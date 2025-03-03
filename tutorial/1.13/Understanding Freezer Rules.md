# Understandig freezer rules

Based on `lesson-13-b.k` and `intPlusInt.test`.

We are trying to run the following:

```
1 + (1 + 3) + (9 + 1)
```

If we've done everything corrently, be the end we should get `15` as the result.


Our K code is the following:
*This is a version of `lesson-13-b.k` with only the INT cases*


## The syntax module:

```{.K .base}
module LESSON-13-B-SYNTAX
  imports UNSIGNED-INT-SYNTAX

  syntax Val ::= Int
  syntax Exp ::= Val
               | "(" Exp ")" [bracket]
               > left: Exp "+" Exp
endmodule
```


## The semantics module:

```{.K .base}
module LESSON-13-B
  imports LESSON-13-B-SYNTAX
  imports INT

  syntax KItem ::= freezer1(Val) | freezer2(Exp)
```

Using this, we can already parse `intPlusInt.test`, but we cannot yet run it and get a result:

> Run `kompile "Understanding Freezer Rules.md" --main-module "LESSON-13-B" --md-selector "k | base"` to kompile.
> 
> Then, run `kast "intPlusInt.test" --definition "Understanding Freezer Rules-kompiled"` to get the following AST:
 
```AST
`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`
(
	`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`
	(
		#token("1","Int"),
		`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`
		(
			#token("1","Int"),
			#token("3","Int")
		)
	),
	`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`
	(
		#token("9","Int"),
		#token("1","Int")
	)
)
```

But at this point, we don't have any rules in place yet, we've 
only been able to get an AST. If we run it, at this point, this 
 what we're going to get:

> Running `krun "intPlusInt.test" --definition "Understanding Freezer Rules-kompiled"`, you'll get the following:

```
<k>
  1 + ( 1 + 3 ) + ( 9 + 1 ) ~> .K
</k>
```


## Adding some rules


### Integer addition

```{.K .rules-1}
rule <k> I1:Int + I2:Int ~> K:K </k> => <k> I1 +Int I2 ~> K </k>
```

By itself, this rule won't do anything yet. You can try 
by compiling using the following and running the program again:

> Run `kompile "Understanding Freezer Rules.md" --main-module "LESSON-13-B" --syntax-module "LESSON-13-B-SYNTAX"  --md-selector "k | base | rules-1"`

Using this, running `intPlustInt.test` will have the same results 
as before. However, thats not to say that nothing changed! If you
run it with something simpler, it can work.

> As an example, try running one of these:
> - `krun -cPGM="1 + 4" --definition "Understanding Freezer Rules-kompiled"`
> 
> This will have the following output:
> ```
> <k>
>   5 ~> .K
> </k>
> ```
> 
> - `krun -cPGM="1 + 4 + 5" --definition "Understanding Freezer Rules-kompiled"`
>
> Meanwhile, this will have the following:
> 
> ```
> <k>
>   1 + 4 + 5 ~> .K
> </k>
> ```
> As can be seen, this simple rules for adding two ints only works in the most basic of cases.


### Sum of two expressions

```{.K .rules-2}
rule <k> E1:Exp + E2:Exp ~> K:K </k> => <k> E1 ~> freezer2(E2) ~> K </k> [priority(52)]
```

Compile using the following:
> Run `kompile "Understanding Freezer Rules.md" --main-module "LESSON-13-B" --syntax-module "LESSON-13-B-SYNTAX" --md-selector "k | base | rules-1 | rules-2"`

Then, running for `intPlusInt.test` gets you the following result:
```
<k>
  1 ~> freezer2 ( 1 + 3 ) ~> freezer2 ( 9 + 1 ) ~> .K
</k>
```

We can understand what's happening here by breaking it down into steps. The only rule that has an effect here is the one in the 'rules-2' block. (If you want, you can test it by kompiling without the 'rules-1' block included.)

This rule says, that if the program encounters the sum of two expressions, it should rewrite that to the chain of the first expression followed by the second expression in freezer2.

Step-by step:
* **`1 + (1 + 3) + (9 + 1) ~> .K`**               <br>
    E1:Exp = "1 + (1 + 3)"                        <br>
    E2:Exp = "(9 + 1)"                            <br>
    K:K    = "~> .K"
* **`1 + (1 + 3) ~> freezer2( 9 + 1 ) ~> .K`**    <br>
    E1:Exp = "1"                                  <br>
    E2:Exp = "(1 + 3)"                            <br>
    K:K    = "~> freezer2( 9 + 1 ) ~> .K"
* **`1 ~> freezer2( 1 + 3 ) ~> freezer2( 9 + 1 ) ~> .K`**

