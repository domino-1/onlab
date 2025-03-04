module XSTS-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID-SYNTAX

    syntax Literal ::= Int | Bool | "empty"
    syntax VariableDeclaration ::= "var" Id ":" "integer"
                                 | "var" Id ":" "boolean"

    syntax Assignment ::= Id ":=" Literal
    syntax Havoc ::= "havoc(" Id ")"
    syntax Assumption ::= "assume(" Literal ")"

    syntax Operation ::= Choice
                       | Assignment
                       | Havoc
                       | Assumption
    
    // syntax ChoiceToken ::= "choice" [token]
    syntax Choice ::= "choice {" Sequence "}" ChoiceOrBlocks | "choice" Int
    syntax ChoiceOrBlock ::= "or {" Sequence "}" | "or" Int
    syntax ChoiceOrBlocks ::= List{ChoiceOrBlock, ""}

    syntax Transition ::= "tran {" Sequence "}"
    syntax Transitions ::= List{Transition, ""}

    syntax Sequence ::= List{Operation, ""}
    
    // syntax Bool ::= hasChoice(Sequence) [function]
    //               | hasOrBlock(Choice) [function]

    syntax Line ::= Transition | VariableDeclaration
    syntax Program ::= List{Line, ""}

endmodule

module XSTS
    imports XSTS-SYNTAX
    imports LIST
    imports INT
    imports MAP

    syntax Work ::= "work(" Transition ")" | "work(" Operation ")"

    configuration <T>
                    <k> $PGM:Program </k>
                    <state>
                        <variables> .Map </variables>
                        <transitions>
                            <transition multiplicity="*" type="Map">
                                <id> 0 </id>
                                <sequence> .List </sequence>
                                // <choiceblock>
                                // // <choices multiplicity="*" type="Map">
                                // //     <cid> 0 </cid>
                                // //     <choice> .List </choice>
                                // //     // <csequence multiplicity="*" type="Map">
                                // //     //     <oid> 0 </oid>
                                // //     //     <or> .List </or>
                                // //     // </csequence>
                                // // </choices>
                                // </choiceblock>
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
                  </T>

    // declaration sequence
    rule <k> L:Line P:Program => L ~> P ...</k>
    rule <k> .Program => .K ...</k>

    // declarations

    //Handle variable declarations, add them into the <variables> Map as empty. 
    // This can get expanded with default values relatively easily
    rule <k> var X:Id : integer => .K ...</k>
         <variables> STATE => STATE [ X <- empty ] </variables> [priority(48)] //default init of empty is possibly temporary
    rule <k> var X:Id : boolean => .K ...</k>
         <variables> STATE => STATE [ X <- empty ] </variables> [priority(48)] //default init of empty is possibly temporary
    
    //Select a transition, create a transition block for it
    rule <k> tran { S:Sequence } => work( tran { S:Sequence } ) ... </k>
         <cur-id> CURID => CURID +Int 1 </cur-id>
         (.Bag => <transition><id>CURID +Int 1</id><sequence>.List</sequence></transition>)

    //Rule A: Remove the first operation from the transition, put it into the current <sequence> list
    // Unless that operation is a choice!
    rule <k> work( tran { O:Operation S:Sequence } ) => work( tran { S:Sequence } ) ~> .K ...</k>
         <cur-id> CURID </cur-id>
         <transition><id>CURID</id><sequence> .List => ListItem(O) ... </sequence></transition> [priority(51)]
    //Rule B: If that operation is a choice, pull it out into the first spot in the <k> sequence
    //Create a choice block for that choice and put the choice id into the <sequence> list
    rule <k> work( tran { O:Choice S:Sequence } ) => O ~> work( tran { S:Sequence } ) ~> .K ...</k>
         <cur-id> CURID </cur-id>
         <choice-id> CHOICEID </choice-id>
         <transition><id>CURID</id><sequence> .List => ListItem( choice CHOICEID ) ... </sequence></transition>
         (.Bag => <choice><cid> CHOICEID </cid><csequence> .List </csequence></choice>)
    //If the transition is processed, remove its husk from k
    rule <k> work( tran { .Sequence } ) => .K ... </k>

    //Rule C: If you see a choice at the start of the k sequence (as the result of Rule B), put 
    //it's first sequence into the current choice block, and leave the or blocks on k
    //This rule only makes sense if it comes after Rule B
    rule <k> choice { S:Sequence } B => B ~> .K ...</k>
         <choice-id> CHOICEID </choice-id>
         <choice><cid>CHOICEID</cid><csequence> .List => ListItem( S ) ... </csequence></choice>
    //Rule D: If you see an or block at the start of the k sequence (as the result of Rule C), put
    //it's sequence into the current choice block, and leave the rest of the or blocks
    //This rule only makes sense coming after Rule C
    rule <k> or { B:Sequence } S:ChoiceOrBlocks => S:ChoiceOrBlocks ...</k>
         <choice-id> CHOICEID </choice-id>
         <choice><cid>CHOICEID</cid><csequence> .List => ListItem( B ) ... </csequence></choice>
    //Rule E: If no more or blocks are left, increase the choice counter by 1 and remove the empty orList from k
    //At this point, if Rule C or D run without Rule B having first run, we will encounter a bad error, because
    // those rules will try to go into a non existent choice block
    rule <k> .ChoiceOrBlocks => .K ...</k>
         <choice-id> CHOICEID => CHOICEID +Int 1 </choice-id>


    //Handle choice blocks -> or blocks
    rule <k> .K </k>
         <choice><csequence> LIST </cseqence></choice>
    

endmodule