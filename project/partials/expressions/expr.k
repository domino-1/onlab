module EXPR-SYNTAX
    imports INT
    imports BOOL

    syntax Expr ::= Int | Bool |
                   "(" Expr ")" [bracket]
                //   | Int "+" Int [function]
                //   | Int "-" Int [function]
                //   | Int "*" Int [function]
                //   | Int "/" Int [function]
                //   | Int "mod" Int [function]
                //   | Bool "&&" Bool [function]
                //   | Bool "||" Bool [function]
                  | Expr "+" Expr [seqstrict, right]
                  | Expr "-" Expr [seqstrict, right]
                  | Expr "*" Expr [strict]
                  | Expr "/" Expr [strict]
                  | Expr "&&" Expr [strict]
                  | Expr "||" Expr [strict]
endmodule

module EXPR
    imports EXPR-SYNTAX
    imports INT
    imports BOOL

    syntax KResult ::= Bool | Int

    rule I1:Int + I2:Int => I1 +Int I2
    rule I1:Int - I2:Int => I1 -Int I2
    rule I1:Int * I2:Int => I1 *Int I2
    rule I1:Int / I2:Int => I1 divInt I2
    rule B1:Bool && B2:Bool => B1 andBool B2
    rule B1:Bool || B2:Bool => B1 orBool B2 
endmodule