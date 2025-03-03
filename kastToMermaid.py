# Escapes:
# ( to < 
# ) to >
# { to <<
# } to >>
# " to ″
# ` to ´

data = ""# = """`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(#token("1","Int"),`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(#token("1","Int"),#token("3","Int"))),`_+__LESSON-13-B-SYNTAX_Exp_Exp_Exp`(#token("9","Int"),#token("1","Int")))"""

import re
import sys

input = data
if (len(sys.argv) > 1):
  input = sys.argv[1]

statements = re.findall(r'`.+?`', input)
statements = [[statement, "STNT_" + str(i)] for i, statement in enumerate(statements)]
for statement in statements:
   input = input.replace(statement[0], statement[1], 1)

tokens = re.findall(r'(#token\(".+?",".+?"\))', input)
tokens = [[token, "TKN_" + str(i)] for i, token in enumerate(tokens)]
for token in tokens:
   input = input.replace(token[0], token[1], 1)

output = input

output = output.replace("(", "_SPLIT_(_SPLIT_")
output = output.replace(",", "_SPLIT_,_SPLIT_")
output = output.replace(")", "_SPLIT_)_SPLIT_")
output = output.split("_SPLIT_")

output = list(filter(None, output))

def isSTNT(stn):
  if stn[0:4] == "STNT": 
    return True

def isTKN(stn):
  if stn[0:3] == "TKN": 
    return True

def buildAst(input, ast):
  output = input
  state = 'a'
  counter = 0
  for elem in output:
    if isSTNT(elem): continue
    if isTKN(elem): continue
    
    if elem == '(' and state == 'a':
      state = 'b'
      counter = output.index(elem)
      continue

    if elem == '(' and state == 'b':
      counter = output.index(elem, counter + 1)
      continue

    if elem == ')' and state == 'b':
      state = 'c'
      cur = output.index(elem)

      name = output[counter - 1]
      body = [output[counter+1],output[cur-1]]
      ast.append([name, body])
      
      outputNew = output[0:counter]
      outputNew += output[cur+1:]
      output = outputNew
      continue
      
  if (len(output) > 1): 
    output = buildAst(output, ast)
  return output

# print(output)
ast = []
log = buildAst(output, ast)
# print(log)
# print(ast)
# print()

keys = statements + tokens

print("```mermaid")
print("graph TD")
for key in keys:
  print("\t" + key[1] + "[" + key[0].replace("(", "<").replace(")", ">").replace("\"", "″").replace('`', "´").replace("{", "<<").replace("}", ">>") + "]")

# print()
for elem in ast:
  for astElem in elem[1]:
    print("\t" + elem[0] + " --> " + astElem)
print("```")