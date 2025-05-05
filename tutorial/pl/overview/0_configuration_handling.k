module SANDBOX
    imports INT
    imports ID
    imports BOOL

    syntax Value ::= Int
                   | Bool

    syntax Type ::= "int" | "bool"
    syntax Decl ::= Type Id

    syntax Asg ::= Id "=" Value

    syntax Line ::= Asg | Decl
    syntax Program ::= List{Line, ""}

    syntax Empty ::= "empty"

    configuration   <T>
                        <k> $PGM:Program </k>
                        <env> .Map </env>
                    </T>

    rule <k> _:Type I:Id P:Program => P ...</k>
         <env> STATE => STATE [ I <- empty ] </env>

    rule <k> I:Id = V:Value P:Program => P ...</k>
         <env>... I |-> (_ => V) ...</env>

    rule <env>... _ |-> (_:Int => false) ...</env> 

endmodule