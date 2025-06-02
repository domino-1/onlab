module EXPR-SYNTAX
    imports INT
    imports BOOL

    syntax Expr ::= Int | Bool
                  | "(" Expr ")" [bracket]
                  | Int "+" Int [function]
                  | Int "-" Int [function]
                  | Int "*" Int [function]
                  | Int "/" Int [function]
                  | Int "mod" Int [function]
                  | Bool "&&" Bool [function]
                  | Bool "||" Bool [function]
                  | Expr "+" Expr [strict]
                  | Expr "-" Expr [strict]
                  | Expr "*" Expr [strict]
                  | Expr "/" Expr [strict]
                  | Expr "mod" Expr [strict]
                  | Expr "&&" Expr [strict]
                  | Expr "||" Expr [strict]
endmodule

module EXPR
    imports EXPR-SYNTAX
    imports INT
    imports BOOL

    rule I1:Int + I2:Int => I1 +Int I2
    rule I1:Int - I2:Int => I1 -Int I2
    rule I1:Int * I2:Int => I1 *Int I2
    rule I1:Int / I2:Int => I1 divInt I2
    rule B1:Bool && B2:Bool => B1 andBool B2
    rule B1:Bool || B2:Bool => B1 orBool B2 
endmodule

module OXSTS-CONDITIONAL-INLINE-SYNTAX
    imports ID
    imports INT
    imports BOOL

     syntax Literal ::= Int | Bool | "empty"
     syntax Assumption ::= "assume" "(" Literal ")"
     syntax Seq ::= List{Opr, ""}

     syntax Block ::= "{" Seq "}"

     syntax Opr ::= "inline" "if" "(" Bool ")" Block
                 | "inline" "if" "(" Bool ")" Block "else" Block 
                 | Assumption

endmodule

module OXSTS-CONDITIONAL-INLINE
    imports OXSTS-CONDITIONAL-INLINE-SYNTAX


    rule inline if ( true ) B => B
    rule inline if ( false ) _ => {}

    rule inline if ( true ) B else _ => B
    rule inline if ( false ) _ else B => B


    rule { S:Seq } => S:Seq

    configuration <T><k> $PGM:Seq </k><out> .K </out></T>

    rule <k> O:Opr Os:Seq => O ~> Os ...</k> [priority(60)]
    rule <k> O:Opr ~> Os:Seq => Os ...</k> 
         <out> .K => O ~> .K ...</out> [priority(60)]
    rule <k> .Seq => .K ...</k> [priority(60)]
    rule <k> { } => .K ...</k>

endmodule