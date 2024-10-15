//
//  main.swift
//  Lab_04
//
//  Created by Serguei Diaz on 09.05.2024.
//

import Foundation

let input: [String] = readLineUntilEmpty()
let code: String = input.reduce("") { partialResult, line in
    "\(partialResult)\(line.replacingOccurrences(of: " ", with: ""))"
}

var tree: Tree = Tree(lexer: Lexer(code: code), firstNodeType: .nonTerminal(subType: .programm))

switch tree.getFirstNode() {
case .success(_):
    print("----------------Original Tree----------------")
    print("Original Tree by levels:")
    printArrayOfStrings(tree.toStringByLevels())
    print("")
    print("Original Tree Graph:")
    printArrayOfStrings(tree.toStringGraph())
    
    switch SyntaxDirectTranslator.translate(tree: tree, rulesPairs: RulesPairs()) {
        
    case .success(let newTree):
        print("")
        print("")
        print("----------------Translated Tree----------------")
        print("Translated Tree by levels:")
        printArrayOfStrings(newTree.toStringByLevels())
        print("")
        print("Translated Tree Graph:")
        printArrayOfStrings(newTree.toStringGraph())
    case .failure(let error):
        print(error)
    }
    
case .failure(let failure):
    print(failure)
}


func readLineUntilEmpty() -> [String] {
    var lines: [String] = []
    
    while let line = readLine(), !line.isEmpty {
        lines.append(line)
    }
    
    return lines
}

func printArrayOfStrings(_ array: [String]) {
    array.forEach { element in
        print(element)
    }
}

/*
 <выражение>-><простоевыражение>|<простоевыражение><операцияотношения><простоевыражение>
 <простоевыражение>-><терм><простоевыражение>'|<знак><терм><простоевыражение>'|<терм>|<знак><терм>
 <терм>-><фактор><терм>'|<фактор>
 <фактор>-><идентификатор>|<константа>|(<простоевыражение>)|not<фактор>
 <операцияотношения>->==|<>|<|<=|>|>=
 <знак>->+|-
 <операциятипасложения>->+|-|or
 <операциятипаумножения>->*|/|div|mod|and
 <программа>-><блок>
 <блок>->{<списокоператоров>}
 <списокоператоров>-><оператор><хвост>|<оператор>
 <хвост>->;<оператор><хвост>|;<оператор>
 <оператор>-><идентификатор>=<выражение>|<блок>
 <простоевыражение>'-><операциятипасложения><терм><простоевыражение>'|<операциятипасложения><терм>
 <терм>'-><операциятипаумножения><фактор><терм>'|<операциятипаумножения><фактор>

 test 1:
 {<идентификатор>=<константа>}
 
 test 2:
 {{<идентификатор>=-(<константа>)mod<идентификатор>+not<идентификатор>==<константа>or<идентификатор>};<идентификатор>=<идентификатор>}
 */

