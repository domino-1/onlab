module OXSTS-INLINE-SYNTAX
    imports ID

    syntax Block ::= "{" Stmt "}"

    syntax Tran ::= "tran" Id Block | "tran" "main" Block
    syntax Opr  ::= "inline" Id | "REST"
    syntax Stmt ::= List{Opr, ""}

    syntax Pgm ::= List{Tran,""}

endmodule

module OXSTS-INLINE
    imports OXSTS-INLINE-SYNTAX
    imports LIST
    imports BOOL

    syntax Empty ::= "EMPTY" | "ACTIVE" | "UNINIT" | "active" "(" KItem ")" | "activek" "(" K ")"

    syntax Bool ::= mIsEmpty( KItem ) [function]

    configuration <T>
                    <k> $PGM:Pgm </k>
                    <main> .K </main>
                    <tmp> .K </tmp>
                    <tmp2> .List </tmp2>
                    <tmp3> .List </tmp3>
                    // <transitions>
                    //     <transition multiplicity="*" type="Map">
                    //         <name> .K </name>
                    //         <content> .List </content>
                    //         // <list> .List </list>
                    //     </transition>
                    // </transitions>
                    <map>
                        .Map
                    </map>
                    // <map2>
                    //     .Map
                    // </map2>
                    // <lst>
                    //     .List
                    // </lst>
                  </T>


    //!priority 50-60

    rule <k> tran main { S } Ts => Ts ...</k>
         <main> .K => S </main>

    //Fill up <transitions>, empty out <k>
    rule <k> tran I:Id { S:Stmt } Ts => Ts ...</k>
         //<map> MAP => MAP [ I <- EMPTY ] </map> 
         <tmp> .K => S ~> I </tmp> [priority(60)]
         //<map2> MAP2 => MAP2 [ I <- .List ] </map2> 
         //(.Bag => <transition><name> I </name><content> .List </content></transition>)
    
    rule <tmp> O:Opr Os:Stmt ~> I ~> .K => Os ~> I ~> .K </tmp>
         <tmp2> LIST => LIST ListItem(O) </tmp2>

    rule <tmp2> LIST => .List </tmp2>
         <tmp> .Stmt ~> I:Id => .K ...</tmp>
         <map> MAP => MAP [I <- LIST] </map> [priority(60)]
    
    rule <k> .Pgm => .K ...</k>


    //!priority 70-80
    
    //inline
    rule <main> O:Opr Os:Stmt => Os ...</main>
         <k> .K => O ...</k> [priority(80)]

    rule <k> inline I:Id => active( inline I:Id ) ...</k>
         <map>... I |-> LIST ...</map>
         <tmp3> .List => LIST </tmp3> [priority(70)]

    rule <tmp3> LIST ListItem(O) => LIST </tmp3>
         <tmp> .K => O ...</tmp> [priority(70)]

    rule <tmp> V => .K </tmp>
         <k> active( inline _:Id ) => V ...</k>
         <tmp3> .List </tmp3> [priority(80)]



    // rule <k> inline _:Id => .K ...</k>
    //      <tmp3> .List </tmp3> [priority(60)]

    // //perform inline
    // rule <k> inline I:Id => V ...</k>
    //      <map>... I |-> V ...</map>

    // //move back to main -> nem kell
    // rule <k> M => .K </k>
    //      <main> .Stmt => M ...</main> [priority(80)]

    /* ---- */

    // rule <map>... I |-> (O:Opr S => O ~> S ~> .K) ...</map> //wont compile
    
    // rule <map>... I |-> (O:Opr S => S) ...</map> 
    //      <map2>... I |-> ( LIST => LIST ListItem(O) ) ...</map2>

    // rule <map2>... I |-> (L => .List) ...</map2>
    //      <transition><name> I </name><content> .List => L </content></transition>


    // rule <transition><name> I </name><content> C:List => .List </content></transition> 
    //      <transition><name> _ </name><content> ListItem(inline I:Id) L:List => C L </content></transition> [priority(60)]

    // rule <transition><name> I </name><content> C:List => .List </content></transition> 
    //      <transition><name> _ </name><content> L:List ListItem(inline I:Id) => L C </content></transition> [priority(60)]

    // rule <transition><name> I </name><content> C:List => .List </content></transition> 
    //      <transition><name> _ </name><content> (L1:List ListItem(inline I:Id) => L1 C) ...</content></transition> [priority(60)] //wont bind


    // Perform inlines
    // rule <transition>... 
	// 	    <content>... ListItem(inline I:Id) => C ...</content> 
	//      </transition>
    //      <transition>
	// 	    <name> I:Id </name>
	// 	    <content> C => .List </content>
	//      </transition>

    //Cleanup <map> -> does not work yet
    // rule mIsEmpty( .Stmt ) => true
    // rule mIsEmpty( _ ) => false [owise]

    // rule <map> MAP => MAP[I <- undef] </map>
    //      <name> I </name> requires mIsEmpty( MAP[I] ) [priority(100)]

    // rule (<transition>... <content> .List </content></transition> => .Bag)
endmodule