//
//  SyntaxDirectTranslator.swift
//  Lab_04
//
//  Created by Serguei Diaz on 09.05.2024.
//

import Foundation

struct SyntaxDirectTranslator {
    
    static func translate(tree: TreeProtocol, rulesPairs: RulesPairs) -> Result<TreeProtocol, Error> {
        
        guard var node = tree.firstNode else { return .failure(TranslatorError.emptytree) }
        
        switch node.translate(rulesPairs: rulesPairs) {
        case .success(let success):
            return .success(BasicTree(firstNode: success))
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
}

struct BasicTree: TreeProtocol {
    var firstNode: (any NodeProtocol)?
    
    init(firstNode: (any NodeProtocol)?) {
        self.firstNode = firstNode
    }
}

extension NodeProtocol {
    
    mutating func translate(rulesPairs: RulesPairs) -> Result<NodeProtocol, Error> {
        switch type {
        case .terminal(subType: _):
            break
        case .nonTerminal(subType: let subType):
            var error: Error? = nil
            self.childs = childs.map({ node in
                var newNode = node
                
                switch newNode.translate(rulesPairs: rulesPairs) {
                    
                case .success(let n):
                    return n
                case .failure(let errorResponse):
                    error = errorResponse
                    return node
                }
            })
            
            if error != nil {
                return .failure(error ?? TranslatorError.unknownError)
            }
                        
            let rulePairs = rulesPairs.getRulePair(subType).sorted { a, b in
                a.0.count > b.0.count
            }
            
            var currentPair: ([NodeType], [NodeType])? = nil
            
            for r in rulePairs {
                if r.0.count == childs.count {
                    currentPair = r
                    for i in childs.indices {
                        if childs[i].type != r.0[i] {
                            currentPair = nil
                            break
                        }
                    }
                }
                
                if currentPair != nil {
                    break
                }
            }
            
            var newChilds: [NodeProtocol] = []
            
            guard let pair = currentPair else { return .failure(TranslatorError.wrongPair(inNodeType: self.type)) }
            
            for t in pair.1 {
                guard let node = self.popChild(type: t) else { return .failure(TranslatorError.wrongPair(inNodeType: self.type)) }
                
                newChilds.append(node)
            }
            self.childs = newChilds
            
        }
        
        return .success(self)
    }
    
    mutating private func popChild(type: NodeType) -> NodeProtocol? {
        guard let index = childs.firstIndex(where: { n in
            n.type == type
        }) else { return nil }
        
        return childs.remove(at: index)
    }
}

enum TranslatorError: Error {
    case unknownError
    case emptytree
    case wrongPair(inNodeType: NodeType)
}

struct RulesPairs {
    func getRulePair(_ nonTerminal: NonTerminal) -> [([NodeType], [NodeType])] {
        switch nonTerminal {
        case .expression: //<простоевыражение>    ,   <простоевыражение> | <простоевыражение><операцияотношения><простоевыражение>    ,   <простоевыражение><простоевыражение><операцияотношения>
            return [
                ([.nonTerminal(subType: .simpleExpression)], [.nonTerminal(subType: .simpleExpression)]),
                ([.nonTerminal(subType: .simpleExpression), .nonTerminal(subType: .relationshipOperation), .nonTerminal(subType: .simpleExpression)], [.nonTerminal(subType: .simpleExpression), .nonTerminal(subType: .simpleExpression), .nonTerminal(subType: .relationshipOperation)])
            ]
        case .simpleExpression: //<терм><простоевыражение>'|<знак><терм><простоевыражение>'  ,   <терм><знак><простоевыражение>' |<терм>|<знак><терм>    ,   <терм><знак>
            return [
                ([.nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)], [.nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)]),
                ([.nonTerminal(subType: .sign), .nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)], [.nonTerminal(subType: .term), .nonTerminal(subType: .sign), .nonTerminal(subType: .simpleExpressionD)]),
                ([.nonTerminal(subType: .term)], [.nonTerminal(subType: .term)]),
                ([.nonTerminal(subType: .sign), .nonTerminal(subType: .term)], [.nonTerminal(subType: .term), .nonTerminal(subType: .sign)])
            ]
        case .term: //<фактор><терм>'|<фактор>
            return [
                ([.nonTerminal(subType: .factor), .nonTerminal(subType: .termD)], [.nonTerminal(subType: .factor), .nonTerminal(subType: .termD)]),
                ([.nonTerminal(subType: .factor)], [.nonTerminal(subType: .factor)])
            ]
        case .factor: //<идентификатор>|<константа>|(<простоевыражение>)|not<фактор> ,   <фактор>not
            return [
                ([.terminal(subType: .identifier)], [.terminal(subType: .identifier)]),
                ([.terminal(subType: .constant)], [.terminal(subType: .constant)]),
                ([.terminal(subType: .parentesisOpen), .nonTerminal(subType: .simpleExpression), .terminal(subType: .parentesisClose)], [.terminal(subType: .parentesisOpen), .nonTerminal(subType: .simpleExpression), .terminal(subType: .parentesisClose)]),
                ([.terminal(subType: .not), .nonTerminal(subType: .factor)], [.nonTerminal(subType: .factor), .terminal(subType: .not)])
            ]
        case .relationshipOperation: //==|<>|<|<=|>|>=
            return [
                ([.terminal(subType: .equal)], [.terminal(subType: .equal)]),
                ([.terminal(subType: .notEqual)], [.terminal(subType: .notEqual)]),
                ([.terminal(subType: .less)], [.terminal(subType: .less)]),
                ([.terminal(subType: .lessOrEqual)], [.terminal(subType: .lessOrEqual)]),
                ([.terminal(subType: .more)], [.terminal(subType: .more)]),
                ([.terminal(subType: .moreOrEqual)], [.terminal(subType: .moreOrEqual)])
            ]
        case .sign: //+|-
            return [
                ([.terminal(subType: .plus)], [.terminal(subType: .plus)]),
                ([.terminal(subType: .minus)], [.terminal(subType: .minus)])
            ]
        case .additionTypeOperation: //+|-|or
            return [
                ([.terminal(subType: .plus)], [.terminal(subType: .plus)]),
                ([.terminal(subType: .minus)], [.terminal(subType: .minus)]),
                ([.terminal(subType: .or)], [.terminal(subType: .or)])
            ]
        case .multiplicationTypeOperation: //*|/|div|mod|and
            return [
                ([.terminal(subType: .multiplication)], [.terminal(subType: .multiplication)]),
                ([.terminal(subType: .division)], [.terminal(subType: .division)]),
                ([.terminal(subType: .quotient)], [.terminal(subType: .quotient)]),
                ([.terminal(subType: .remainder)], [.terminal(subType: .remainder)]),
                ([.terminal(subType: .and)], [.terminal(subType: .and)])
            ]
        case .programm: //<блок>
            return [
                ([.nonTerminal(subType: .block)], [.nonTerminal(subType: .block)])
            ]
        case .block: //{<списокоператоров>}
            return [
                ([.terminal(subType: .bracketOpen), .nonTerminal(subType: .operatorsList), .terminal(subType: .bracketClose)], [.terminal(subType: .bracketOpen), .nonTerminal(subType: .operatorsList), .terminal(subType: .bracketClose)])
            ]
        case .operatorsList: //<оператор><хвост>|<оператор>
            return [
                ([.nonTerminal(subType: .operato), .nonTerminal(subType: .tail)], [.nonTerminal(subType: .operato), .nonTerminal(subType: .tail)]),
                ([.nonTerminal(subType: .operato)], [.nonTerminal(subType: .operato)])
            ]
        case .tail: //;<оператор><хвост>|;<оператор>
            return [
                ([.terminal(subType: .semicolon), .nonTerminal(subType: .operato), .nonTerminal(subType: .tail)], [.terminal(subType: .semicolon), .nonTerminal(subType: .operato), .nonTerminal(subType: .tail)]),
                ([.terminal(subType: .semicolon), .nonTerminal(subType: .operato)], [.terminal(subType: .semicolon), .nonTerminal(subType: .operato)])
            ]
        case .operato: //<идентификатор>=<выражение>    ,   <идентификатор><выражение>= | <блок> ,  <блок>
            return [
                ([.terminal(subType: .identifier), .terminal(subType: .assign), .nonTerminal(subType: .expression)], [.terminal(subType: .identifier), .nonTerminal(subType: .expression), .terminal(subType: .assign)]),
                ([.nonTerminal(subType: .block)], [.nonTerminal(subType: .block)])
            ]
        case .simpleExpressionD: //<операциятипасложения><терм><простоевыражение>'  ,   <терм><операциятипасложения><простоевыражение>' | <операциятипасложения><терм>  ,   <терм><операциятипасложения>
            return [
                ([.nonTerminal(subType: .additionTypeOperation), .nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)], [.nonTerminal(subType: .term), .nonTerminal(subType: .additionTypeOperation), .nonTerminal(subType: .simpleExpressionD)]),
                ([.nonTerminal(subType: .additionTypeOperation), .nonTerminal(subType: .term)], [.nonTerminal(subType: .term), .nonTerminal(subType: .additionTypeOperation)])
            ]
        case .termD: //<операциятипаумножения><фактор><терм>'    ,   <фактор><операциятипаумножения><терм>' | <операциятипаумножения><фактор>    ,   <фактор><операциятипаумножения>
            return [
                ([.nonTerminal(subType: .multiplicationTypeOperation), .nonTerminal(subType: .factor), .nonTerminal(subType: .termD)], [.nonTerminal(subType: .factor), .nonTerminal(subType: .multiplicationTypeOperation), .nonTerminal(subType: .termD)]),
                ([.nonTerminal(subType: .multiplicationTypeOperation), .nonTerminal(subType: .factor)], [.nonTerminal(subType: .factor), .nonTerminal(subType: .multiplicationTypeOperation)])
            ]
        }
    }
}

