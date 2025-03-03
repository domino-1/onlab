module LESSON-02-PRACTICE

    syntax Boolean ::= True() | False()
    syntax Boolean ::= isSame(Color, Color) [function]
    syntax Boolean ::= outfitMatching(Outfit) [function]

    syntax Boolean ::= and(Boolean, Boolean) [function]
    rule and(True(), True()) => True()
    rule and(True(), False()) => False()
    rule and(False(), True()) => False()
    rule and(False(), False()) => False()

    rule isSame(Black(), Black()) => True()
    rule isSame(White(), White()) => True()
    rule isSame(Black(), White()) => False()
    rule isSame(White(), Black()) => False()

    syntax Color ::= Black() | White()
    syntax Color ::= colorOf(Hat) [function]
                   | colorOf(Shirt) [function]
                   | colorOf(Pants) [function]
                   | colorOf(Shoes) [function]  
                    //1 colorOf(Clothing) [function]
                //0    | colorOf(Shirt) [function]
                //0    | colorOf(Pants) [function]
                //0    | colorOf(Shoes) [function] 

    rule colorOf(Hat(C)) => C
    rule colorOf(Shirt(C)) => C
    rule colorOf(Shoes(C)) => C
    rule colorOf(Pants(C)) => C

    //1 syntax Clothing ::= Hat(Color) | Shirt(Color) | Pants(Color) | Shoes(Color)
    syntax Hat ::= Hat(Color)
    syntax Shirt ::= Shirt(Color)
    syntax Pants ::= Pants(Color)
    syntax Shoes ::= Shoes(Color)

    rule outfitMatching(Outfit(HAT, SHIRT, PANTS, SHOES)) => 
        and(
            and(
                isSame(colorOf(HAT), colorOf(SHIRT)), 
                isSame(colorOf(HAT), colorOf(PANTS))
                ), 
            isSame(colorOf(HAT), colorOf(SHOES)
            )
        ) 
        //C I think this much is enough? Do I need to cross check SHIRT == PANTS, SHIRT == SHOES and PANTS == SHOES?
    
    //0 syntax Hat ::= Clothing(Color)
    //0 syntax Shirt ::= Clothing(Color)
    //0 syntax Pants ::= Clothing(Color)
    //0 syntax Shoes ::= Clothing(Color)
    //C How can I requite the four types of clothing to be different?
    //1 syntax Outfit ::= Outfit(Clothing, Clothing, Clothing, Clothing) 
    syntax Outfit ::= Outfit(Hat, Shirt, Pants, Shoes)

endmodule