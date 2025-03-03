module SKELETON-SYNTAX
  imports INT-SYNTAX
  imports ID-SYNTAX

  syntax Exp ::= Id | Int
  syntax Decl ::= "int" Id "=" Exp ";" [strict(2)]
  syntax Pgm ::= List{Decl,""}
endmodule

module SKELETON
  imports SKELETON-SYNTAX
  imports BOOL

  configuration <T>
                  <k> $PGM:Pgm </k>
                  <state> .Map </state>
                </T>

  // declaration sequence
  rule <k> D:Decl P:Pgm => D ~> P ...</k>
  rule <k> .Pgm => .K ...</k>

//   // variable declaration
//   rule <k> int X:Id = I:Int ; => . ...</k>
//        <state> STATE => STATE [ X <- I ] </state>

//   // variable lookup
//   rule <k> X:Id => I ...</k>
//        <state>... X |-> I ...</state>

  syntax Bool ::= isKResult(K) [symbol(isKResult), function]
  rule isKResult(_:Int) => true
  rule isKResult(_) => false [owise]
endmodule
