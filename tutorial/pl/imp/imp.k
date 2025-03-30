module IMP-SYNTAX
    imports ID
    imports INT
    imports BOOL

    syntax AExp     ::= Int | Id
                      | "(" AExp ")"        [bracket]
                      | AExp "/" AExp       [left, strict]
                      > AExp "+" AExp       [left, strict]
    syntax BExp     ::= Bool
                      | "(" BExp ")"        [bracket]
                      | AExp "<=" AExp      [seqstrict]
                      | "!" BExp            [strict]
                      > BExp "&&" BExp      [left, strict(1)]
    syntax Block    ::= "{" "}"
                      | "{" Stmt "}"
    syntax Stmt     ::= Block
                      | Id "=" AExp ";"     [strict(2)]
                      | "if" "(" BExp ")"
                        Block "else" Block  [strict(1)]
                      | "while" "(" BExp ")"
                        Block
                      > Stmt Stmt           [left]
    syntax Pgm      ::= "int" Ids ";" Stmt
    syntax Ids      ::= List{Id, ","}

endmodule

module IMP
    imports IMP-SYNTAX
    imports MAP

    syntax KResult ::= Int | Bool

    configuration <T> <k> $PGM:Pgm </k> <state> .Map </state> </T>


    //AExp
    rule <k> X:Id => I ...</k> <state>... X |-> I ...</state>
    rule I1:Int / I2:Int => I1 /Int I2 requires I2 =/=Int 0
    rule I1:Int + I2:Int => I1 +Int I2 

    //BExp
    rule I1:Int <= I2:Int => I1 <=Int I2
    rule ! T:Bool => notBool T
    rule true && B => B
    rule false && _ => false

    //Block
    rule {} => .K
    rule {S} => S

    //Stmt
    rule <k> X = I:Int; => .K ...</k> <state>... X |-> (_ => I) ...</state>
    rule S1:Stmt S2:Stmt => S1 ~> S2
    rule if (true) S else _ => S
    rule if (false) _ else S => S
    rule while (B) S => if (B) {S while (B) S} else {}
    
    //Pgm
    rule <k> int (X:Id,Xs:Ids => Xs);_ </k> <state> Rho:Map => Rho [ X <- 0 ] </state>
        requires notBool (X in_keys(Rho))
    rule int .Ids; S => S
endmodule