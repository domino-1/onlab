```input
`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(#token("1","Int"),`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(#token("1","Int"),#token("3","Int"))),`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(#token("9","Int"),#token("1","Int")))
```

```k
module AST-DIAGRAM-MERMAID
    imports STRING

    //syntax Backtick ::= "`"
    syntax AstStatementName ::= r"`.+?`" [token]

    //syntax AstStatement ::= AstStatementName
endmodule
```

```mermaid
graph TD
        STNT_0[´_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp´]
        STNT_1[´_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp´]
        STNT_2[´_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp´]
        STNT_3[´_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp´]
        TKN_0[#token<″1″,″Int″>]
        TKN_1[#token<″1″,″Int″>]
        TKN_2[#token<″3″,″Int″>]
        TKN_3[#token<″9″,″Int″>]
        TKN_4[#token<″1″,″Int″>]
        STNT_2 --> TKN_1
        STNT_2 --> TKN_2
        STNT_1 --> TKN_0
        STNT_1 --> STNT_2
        STNT_3 --> TKN_3
        STNT_3 --> TKN_4
        STNT_0 --> STNT_1
        STNT_0 --> STNT_3
```


```mermaid
graph TD
        STNT_0[´___SKELETON-SYNTAX_Pgm_Decl_Pgm´]
        STNT_1[´int_=_;_SKELETON-SYNTAX_Decl_Id_Exp´]
        STNT_2[´___SKELETON-SYNTAX_Pgm_Decl_Pgm´]
        STNT_3[´int_=_;_SKELETON-SYNTAX_Decl_Id_Exp´]
        STNT_4[´.List<<″___SKELETON-SYNTAX_Pgm_Decl_Pgm″>>_Pgm´]
        TKN_0[#token<″x″,″Id″>]
        TKN_1[#token<″1″,″Int″>]
        TKN_2[#token<″y″,″Id″>]
        TKN_3[#token<″2″,″Int″>]
        STNT_1 --> TKN_0
        STNT_1 --> TKN_1
        STNT_3 --> TKN_2
        STNT_3 --> TKN_3
        STNT_4 --> .KList
        STNT_4 --> .KList
        STNT_2 --> STNT_3
        STNT_2 --> STNT_4
        STNT_0 --> STNT_1
        STNT_0 --> STNT_2
```