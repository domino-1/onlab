requires "substitution.md"

module LAMBDA
    imports ID
    imports SUBSTITUTION
    imports KVAR
    imports INT
    imports BOOL
    
    // syntax Id ::= KVar
    syntax Val ::= KVar
                 | "lambda" KVar "." Exp  [binder]

    syntax Exp ::= Val
                 | Exp Exp      [left, strict] // Lesson 3
                 | "(" Exp ")"  [bracket]

    syntax KResult ::= Val

    // Lesson 2

    rule (lambda X:KVar . E:Exp) V:Val => E[V / X]

    // Lesson 5

    syntax Val ::= Int | Bool
    syntax Exp ::= Exp "*" Exp      [function, strict, left]
                 | Exp "/" Exp      [function, strict]
                 > Exp "+" Exp      [function, strict, left]
                 > Exp "<=" Exp     [function, strict]

    rule I1:Int * I2:Int => I1 *Int I2
    rule I1:Int / I2:Int => I1 /Int I2 requires I2 =/=Int 0
    rule I1:Int + I2:Int => I1 +Int I2
    rule I1:Int <= I2:Int => I1 <=Int I2

    // Lesson 6
    
    syntax Exp ::= "if" Exp "then" Exp "else" Exp   [strict(1)]
    rule if true then E else _ => E
    rule if false then _ else E => E

    // Lesson 7

    syntax Exp ::= "let" KVar "=" Exp "in" Exp
    rule let X = E in E':Exp => (lambda X . E') E   [anywhere]

    // syntax Idb ::= KVar | "$x" | "$y"
    // syntax Exp ::= "letrec" KVar KVar "=" Exp "in" Exp
    // rule letrec F:KVar X:Idb = E in E' 
    //     => let F = 
    //         (lambda $x . ((lambda F . lambda X . E) (lambda $y . ($x $x $y))))
    //         (lambda $x . ((lambda F . lambda X . E) (lambda $y . ($x $x $y))))
    //     in E' [structural]

endmodule