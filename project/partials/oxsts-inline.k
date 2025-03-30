module OXSTS-INLINE-SYNTAX
    imports ID

    syntax Block ::= "{" Stmt "}"

    syntax Tran ::= "tran" Id Block
    syntax Opr  ::= "inline" Id | "REST"
    syntax Stmt ::= List{Opr, ""}

    syntax Pgm ::= List{Tran,""}

endmodule

module OXSTS-INLINE
    imports OXSTS-INLINE-SYNTAX
    imports LIST
    imports BOOL

    syntax Empty ::= "EMPTY" | "ACTIVE" | "UNINIT"

    syntax Bool ::= mIsEmpty( KItem ) [function]

    configuration <T>
                    <k> $PGM:Pgm </k>
                    <transitions>
                        <transition multiplicity="*" type="Map">
                            <name> .K </name>
                            <content> .List </content>
                            // <list> .List </list>
                        </transition>
                    </transitions>
                    <map>
                        .Map
                    </map>
                    <map2>
                        .Map
                    </map2>
                    <lst>
                        .List
                    </lst>
                  </T>

    //Fill up <transitions>, empty out <k>
    rule <k> tran I:Id { S:Stmt } Ts => Ts</k>
         <map> MAP => MAP [I <- S] </map>
         <map2> MAP2 => MAP2 [ I <- .List ] </map2> 
         (.Bag => <transition><name> I </name><content> .List </content></transition>)

    // rule <map>... I |-> (O:Opr S => O ~> S ~> .K) ...</map> //wont compile
    
    rule <map>... I |-> (O:Opr S => S) ...</map> 
         <map2>... I |-> ( LIST => LIST ListItem(O) ) ...</map2>

    rule <map2>... I |-> (L => .List) ...</map2>
         <transition><name> I </name><content> .List => L </content></transition>


    rule <transition><name> I </name><content> C:List => .List </content></transition> 
         <transition><name> _ </name><content> ListItem(inline I:Id) L:List => C L </content></transition> [priority(60)]

    rule <transition><name> I </name><content> C:List => .List </content></transition> 
         <transition><name> _ </name><content> L:List ListItem(inline I:Id) => L C </content></transition> [priority(60)]

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

    rule (<transition>... <content> .List </content></transition> => .Bag)
endmodule