/*
 <выражение>-> <простоевыражение>    ,   <простоевыражение> | <простоевыражение><операцияотношения><простоевыражение>    ,   <простоевыражение><простоевыражение><операцияотношения>
 <простоевыражение>-><терм><простоевыражение>'|<знак><терм><простоевыражение>'  ,   <терм><знак><простоевыражение>' |<терм>|<знак><терм>    ,   <терм><знак>
 <терм>-><фактор><терм>'|<фактор>
 <фактор>-><идентификатор>|<константа>|(<простоевыражение>)|not<фактор> ,   <фактор>not
 <операцияотношения>->==|<>|<|<=|>|>=
 <знак>->+|-
 <операциятипасложения>->+|-|or
 <операциятипаумножения>->*|/|div|mod|and
 <программа>-><блок>
 <блок>->{<списокоператоров>}
 <списокоператоров>-><оператор><хвост>|<оператор>
 <хвост>->;<оператор><хвост>|;<оператор>
 <оператор>-><идентификатор>=<выражение>    ,   <идентификатор><выражение>= | <блок> ,  <блок>
 <простоевыражение>'-> <операциятипасложения><терм><простоевыражение>'  ,   <терм><операциятипасложения><простоевыражение>' | <операциятипасложения><терм>  ,   <терм><операциятипасложения>
 <терм>'-><операциятипаумножения><фактор><терм>'    ,   <фактор><операциятипаумножения><терм>' | <операциятипаумножения><фактор>    ,   <фактор><операциятипаумножения>
 */
