module XSTS-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID-SYNTAX

    syntax Literal ::= Int | Bool | Id

    syntax Enums ::= List{Id, ","}
    syntax TypeDeclaration ::= "type" Id ":" "{" Enums "}"
    
    syntax TypeName ::= "integer" | "boolean" | Id
    syntax VariableDeclaration ::= "var" Id ":" TypeName
                                 | "var" Id ":" TypeName "=" Int 
                                 | "var" Id ":" TypeName "=" Bool
                                 | "var" Id ":" TypeName "=" Id

    syntax Assignment ::= Id ":=" Literal
    syntax Havoc ::= "havoc" "(" Id ")"
    syntax Assumption ::= "assume" "(" Literal ")" //lehet Expr, literalExpression vagy ReferenceExpression

    syntax Operation ::= Choice
                       | Assignment
                       | Havoc
                       | Assumption
    
    syntax Choice ::= "choice" "{" Sequence "}" ChoiceOrBlocks

    // syntax Block ::= "{" Sequence "}"
    // syntax Ors ::= List{Block, "or"}
    // syntax OrBlock ::= "{" Sequence "}" | "{" Sequence "}" "or"

    // syntax Choice ::= "choice" "{" Sequence "}" ("or" "{" Sequence "}")*

    syntax ChoiceOrBlock ::= "or" "{" Sequence "}"
    syntax ChoiceOrBlocks ::= List{ChoiceOrBlock, ""}
    
    syntax Sequence ::= List{Operation, ""}

    syntax Transition ::= "tran" "{" Sequence "}" | "tran" "{" "}"
    syntax Init ::= "init" "{" Sequence "}" | "init" "{" "}"
    syntax Env ::= "env" "{" Sequence "}" | "env" "{" "}"

endmodule

module PROJECT-SYNTAX
    imports XSTS-SYNTAX

    syntax Declaration ::= VariableDeclaration | TypeDeclaration
    syntax Declarations ::= List{Declaration, ""}

    syntax Program ::= Declarations Transition Env Init
                     | Declarations Init //(TODO: remove) minimal for testing

endmodule

module CONFIGURATION
    imports PROJECT-SYNTAX

    configuration <T>
        <k> $PGM:Program </k>
        <state>
            <enum-definitions> .Map </enum-definitions>
            <variables>
                <enum-type> .Map </enum-type>
                <enum> .Map </enum>
                <integer> .Map </integer>
                <boolean> .Map </boolean>
            </variables>
            <init> .K </init>
            <transition> .K </transition>
            <env> .K </env>
        </state>
        <temp>
            <linking>
                <linking-declarations> .K </linking-declarations>
                <linking-transition> .K </linking-transition>
                <linking-env> .K </linking-env>
                <linking-init> .K </linking-init>
            </linking>
        </temp>
        <runner> .K </runner>
        <status> 0 </status>
        <return-status> -1 </return-status>
        <discard-errors> false </discard-errors>
    </T>

    /* status key:
    0: program linking
    1: declaration semantics
    2: init block
    3: tran block
    4: env block
    100: transitions runner

    return status: -1 means no return expected
    */

    /* semantic sorts */
    syntax Literal ::= "empty" //top
    syntax Choice ::= "choice" Int
    syntax ChoiceOrBlock ::= "or" Int
endmodule

module PROGRAM-LINKING
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    rule <k> D:Declarations I:Init => D tran{} env{} I </k> //(TODO: remove) minimal for testing

    rule <k> D:Declarations T:Transition E:Env I:Init => .K </k>
        <linking-declarations> .K => D </linking-declarations>
        <linking-transition> .K => T </linking-transition>
        <linking-env> .K => E </linking-env>
        <linking-init> .K => I </linking-init>
        <status> 0 => 1 </status>
endmodule

module DECLARATIONS
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //types
    rule <linking-declarations> T:TypeDeclaration D:Declarations => T ~> D ... </linking-declarations>
         <status> 1 </status>

    rule <linking-declarations> type I:Id : { E:Enums } => .K ... </linking-declarations>
         <enum-definitions> ENUMS => ENUMS [ I <- E ] </enum-definitions>
         <status> 1 </status>

    rule <linking-declarations> V:VariableDeclaration D:Declarations => V ~> D ... </linking-declarations>
         <status> 1 </status>

    //integers
    rule <linking-declarations> var I:Id : integer => .K ... </linking-declarations>
         <integer> INTEGER => INTEGER [ I <- empty ] </integer>
         <status> 1 </status>

    rule <linking-declarations> var I:Id : integer = V:Int => .K ... </linking-declarations>
         <integer> INTEGER => INTEGER [ I <- V ] </integer>
         <status> 1 </status>

    //booleans
    rule <linking-declarations> var I:Id : boolean => .K ... </linking-declarations>
         <boolean> BOOLEAN => BOOLEAN [ I <- empty ] </boolean>
         <status> 1 </status>

    rule <linking-declarations> var I:Id : boolean = V:Bool => .K ... </linking-declarations>
         <boolean> BOOLEAN => BOOLEAN [ I <- V ] </boolean>
         <status> 1 </status>

    //enums
    rule <linking-declarations> var I:Id : T:Id => .K ... </linking-declarations>
         <enum-type> TYPE => TYPE [ I <- T ] </enum-type>
         <enum> ENUM => ENUM [ I <- empty ] </enum>
         <status> 1 </status>

    rule <linking-declarations> var I:Id : T:Id = V:Id => .K ... </linking-declarations>
         <enum-type> TYPE => TYPE [ I <- T ] </enum-type>
         <enum> ENUM => ENUM [ I <- V ] </enum>
         <status> 1 </status>

    //cleanup
    rule <linking-declarations> .Declarations => .K ... </linking-declarations>
         <status> 1 => 2 </status>
