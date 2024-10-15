//
//  Node.swift
//  Lab_04
//
//  Created by Serguei Diaz on 09.05.2024.
//

import Foundation

struct Tree: TreeProtocol {
    private var lexer: LexerProtocol
    internal var firstNode: NodeProtocol? = nil
    private let firstNodeType: NodeType
    
    init(lexer: LexerProtocol, firstNodeType: NodeType) {
        self.lexer = lexer
        self.firstNodeType = firstNodeType
    }
    
    mutating func getFirstNode() -> Result<NodeProtocol, Error> {
        if let node = firstNode {
            return .success(node)
        }
        else {
            switch Parser.parse(type: firstNodeType, lexer: &lexer) {
            case .success(let node):
                let extraCode: String = lexer.getRemainingCode()
                if extraCode.isEmpty {
                    self.firstNode = node
                    return .success(node)
                }
                else {
                    return .failure(TreeError.unexpectedExtraCharacters(characters: extraCode))
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}

struct Node: NodeProtocol {
    let type: NodeType
    
    var childs: [NodeProtocol]
    
    private let id: String
    
    init(type: NodeType, childs: [any NodeProtocol]) {
        self.type = type
        self.childs = childs
        self.id = "Node-\(IdGenerator.shared.getId())"
    }
    
    func getString() -> String {
        switch type {
        case .terminal(let subType):
            return subType.rawValue
        case .nonTerminal(let subType):
            return subType.rawValue
        }
    }
    
    func getId() -> String {
        return self.id
    }
    
    func toStringGraph() -> [String] {
        var typeRawValue: String = ""
        switch type {
        case .terminal(let subType):
            typeRawValue = subType.rawValue
        case .nonTerminal(let subType):
            typeRawValue = subType.rawValue
        }
        
        let childsString: String = childs.reduce("\(id)_\(typeRawValue):") { partialResult, child in
            "\(partialResult) \(child.getId())"
        }
        
        return childs.reduce([childsString]) { partialResult, child in
            var result = partialResult
            result.append(contentsOf: child.toStringGraph())
            
            return result
        }
    }
}

protocol TreeProtocol {
    
    var firstNode: NodeProtocol? { get set }
    
    func toStringByLevels() -> [String]
    
    func toStringGraph() -> [String]
}

extension TreeProtocol {
    func toStringByLevels() -> [String] {
        guard let node = firstNode else { return [] }
        var tempNodes: [NodeProtocol] = []
        tempNodes.append(node)
        
        var response: [String] = []
        
        var level: Int = 1
        
        var continueWhile: Bool = true
        
        while continueWhile {
            continueWhile = tempNodes.contains { node in
                !node.childs.isEmpty
            }
            
            let levelString = tempNodes.reduce("Level \(level):") { partialResult, node in
                "\(partialResult) \(node.getString())"
            }
            
            response.append(levelString)
            
            level = level + 1
            
            tempNodes = tempNodes.reduce([], { partialResult, node in
                var result = partialResult
                if node.childs.isEmpty {
                    result.append(node)
                }
                else {
                    result.append(contentsOf: node.childs)
                }
                return result
            })
            
            
        }
        
        return response
    }
    
    func toStringGraph() -> [String] {
        firstNode?.toStringGraph() ?? []
    }
}

protocol NodeProtocol {
    
    var type: NodeType { get }
    
    var childs: [NodeProtocol] { get set }
    
    func getString() -> String
    
    func getId() -> String
    
    func toStringGraph() -> [String]
    
}

enum TreeError: Error {
    case unexpectedExtraCharacters(characters: String)
    case unknownError
}

struct IdGenerator {

    static var shared: IdGenerator = IdGenerator()

    private var currentId: Int = 0
    
    private init() { }
    
    mutating func getId() -> Int {
        currentId = currentId + 1
        return currentId
    }
    
}

