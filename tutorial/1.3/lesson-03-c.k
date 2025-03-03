module LESSON-03-C
  syntax Color ::= "Yellow" "(" ")" | "Blue" "(" ")"
  syntax Fruit ::= "Banana" "(" ")" | "Blueberrry" "(" ")"
  syntax Color ::= "colorOf" "(" Fruit ")" [function]
endmodule