endmodule

module TRAN-INIT
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //add to state
    rule <linking-init> init { S:Sequence } => .K ... </linking-init>
         <init> .K => S </init>
         <status> 2 </status>

    //passing to runner
    rule <init> E:Sequence => .K </init>
         <runner> .K => E </runner>
         <status> 2 => 100 </status>
         <return-status> -1 => 2 </return-status> [priority(100)]

    rule <init> .K </init>
         <status> 2 => 3 </status> [priority(100)]
    
endmodule

module TRAN-TRAN
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //add to state
    rule <linking-transition> tran { S:Sequence } => .K ... </linking-transition>
         <transition> .K => S </transition>
         <status> 3 </status>

    //passing to runner
    rule <transition> E:Sequence </transition>
         <runner> .K => E </runner>
         <status> 3 => 100 </status>
         <return-status> -1 => 4 </return-status> [priority(100)]
         /* by passing in 4 as the return status, it will go to ENV next. This is not pretty, since this way it doesn't allow for any
         * closing operations after the running is done, but before we move on to env.
         * If closing operations are needed, it could possibly be done by <transition> E:... => active(E) </transition>
         * and a new rule <transition> active(E:...) => E </transition> <status> 3 => 4 </status> 
         * which would prevent looping
         */
    
endmodule

module TRAN-ENV
    imports CONFIGURATION
    imports PROJECT-SYNTAX

    //add to state
    rule <linking-env> env { S:Sequence } => .K ... </linking-env>
         <env> .K => S </env>
         <status> 4 </status>

    //passing to runner
    rule <env> E:Sequence </env>
         <runner> .K => E </runner>
         <status> 4 => 100 </status>
         <return-status> -1 => 3 </return-status> [priority(100)]
         /* by passing in 3 as the return status, it will go to TRAN next. This is not pretty, since this way it doesn't allow for any
         * closing operations after the running is done, but before we move on to tran.
         * If closing operations are needed, it could possibly be done by <transition> E:... => active(E) </transition>
         * and a new rule <transition> active(E:...) => E </transition> <status> 4 => 3 </status> 
         * which would prevent looping
         */
    
endmodule

module RUN-TRANSITION
    imports CONFIGURATION
    imports PROJECT-SYNTAX
    imports BOOL

    rule <runner> O:Operation S:Sequence => O ~> S ... </runner>
         <status> 100 </status> 
    
    //assignment
    rule <runner> I:Id := V:Id => .K ... </runner>
         <enum> ENUM => ENUM [ I <- V ] </enum>
         <status> 100 </status> requires I in_keys( ENUM )

    rule <runner> I:Id := V:Bool => .K ... </runner>
         <boolean> BOOL => BOOL [ I <- V ] </boolean>
         <status> 100 </status> requires I in_keys( BOOL )

    rule <runner> I:Id := V:Int => .K ... </runner>
         <integer> INT => INT [ I <- V ] </integer>
         <status> 100 </status> requires I in_keys( INT )

    //discard assignments to undeclared variables
    rule <runner> I:Id := _:Id => .K ... </runner>
         <enum> ENUM </enum>
         <status> 100 </status> 
         <discard-errors> true </discard-errors> requires notBool ( I in_keys( ENUM ) )

    rule <runner> I:Id := _:Bool => .K ... </runner>
         <boolean> BOOL </boolean>
         <status> 100 </status> 
         <discard-errors> true </discard-errors> requires notBool ( I in_keys( BOOL ) )

    rule <runner> I:Id := _:Int => .K ... </runner>
         <integer> INT </integer>
         <status> 100 </status> 
         <discard-errors> true </discard-errors> requires notBool ( I in_keys( INT ) )
     

    //exit
    //TODO currently this also discards errors, without indicating that it does so
    rule <runner> _ => .K </runner> //nem kell a _ =>
         <return-status> ID:Int => -1 </return-status>
         <status> 100 => ID:Int </status> [priority(1000)]

endmodule

module PROJECT
    imports PROGRAM-LINKING
    imports DECLARATIONS
    imports TRAN-INIT

    //! Important! This will currently enter an infinite loop, krun only with --depth bound!
    // imports TRAN-TRAN
    // imports TRAN-ENV

    imports RUN-TRANSITION
endmodule