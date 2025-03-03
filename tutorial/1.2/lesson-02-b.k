module LESSON-02-B

  syntax Color ::= Yellow()
  syntax Color ::= Blue()
  syntax Fruit ::= Banana()
  syntax Fruit ::= Blueberry()
  syntax Color ::= colorOf(Fruit) [function]

  rule colorOf(Banana()) => Yellow()
  rule colorOf(Blueberry()) => Blue()

endmodule
