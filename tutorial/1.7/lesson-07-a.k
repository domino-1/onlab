module LESSON-07-A
  imports BOOL
  imports INT

  syntax Grade ::= "letter-A"
                 | "letter-B"
                 | "letter-C"
                 | "letter-D"
                 | "letter-F"
                 | gradeFromPercentile(Int) [function]
                // | require(Grade, Bool) [function] // see comment block bellow
                //  | Grade "_requires" Bool "|" Int [function]

  rule gradeFromPercentile(I) => letter-A requires I >=Int 90 | 1
  rule gradeFromPercentile(I) => letter-B requires I >=Int 80 andBool I <Int 90 | 2
  rule gradeFromPercentile(I) => letter-C requires I >=Int 70 andBool I <Int 80 | 3
  rule gradeFromPercentile(I) => letter-D requires I >=Int 60 andBool I <Int 70 | 4
  rule gradeFromPercentile(I) => letter-F requires I <Int 60 | 5 [owise] 

  /** Is it possible to rewrite this without 'requires' using a function?
   *  Partially only? It works for a single rule, but so far when I have multiple, I haven't been
   *  able to figure out a way for it to go to the next rule when it evaluates to false
   */
  // rule require(G, true) => G
  // rule gradeFromPercentile(I) => require(letter-A, I >=Int 90)
  // rule G _requires true | _ => G
  // rule G _requires B | I => G _requires B | I +Int 1

endmodule
