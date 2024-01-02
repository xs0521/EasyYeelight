//
//  MessageType.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/22.
//

import Foundation

enum MessageType {
    
    case switchOn
    case switchOff
    case bright(value: Int)
    case color(value: Int)
    
    var tag: Int {
        switch self {
        case .switchOn:
            return 10000
        case .switchOff:
            return 10001
        case .bright:
            return 10002
        case .color:
            return 10003
        }
    }
    
    var params: [Any] {
        switch self {
        case .switchOn:
            return ["on", "smooth", 500]
        case .switchOff:
            return ["off", "smooth", 500]
        case .bright(let value):
            return [value, "smooth", 500]
        case .color(let value):
            return [value, 100, "smooth", 500]
        }
    }
    
    var method: String {
        switch self {
        case .switchOn, .switchOff:
            return "set_power"
        case .bright:
            return "set_bright"
        case .color:
            return "set_hsv"
        }
    }
    
}
