//
//  Parser.swift
//  Lab_04
//
//  Created by Serguei Diaz on 09.05.2024.
//

import Foundation

struct Parser: ParserProtocol {
    static func parse(type: NodeType, lexer: inout LexerProtocol) -> Result<NodeProtocol, Error> {
        switch type {
        case .terminal(let subType):
            switch lexer.get() {
            case let .success(terminal):
                if subType == terminal {
                    lexer.next()
                    return .success(Node(type: type, childs: []))
                }
                else {
                    return .failure(ParserErrors.invalidTerminal(found: terminal, expected: subType))
                }
            case let .failure(error):
                return .failure(error)
            }
        case .nonTerminal(let subType):
            let rules = Rules.getRule(subType).sorted { a, b in
                a.count > b.count
            }
            
            var parseError: Error? = nil
            
            for rule in rules {
                var childs: [NodeProtocol] = []
                parseError = nil
                var lexerCopy = lexer
                for t in rule {
                    switch Parser.parse(type: t, lexer: &lexerCopy) {
                        case let .success(node):
                            childs.append(node)
                        case let .failure(error):
                            parseError = error
                    }
                    
                    if parseError != nil {
                        break
                    }
                }
                
                if parseError == nil {
                    lexer = lexerCopy
                    return .success(Node(type: type, childs: childs))
                }
            }
            
            return .failure(parseError ?? ParserErrors.unknownError)
            
        }
    }
}

protocol ParserProtocol {
    static func parse(type: NodeType, lexer: inout LexerProtocol) -> Result<NodeProtocol, Error>
}

enum ParserErrors: Error {
    case invalidTerminal(found: Terminal, expected: Terminal)
    case unknownError
}

struct Rules {
    static func getRule(_ nonTerminal: NonTerminal) -> [[NodeType]] {
        switch nonTerminal {
        case .expression: //<простоевыражение>|<простоевыражение><операцияотношения><простоевыражение>
            return [
                [.nonTerminal(subType: .simpleExpression)],
                [.nonTerminal(subType: .simpleExpression), .nonTerminal(subType: .relationshipOperation), .nonTerminal(subType: .simpleExpression)]
            ]
        case .simpleExpression: //<терм><простоевыражение>'|<знак><терм><простоевыражение>'|<терм>|<знак><терм>
            return [
                [.nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)],
                [.nonTerminal(subType: .sign), .nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)],
                [.nonTerminal(subType: .term)],
                [.nonTerminal(subType: .sign), .nonTerminal(subType: .term)]
            ]
        case .term: //<фактор><терм>'|<фактор>
            return [
                [.nonTerminal(subType: .factor), .nonTerminal(subType: .termD)],
                [.nonTerminal(subType: .factor)]
            ]
        case .factor:
            return [
                [.terminal(subType: .identifier)],
                [.terminal(subType: .constant)],
                [.terminal(subType: .parentesisOpen), .nonTerminal(subType: .simpleExpression), .terminal(subType: .parentesisClose)],
                [.terminal(subType: .not), .nonTerminal(subType: .factor)]
            ]
        case .relationshipOperation: //==|<>|<|<=|>|>=
            return [
                [.terminal(subType: .equal)],
                [.terminal(subType: .notEqual)],
                [.terminal(subType: .less)],
                [.terminal(subType: .lessOrEqual)],
                [.terminal(subType: .more)],
                [.terminal(subType: .moreOrEqual)]
            ]
        case .sign: //+|-
            return [
                [.terminal(subType: .plus)],
                [.terminal(subType: .minus)]
            ]
        case .additionTypeOperation: //+|-|or
            return [
                [.terminal(subType: .plus)],
                [.terminal(subType: .minus)],
                [.terminal(subType: .or)]
            ]
        case .multiplicationTypeOperation: //*|/|div|mod|and
            return [
                [.terminal(subType: .multiplication)],
                [.terminal(subType: .division)],
                [.terminal(subType: .quotient)],
                [.terminal(subType: .remainder)],
                [.terminal(subType: .and)]
            ]
        case .programm: //<блок>
            return [
                [.nonTerminal(subType: .block)]
            ]
        case .block: //{<списокоператоров>}
            return [
                [.terminal(subType: .bracketOpen), .nonTerminal(subType: .operatorsList), .terminal(subType: .bracketClose)]
            ]
        case .operatorsList: //<оператор><хвост>|<оператор>
            return [
                [.nonTerminal(subType: .operato), .nonTerminal(subType: .tail)],
                [.nonTerminal(subType: .operato)]
            ]
        case .tail: //;<оператор><хвост>|;<оператор>
            return [
                [.terminal(subType: .semicolon), .nonTerminal(subType: .operato), .nonTerminal(subType: .tail)],
                [.terminal(subType: .semicolon), .nonTerminal(subType: .operato)]
            ]
        case .operato: //<идентификатор>=<выражение>|<блок>
            return [
                [.terminal(subType: .identifier), .terminal(subType: .assign), .nonTerminal(subType: .expression)],
                [.nonTerminal(subType: .block)]
            ]
        case .simpleExpressionD: //<операциятипасложения><терм><простоевыражение>'|<операциятипасложения><терм>
            return [
                [.nonTerminal(subType: .additionTypeOperation), .nonTerminal(subType: .term), .nonTerminal(subType: .simpleExpressionD)],
                [.nonTerminal(subType: .additionTypeOperation), .nonTerminal(subType: .term)]
            ]
        case .termD: //<операциятипаумножения><фактор><терм>'|<операциятипаумножения><фактор>
            return [
                [.nonTerminal(subType: .multiplicationTypeOperation), .nonTerminal(subType: .factor), .nonTerminal(subType: .termD)],
                [.nonTerminal(subType: .multiplicationTypeOperation), .nonTerminal(subType: .factor)]
            ]
        }
    }
}
