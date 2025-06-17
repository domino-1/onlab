requires "project.k"

module PROJECT-SPEC
    imports PROJECT

    syntax Id ::= "$a" [token]

    claim <k> init {} => .K </k>
endmodule