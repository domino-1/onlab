module OXSTS-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID-SYNTAX
    imports STRING-SYNTAX

    syntax Valami ::= "TODO"

    syntax Literal ::= Int | Bool | "empty"
    syntax Expression ::= "if" "(" Bool ")" "{" Valami "}"
                        | "if" "(" Bool ")" "{" Valami "}" "else" "{" Valami "}"

    syntax Type ::= "integer" | "boolean"
    syntax VariableDeclaration ::= "var" Id ":" Type
                                 | "var" Id ":" Type "=" Int 
                                 | "var" Id ":" Type
                                 | "var" Id ":" Type "=" Bool

    syntax Assignment ::= Id ":=" Literal
    syntax Havoc ::= "havoc" "(" Id ")"
    syntax Assumption ::= "assume" "(" Literal ")"
    syntax Inline ::= "inline" OTransitionName "()" ";"
                    | "inline" Expression

    syntax Operation ::= Choice
                       | Assignment
                       | Havoc
                       | Assumption
                       | Inline
    
    syntax Choice ::= "choice" "{" Sequence "}" ChoiceOrBlocks | "choice" Int
    syntax ChoiceOrBlock ::= "or" "{" Sequence "}" | "or" Int
    syntax ChoiceOrBlocks ::= List{ChoiceOrBlock, ""}

    syntax OTransitionName ::= Id | "main"
    syntax OTransition ::= "tran" OTransitionName "{" Sequence "}"

    syntax OTransitions ::= List{OTransition, ""}

    syntax Transition ::= "tran {" Sequence "}"
    syntax Transitions ::= List{Transition, ""}

    syntax Sequence ::= List{Operation, ""}

    syntax Line ::= OTransition | VariableDeclaration
    syntax Program ::= List{Line, ""}
endmodule

