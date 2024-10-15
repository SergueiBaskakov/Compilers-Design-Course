//
//  main.swift
//  Lab_02
//
//  Created by Serguei Diaz on 26.03.2024.
//

import Foundation

let input: [String] = readLineUntilEmpty()
var grammar: Grammar = .init(input.map({ g in
    g.replacingOccurrences(of: " ", with: "")
}))

print("Initial Rigth Linear Grammar:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.removeIndirectCalls()

print("Rigth Linear Grammar Without Indirect Calls:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.removeLeftRecursion()


print("Rigth Linear Grammar Without Left Recursion:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.applyLeftFactorization()


print("Rigth Linear Grammar With Left Factorization:")
printArrayOfStrings(grammar.toStringArray())
print()

grammar.removeInnaccesibleSymbols()


print("Rigth Linear Grammar Without Innaccesible Symbols:")
printArrayOfStrings(grammar.toStringArray())
print()


func readLineUntilEmpty() -> [String] {
    var lines: [String] = []
    
    while let line = readLine(), !line.isEmpty {
        lines.append(line)
        print(line)
    }
    
    return lines
}

func printArrayOfStrings(_ array: [String]) {
    array.forEach { element in
        print(element)
    }
}


/*
E->E+T|T
T->T*F|F
F->(E)|a
 
E->E+T|T
T->T*F|F
F->(E)|id
 
S->iEtS|iEtSeS|a
E->b
 
A->Br
B->Cd|a
C->At
 
 <выражение>-><простоевыражение>|<простоевыражение><операцияотношения><простоевыражение>
 <простоевыражение>-><терм><простоевыражение>'|<знак><терм><простоевыражение>'|<терм>|<знак><терм>
 <терм>-><фактор><терм>'|<фактор>
 <фактор>-><идентификатор>|<константа>|(<простоевыражение>)|not<фактор>
 <операцияотношения>->=|<>|<|<=|>|>=
 <знак>->+|-
 <операциятипасложения>->+|-|or
 <операциятипаумножения>->*|/|div|mod|and
 <программа>-><блок>
 <блок>->{<списокоператоров>}
 <списокоператоров>-><оператор><хвост>|<оператор>
 <хвост>->;<оператор><хвост>|;<оператор>
 <оператор>-><идентификатор>=<выражение>|<блок>
 <идентификатор>->a
 <константа>->b
 */

/*
 declaration->typeDecl|(varDecl)
 identifierList->IDENTIFIER|(IDENTIFIER COMMA identifierList)
 expressionList->expression|(expression COMMA expressionList)
 typeDecl->TYPE typeSpec|(TYPE L_PAREN R_PAREN)|(TYPE L_PAREN typeSpecEos R_PAREN)
 typeSpecEos->typeSpec eos|(typeSpec eos typeSpecEos)
 typeSpec->typeDef
 typeDef->IDENTIFIER typeParameters type_|(IDENTIFIER type_)
 typeParameters->L_BRACKET typeParametersRepetitions R_BRACKET
 typeParametersRepetitions->typeParameterDecl|(typeParameterDecl COMMA typeParametersRepetitions)
 typeParameterDecl->identifierList typeElement
 typeElement->typeTerm|(typeTerm OR typeElement)
 typeTerm->UNDERLYING type_|type_
 functionDecl->FUNC IDENTIFIER signature block|(FUNC IDENTIFIER typeParameters signature)|(FUNC IDENTIFIER signature block)|(FUNC IDENTIFIER typeParameters signature block)
 varDecl->VAR varSpec|(L_PAREN R_PAREN)|(L_PAREN varDeclRepetitions R_PAREN)
 varDeclRepetitions->varSpec eos|(varSpec eos varDeclRepetitions)
 varSpec->identifierList type_|(identifierList type_ ASSIGN expressionList)|(identifierList ASSIGN expressionList)
 block->L_CURLY R_CURLY|(L_CURLY statementList R_CURLY)
 statementList->statement eos|(SEMI statement eos)|(EOS statement eos)|(statement eos statementList)|(SEMI statement eos statementList)|(EOS statement eos statementList)
 statement->declaration|simpleStmt|returnStmt|breakStmt|block|ifStmt|forStmt
 simpleStmt->assignment|expressionStmt
 expressionStmt->expression
 assignment->expressionList assign_op expressionList
 assign_op->ASSIGN
 returnStmt->RETURN|(RETURN expressionList)
 breakStmt->BREAK|(BREAK IDENTIFIER)
 ifStmt->IF expression block|(IF eos expression block)|(IF simpleStmt eos expression block)|(IF expression block ELSE ifStmt)|(IF eos expression block ELSE ifStmt)|(IF simpleStmt eos expression block ELSE ifStmt)|(IF expression block ELSE block)|(IF eos expression block ELSE block)|(IF simpleStmt eos expression block ELSE block)
 typeList->type_|NIL_LIT|(type_ COMMA typeList)|(NIL_LIT COMMA typeList)
 forStmt->FOR block|(FOR expression block)|(FOR forClause block)|(FOR rangeClause block)
 forClause->simpleStmt eos simpleStmt|(simpleStmt eos expression eos simpleStmt)
 rangeClause->RANGE expression|(expressionList ASSIGN RANGE expression)|(identifierList DECLARE_ASSIGN RANGE expression)
 type_->typeName|(typeName typeArgs)|typeLit|(L_PAREN type_ R_PAREN)
 typeArgs->L_BRACKET typeList R_BRACKET|(L_BRACKET typeList COMMA R_BRACKET)
 typeName->qualifiedIdent|IDENTIFIER
 typeLit->arrayType|structType|functionType
 arrayType->L_BRACKET arrayLength R_BRACKET elementType
 arrayLength->expression
 elementType->type_
 functionType->FUNC signature
 signature->parameters|(parameters result)
 result->parameters|type_
 parameters->L_PAREN R_PAREN|(L_PAREN parametersRepetition R_PAREN)|(L_PAREN parametersRepetition COMMA R_PAREN)
 parametersRepetition->parameterDecl|(parameterDecl COMMA parametersRepetition)
 parameterDecl->type_|(identifierList type_)|(ELLIPSIS type_)|(identifierList ELLIPSIS type_)
 expression->primaryExpr|(expressionPrefixOperation expression)|(expression expressionOperation expression)
 expressionOperation->STAR|DIV|MOD|PLUS|MINUS|OR|EQUALS|NOT_EQUALS|LESS|LESS_OR_EQUALS|GREATER|GREATER_OR_EQUALS|LOGICAL_AND|LOGICAL_OR
 expressionPrefixOperation->PLUS|MINUS|EXCLAMATION|STAR
 primaryExpr->operand|conversion|(primaryExpr primaryExprLast)
 primaryExprLast->DOT IDENTIFIER|index|typeAssertion|arguments
 conversion->type_ L_PAREN expression R_PAREN|(type_ L_PAREN expression COMMA R_PAREN)
 operand->literal|operandName|(operandName typeArgs)|(L_PAREN expression R_PAREN)
 literal->basicLit|functionLit
 basicLit->NIL_LIT|integer|string_
 integer->DECIMAL_LIT
 operandName->IDENTIFIER
 qualifiedIdent->IDENTIFIER DOT IDENTIFIER
 literalType->structType|arrayType|(L_BRACKET ELLIPSIS R_BRACKET elementType)|typeName|(typeName typeArgs)
 structType->STRUCT L_CURLY structTypeRepetitions R_CURLY
 structTypeRepetitions->fieldDecl eos|(fieldDecl eos structTypeRepetitions)
 fieldDecl->identifierList type_|embeddedField|(identifierList type_ string_)|(embeddedField string_)
 string_->RAW_STRING_LIT
 embeddedField->typeName|(STAR typeName)|(typeName typeArgs)|(STAR typeName typeArgs)
 functionLit->FUNC signature block
 index->L_BRACKET expression R_BRACKET
 typeAssertion->DOT L_PAREN type_ R_PAREN
 arguments->L_PAREN R_PAREN|(L_PAREN expressionList R_PAREN)|(L_PAREN type_ R_PAREN)|(L_PAREN type_ COMMA expressionList R_PAREN)|(L_PAREN type_ ELLIPSIS R_PAREN)|(L_PAREN type_ COMMA R_PAREN)|(L_PAREN type_ ELLIPSIS COMMA R_PAREN)|(L_PAREN type_ COMMA expressionList ELLIPSIS R_PAREN)|(L_PAREN type_ COMMA expressionList COMMA R_PAREN)|(L_PAREN type_ COMMA expressionList ELLIPSIS COMMA R_PAREN)|(L_PAREN expressionList ELLIPSIS R_PAREN)|(L_PAREN expressionList COMMA R_PAREN)|(L_PAREN expressionList ELLIPSIS COMMA R_PAREN)
 eos->SEMI|eof

 */
