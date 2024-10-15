//
//  Enum.swift
//  Lab_04
//
//  Created by Serguei Diaz on 09.05.2024.
//

import Foundation

enum NodeType: Equatable {
    case terminal(subType: Terminal)
    case nonTerminal(subType: NonTerminal)
}

enum NonTerminal: String {
    case expression = "<выражение>" //выражение
    case simpleExpression = "<простое выражение>" //простое выражение
    case term = "<терм>" //терм
    case factor = "<фактор>" //фактор
    case relationshipOperation = "<операция отношения>" //операция отношения
    case sign = "<знак>" //знак
    case additionTypeOperation = "<операция типа сложения>" //операция типа сложения
    case multiplicationTypeOperation = "<операция типа умножения>" //операция типа умножения
    case programm = "<программа>" //программа
    case block = "<блок>" //блок
    case operatorsList = "<список операторов>" //список операторов
    case tail = "<хвост>" //хвост
    case operato = "<оператор>" //оператор
    case simpleExpressionD = "<простое выражение>'" //простое выражениеD
    case termD = "<терм>'" //термD
}

enum Terminal: String, CaseIterable {
    case parentesisOpen = "("
    case parentesisClose = ")"
    case bracketOpen = "{"
    case bracketClose = "}"
    case not = "not"
    case or = "or"
    case and = "and"
    case equal = "=="
    case assign = "="
    case notEqual = "<>"
    case more = ">"
    case less = "<"
    case lessOrEqual = "<="
    case moreOrEqual = ">="
    case plus = "+"
    case minus = "-"
    case multiplication = "*"
    case division = "/"
    case quotient = "div"
    case remainder = "mod"
    case semicolon = ";"
    case identifier = "<идентификатор>"
    case constant = "<константа>"
}