module OXSTS
    imports OXSTS-SYNTAX
    imports LIST
    imports INT
    imports MAP
    imports STRING

    syntax Work ::= "work(" Transition ")" | "work(" Operation ")" | "work(" ChoiceOrBlock ")"
    syntax Placeholder ::= "PLACEHOLDER"

    configuration <T>
                    <k> $PGM:Program </k>
                    <state>
                        <variables> .Map </variables>
                        <transitions-key> .Map </transitions-key>
                        <transitions>
                            <transition multiplicity="*" type="Map">
                                <id> 0 </id>
                                <sequence> .List </sequence>
                            </transition>
                        </transitions>
                        <choices>
                            <choice multiplicity="*" type="Map">
                                <cid> 0 </cid>
                                <csequence> .List </csequence>
                            </choice>
                        </choices>
                        <ors>
                            <or multiplicity="*" type="Map">
                                 <oid> 0 </oid>
                                 <osequence> .List </osequence>
                            </or>
                        </ors>
                    </state>
                    <cur-id> 0 </cur-id>
                    <choice-id> 0 </choice-id>
                    <or-id> 0 </or-id>
                    <temp> .List </temp>
                  </T>

    // declaration sequence
    rule <k> L:Line P:Program => L ~> P ...</k>
    rule <k> .Program => .K ...</k>

    // declarations

    /* Handle variable declarations, add them into the <variables> Map
    */
    rule <k> var X:Id : integer => .K ...</k>
         <variables> STATE => STATE [ X <- empty ] </variables> [priority(48)] //default init of empty is possibly temporary
    rule <k> var X:Id : integer = I:Int => .K ...</k>
         <variables> STATE => STATE [ X <- I ] </variables> [priority(48)]

    
    rule <k> var X:Id : boolean => .K ...</k>
         <variables> STATE => STATE [ X <- empty ] </variables> [priority(48)] //default init of empty is possibly temporary
    rule <k> var X:Id : boolean = B:Bool => .K ...</k>
         <variables> STATE => STATE [ X <- B ] </variables> [priority(48)]
    
    /*
    * 1. Should typechecking be done for operations? 
    * 2. Currently declarations with default values of the wrong type are not recognized by any rule (which is the expected behaviour)
    * causing everything to simply stop. Maybe 'exceptions' like that should be hadled a bit more gracefully
    * 2.1. Possible solution is making them also unrecognized as syntax, which will cause an error and stop execution
    */

    //named tran to tran
    rule <k> tran NAME:OTransitionName { S:Sequence } => tran { S:Sequence } ... </k>
         <cur-id> CURID </cur-id>
         <transitions-key> KEYS => KEYS [ NAME <- CURID +Int 1 ] </transitions-key>

    //Select a transition, create a transition block for it
    rule <k> tran { S:Sequence } => work( tran { S:Sequence } ) ... </k>
         <cur-id> CURID => CURID +Int 1 </cur-id>
         (.Bag => <transition><id>CURID +Int 1</id><sequence>.List</sequence></transition>)

    /* Rule A: Remove the first operation from the transition, put it into the current <sequence> list
    *  Unless that operation is a choice!
    */
    rule <k> work( tran { O:Operation S:Sequence } ) => work( tran { S:Sequence } ) ~> .K ...</k>
         <cur-id> CURID </cur-id>
         <transition><id>CURID</id><sequence> .List => ListItem(O) ... </sequence></transition> [priority(51)]
    /* Rule B: If that operation is a choice, pull it out into the first spot in the <k> sequence
    * Create a choice block for that choice and put the choice id into the <sequence> list
    */
    rule <k> work( tran { O:Choice S:Sequence } ) => O ~> work( tran { S:Sequence } ) ~> .K ...</k>
         <cur-id> CURID </cur-id>
         <choice-id> CHOICEID </choice-id>
         <transition><id>CURID</id><sequence> .List => ListItem( choice CHOICEID ) ... </sequence></transition>
         (.Bag => <choice><cid> CHOICEID </cid><csequence> .List </csequence></choice>)
    //If the transition is processed, remove its husk from k
    rule <k> work( tran { .Sequence } ) => .K ... </k>

    /* Rule C: If you see a choice at the start of the k sequence (as the result of Rule B), put 
    * it's first sequence into the current choice block, and leave the or blocks on k
    * This rule only makes sense if it comes after Rule B
    */
    rule <k> choice { S:Sequence } B => B ~> .K ...</k>
         <choice-id> CHOICEID </choice-id>
         <choice><cid>CHOICEID</cid><csequence> .List => ListItem( S ) ... </csequence></choice>
    /* Rule D: If you see an or block at the start of the k sequence (as the result of Rule C), put
    * it's sequence into the current choice block, and leave the rest of the or blocks
    * This rule only makes sense coming after Rule C
    */
    rule <k> or { B:Sequence } S:ChoiceOrBlocks => S:ChoiceOrBlocks ...</k>
         <choice-id> CHOICEID </choice-id>
         <choice><cid>CHOICEID</cid><csequence> .List => ListItem( B ) ... </csequence></choice>
    /* Rule E: If no more or blocks are left, increase the choice counter by 1 and remove the empty orList from k
    * At this point, if Rule C or D run without Rule B having first run, we will encounter a bad error, because
    *  those rules will try to go into a non existent choice block
    */
    rule <k> .ChoiceOrBlocks => .K ...</k>
         <choice-id> CHOICEID => CHOICEID +Int 1 </choice-id>


    //Handle choice blocks -> or blocks
    /* If K is empty (meaning we are done with all previous operations)
    * Take the first sequence insite <csequence> and create an or block and osequence for it
    * Pull up the sequence into k
    * Add an or identifier refering to the newly created or block to <temp>
    *  This is important because if we add it straight into csequence it will block further steps
    *   (since at that point csequence will no longer begin with a ListItem(S:Sequence) but a ListItem(S:ChoiceOrBlock) at some point)
    *   Theres probably a better way to do this? TODO: Look a bit better at semantic list pattern matching
    */
    rule <k> .K => S ~> .K </k>
         <or-id> ORID </or-id>
         <choice>...<csequence> ListItem(S:Sequence) => .List ...</csequence></choice>
         <temp> .List => ListItem( or ORID ) ...</temp>
         (.Bag => <or><oid> ORID </oid><osequence> .List </osequence></or>)
    
    /* In <k>, split off the first operation from the sequence (unless it is is a choice, in that case see the next rule)
    * Put the operation into the osequence list
    */
    rule <k> O:Operation S:Sequence => S ...</k>
         <or-id> ORID </or-id>
         <or><oid> ORID </oid><osequence> .List => ListItem(O) ...</osequence></or> [priority(51)]
    
    /* If in the previous rule we had a choice instead of just an operation:
    * Create a new choice block for it (equivalent to previous rules)
    * Put a choice identifier to that choice into the osequence
    * Pull out the choice into its own unit in k
    *  This is imporant! At this point a previous rule (Rule C) will recoginse this and handle the rest of the choice!
    *  Eg it will put its initial sequence into the list, hand off to furhter rules to handle the other or sequences, etc...
    */
    rule <k> C:Choice S:Sequence => C ~> S ...</k>
         <or-id> ORID </or-id>
         <or><oid> ORID </oid><osequence> .List => ListItem(choice CHOICEID) ...</osequence></or>
         <choice-id> CHOICEID </choice-id>
         (.Bag => <choice><cid> CHOICEID </cid><csequence> .List </csequence></choice>)
    
    //Cleanup when: If we have finished handling a or sequence, but not yet the whole choice
    rule <k> .Sequence => .K ...</k>
         <or-id> ORID => ORID +Int 1 </or-id> [priority(51)]

    /* Cleanup when: If we have finished both an or sequence and an enitre choice
    * Indicated by the empty csequence list (csequence lists should only be empty here, nowhere else, othervise we might get into a loop)
    *   (osequences can currently be empty, maybe that should change for consistency's sake)
    *     ((An empty osequence means that the whole block was empty, eg choice {}, or {}
    *       It happens by: choice {} becomes <csequence>ListItem(.Sequence)</csequence> which
    *       becomes <osequence>.List</osequence>))
    * Move the or identifiers stored in <temp> back into csequence
    */
    rule <k> .Sequence => .K ...</k>
         <or-id> ORID => ORID +Int 1 </or-id>
         <temp> L:List => .List </temp>
         <csequence> .List => L </csequence>


    //
    rule <sequence> ListItem( inline NAME:OTransitionName () ; ) LIST:List => LIST ... </sequence>
         <transitions-key> KEYS:Map </transitions-key>
         <transition><id> CURID:Int </id><sequence> L:List </sequence></transition>
         <temp> .List => L </temp> requires CURID ==Int KEYS [ NAME ] [priority(52)]
         //KEYS[alma] -> 1
         //transitions>id=1 -> 

    rule <sequence> LIST:List => L LIST </sequence>
         <temp> L:List => .List </temp> [priority(52)]

endmodule