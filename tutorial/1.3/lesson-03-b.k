module LESSON-03-B
  syntax Color ::= Yellow() | Blue()
  syntax Fruit ::= Banana() | Blueberry()
  syntax Color ::= colorOf(Fruit) [function]
endmodule
