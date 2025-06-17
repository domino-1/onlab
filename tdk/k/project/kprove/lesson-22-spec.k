requires "lesson-22.k"
requires "domains.md"

module LESSON-22-SPEC-SYNTAX
    imports LESSON-22-SYNTAX

    syntax Id ::= "$a" [token]

endmodule

module VERIFICATION
    imports K-EQUAL
    imports LESSON-22-SPEC-SYNTAX
    imports LESSON-22
    imports MAP-SYMBOLIC

endmodule

module LESSON-22-SPEC
    imports VERIFICATION

    claim <k> 3 + 4 => 7 ... </k>

    claim <k> if ( 3 + 4 == 7 ) {
            $a = 1 ;
            } else {
            $a = 2 ;
            }
        => . ... </k>
        <store> STORE => STORE [ $a <- 1 ] </store>

endmodule
