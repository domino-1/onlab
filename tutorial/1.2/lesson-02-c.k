module LESSON-02-C

  syntax Color ::= Yellow()
                 | Blue()
                 | colorOf(Fruit) [function]
  syntax Fruit ::= Banana()
                 | Blueberry()

  rule colorOf(Banana()) => Yellow()
  rule colorOf(Blueberry()) => Blue()

endmodule
