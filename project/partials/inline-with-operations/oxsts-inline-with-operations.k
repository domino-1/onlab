module OXSTS-INLINE-WITH-OPERATIONS-SYNTAX
    imports ID
    imports INT
    imports BOOL

    /* temp */
    syntax Literal ::= Int | Bool | "empty"
    syntax Assignment ::= Id ":=" Literal
    syntax Havoc ::= "havoc" "(" Id ")"
    syntax Assumption ::= "assume" "(" Literal ")"

    syntax Choice ::= "choice" "{" Seq "}" ChoiceOrBlocks | "choice" Int
    syntax ChoiceOrBlock ::= "or" "{" Seq "}" | "or" Int
    syntax ChoiceOrBlocks ::= List{ChoiceOrBlock, ""}
    /* temp */

    syntax Block ::= "{" Seq "}" | "{""}"

    syntax Tran ::= "tran" Id "("")" Block | "tran" "main" Block
    syntax Opr  ::= "inline" Id "("")" | "REST"
                  | Assignment | Havoc | Assumption | Choice
    syntax Seq ::= List{Opr, ""}

    syntax Pgm ::= List{Tran,""}

endmodule

module OXSTS-INLINE-WITH-OPERATIONS
    imports OXSTS-INLINE-WITH-OPERATIONS-SYNTAX
    imports LIST
    imports BOOL

    syntax Empty ::= "EMPTY" | "ACTIVE" | "UNINIT" | "active" "(" KItem ")" | "activek" "(" K ")"

    syntax Bool ::= mIsEmpty( KItem ) [function]

    configuration <T>
                    <k> $PGM:Pgm </k>
                    <k2> .K </k2>
                    <main> .K </main>
                    <store>
                        <tmp> .K </tmp>
                        <tmp2> .List </tmp2>
                        <tmp3> .List </tmp3>
                        <tmp4> .K </tmp4>
                    </store>
                    <map>
                        .Map
                    </map>
                  </T>


    //!priority 50-60

    rule <k> tran main { S } Ts => Ts ...</k>
         <main> .K => S </main>

    //Fill up <transitions>, empty out <k>
    rule <k> tran I:Id () { S:Seq } Ts => Ts ...</k>
         <tmp> .K => S ~> I </tmp> [priority(60)]
    
    rule <tmp> O:Opr Os:Seq ~> I ~> .K => Os ~> I ~> .K </tmp>
         <tmp2> LIST => LIST ListItem(O) </tmp2>

    rule <tmp2> LIST => .List </tmp2>
         <tmp> .Seq ~> I:Id => .K ...</tmp>
         <map> MAP => MAP [I <- LIST] </map> [priority(60)]
    
    rule <k> .Pgm => .K ...</k>


    //!priority 70-80: non recursive inlines
    
    rule <main> O:Opr Os:Seq => Os ...</main>
         <k> .K => O ...</k> [priority(80)]

    rule <k> inline I:Id () => active( inline I:Id () ) ...</k>
         <map>... I |-> LIST ...</map>
         <tmp3> .List => LIST </tmp3> [priority(70)]

    rule <tmp3> LIST ListItem(O) => LIST </tmp3>
         <tmp> .K => O ...</tmp> [priority(70)]

    rule <tmp> V => .K </tmp>
         <k> active( inline _:Id () ) => V ...</k>
         <tmp3> .List </tmp3> [priority(80)]


    //! priority 90-100: recursive inlines

    //if not inline
    rule <k> O:Opr => .K ...</k>
         <k2> .K => O ...</k2> [priority(95)]

    //the previous inline rules take it from here in case it is an inline

    //! priority 100+: cleanup
    rule <k2> O:Opr => .K ...</k2> 
         <tmp2> LIST => LIST ListItem(O) </tmp2> [priority(100)]

    rule <tmp4> .K => active(O) </tmp4>
         <tmp2> LIST ListItem(O) => LIST </tmp2> [priority(100)]
    
    rule <tmp4> active(O:Opr) => active(O .Seq) ...</tmp4> [priority(100)]

    rule <tmp4> active(Os:Seq) => active(O Os) ...</tmp4>
         <tmp2> LIST ListItem(O) => LIST </tmp2> [priority(100)]

    rule <tmp4> active(Os:Seq) ~> .K => .K </tmp4>
         <k> .K => tran main { Os } .Pgm </k> [priority(105)]

endmodule