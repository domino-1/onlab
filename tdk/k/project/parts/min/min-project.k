module MIN-PROJECT-SYNTAX
    syntax Tran ::= "tran" "{" "}"
    syntax Env ::= "env" "{" "}"
    syntax Init ::= "init" "{" "}"
    syntax Program ::= Tran Env Init

endmodule

module MIN-PROJECT
    imports MIN-PROJECT-SYNTAX

    configuration <k> $PGM:Program </k>

    rule <k> _:Program => .K </k>
endmodule