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
    
    syntax Choice ::= "choice {" Sequence "}" ChoiceOrBlocks
    syntax ChoiceOrBlock ::= "or {" Sequence "}" 
    syntax ChoiceOrBlocks ::= List{ChoiceOrBlock, ""}

    syntax Transition ::= "tran {" Sequence "}"

    syntax Sequence ::= List{Operation, ""}

    syntax Line ::= Transition | VariableDeclaration
    syntax Program ::= List{Line, ""}
endmodule

module XSTS
    imports XSTS-SYNTAX
    imports LIST

    configuration <T>
                    <k> $PGM:Program </k>
                    <state>
                      <variables> .Map </variables>
                      <transitions> .List </transitions>
                    </state>
                  </T>

    // declaration sequence
    rule <k> L:Line P:Program => L ~> P ...</k>
    rule <k> .Program => .K ...</k>

    // declarations
    rule <k> var X:Id : integer => .K ...</k>
         <variables> STATE => STATE [ X <- empty ] </variables> //default init of empty is possibly temporary
    rule <k> var X:Id : boolean => .K ...</k>
         <variables> STATE => STATE [ X <- empty ] </variables> //default init of empty is possibly temporary
    rule <k> T:Transition => .K ... </k>
         <transitions> .List => ListItem(T) ... </transitions>

endmodule