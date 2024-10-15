//
//  Lexer.swift
//  Lab_03
//
//  Created by Serguei Diaz on 06.05.2024.
//

import Foundation

struct Lexer: LexerProtocol {
    
    private let code: String
    
    private let codeLength: Int
        
    private var pos: Int
    
    private let terminalsSorted = Terminal.allCases.sorted(by: { $0.rawValue.count > $1.rawValue.count })
    
    private var cachedGet: Terminal? = nil
        
    init(code: String) {
        self.code = code
        self.codeLength = code.count
        self.pos = 0
    }
    
    mutating func get() -> Result<Terminal, any Error> {
        if let terminal = cachedGet {
            return .success(terminal)
        }
        else if pos >= codeLength {
            return .failure(LexerErrors.endOfInput(pos: pos))
        }
        for terminal in terminalsSorted {
            let terminalRawValue: String = terminal.rawValue
            let terminalLength: Int = terminalRawValue.count
            
            let endPos: Int = pos + terminalLength - 1
            
            if endPos < codeLength {
                let subString = String(code[code.index(code.startIndex, offsetBy: pos)...code.index(code.startIndex, offsetBy: endPos)])
                
                if terminalRawValue == subString {
                    cachedGet = terminal
                    return .success(terminal)
                }
            }
        }
        
        let currentChar = String(code[code.index(code.startIndex, offsetBy: pos)])
        return .failure(LexerErrors.unexpectedCharacter(character: currentChar))
    }
    
    mutating func next() {
        if let terminal = cachedGet {
            pos = pos + terminal.rawValue.count
            cachedGet = nil
        }
    }
    
    func getRemainingCode() -> String {
        pos == codeLength ? "" : String(code[code.index(code.startIndex, offsetBy: pos)...code.index(code.startIndex, offsetBy: codeLength - 1)])
    }
}

protocol LexerProtocol {
            
    mutating func get() -> Result<Terminal, Error>
        
    mutating func next()
    
    func getRemainingCode() -> String
    
}

enum LexerErrors: Error {
    case unexpectedCharacter(character: String)
    case endOfInput(pos: Int)
}