At this point, we no longer have two expressions present, only one, so the rule has nothing more to do.

<!-- Note: Add example for -cPGM="1 + 4 + 5". That one does have a difference between having rules-1 active or not. --> 


### Sum of a value and an expression

At the end of the previous step, we got to a form where we had a single expression that was only a single value (an integer) followed by two freezers, both of which contained an expression (the sums of two integers).

```{.K .rules-3}
rule <k> E1:Val + E2:Exp ~> K:K </k> => <k> E2 ~> freezer1(E1) ~> K </k> [priority(51)]
```

Running this, you'll find that it only did something with the first half of the original expression:

```
<k>
  4 ~> freezer1 ( 1 ) ~> freezer2 ( 9 + 1 ) ~> .K
</k>
```

In that half, it "unwrapped" the 1 + 3 inside the freezer, and instead "wrapped" the single 1. At this point, the first rule we had (sum of two integers) could apply to sum up 1 + 3 into 4. You can see this in more steps by kompiling & running this with only rules 2 and 3 active.

This results in the following:
```
<k>
  3 ~> freezer1 ( 1 ) ~> freezer1 ( 1 ) ~> freezer2 ( 9 + 1 ) ~> .K
</k>
```

This may look weird, and it is. This is not a straight-up transitional step, because by turning off rule 1 completely, we got a different result. This is where rule priority becomes important. Lets look at it step-by-step:

1 ~> freezer2(1 + 3) ~> freezer2(9 + 1) ~> .K   <br>
E1:Val = 1                                      <br>
E2:Exp = 1 + 3                                  <br>
K:K = ~> freezer2(9 + 1) ~> .K                  <br>

1 + 3 ~> freezer1(1) ~> freezer2(9 + 1) ~> .K   <br>

Up to here, we are good. However, this is where rule priority comes into play. If we don't have rule 1 active, then this will see that there is something it can apply rule 3 to, and do that. (The reason it doesn't apply rule 2 instead is priority again. You'll notice that rule 2 has a higher priority then 3, meaning 3 gets tried first.) You can see that if we continue, we would end up with `3 ~> freezer1 ( 1 ) ~> freezer1 ( 1 ) ~> freezer2 ( 9 + 1 ) ~> .K`

But if we do have rule 1 active, since that has an implicit priority of 50, lower then both rules 2 and 3, that will apply and sum up 1 + 3 into 4, which will get us back to our initial result.


### From freezers to results

The final two rules we apply are the following:
```{.K .rules-4}
rule <k> E2:Val ~> freezer1(E1) ~> K:K </k> => <k> E1 + E2 ~> K </k>
```
```{.K .rules-5}
rule <k> E1:Val ~> freezer2(E2) ~> K:K </k> => <k> E1 + E2 ~> K </k>
```

Lets look at what they do individually:

In the case of rule 4, the following happens:
Since this rule applies to freezer1, we know that its input must have come from rule 3. That means that whatever is in freezer1 (our E1) is not only an expression, but it also must be a single value.
Since in the input, we case E1 to Val, we also know that that too is a single value. That means that we can rewrite it to E1 + E2 in the knowledge that the two expressions are both values. This will then activate rule 1, which will sum up the two expressions into their sum.

In the case of rule 5, we know that its input must come from rule 2 because of freezer2 being present. We also know that E1 must be a value because of the cast. (Unless it is a value, the rule would not activate. Which combined with the rule's priority of 50, means that what happens is rule 2 and 3 doing rewrites until we get to E1 being a single value.) At which point, we can rewrite into a sum, which we know rule 1 can take.

At this point, if we try to compile without rule 1, we can quickly run into an infinite loop. (The addition of two expressions results in Exp + Freezer2 due to rule 2, which results in Exp + Exp due to rule 5, which results in Exp + Freezer2 due to rule 2 etc. etc.) 

## Results

Combining all 5 rules, we can see what K does step-by-step using the `--depth N` switch in `krun`. We can get to 15 in 10 steps.
As a shorthand, instead of compiling using `k | base | rules-1 | rules-2 | rules-3 | rules-4 | rules-5` you can compile using `k | K`.

<!-- We cannot use only lowercase k because /include/builtin/domains.md uses that for its own code blocks. If every block had "k" instead of "K", we couldn't compile only with some steps included. 
Eg. if we had "k" everywhere we have "K" right now, "k & base" would exclude the built in INT-SYNTAX. The only way to include the domains.md bits is to have "k | " in every markdown selector without any other qualifiers. (Or a convoluted method where every block in this file gets a selector such as "steps", at which point we can do "k & (!steps) | base" -->

## Addendum

Closing the module:

```{.K .base}
endmodule
```