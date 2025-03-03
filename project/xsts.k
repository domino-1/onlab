module XSTS-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID-SYNTAX

    syntax Literal ::= Int | Bool
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

    configuration <T>
                    <k> $PGM:Program </k>
                  </T>
endmodule