//
//  Device.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/22.
//

import Foundation

enum Power: String, Codable {
    case off = "off"
    case on = "on"
}

struct Device: Codable, Identifiable, Hashable {
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
    
    let ct: Int
    let name, cacheControl: String
    var power: Power {
        didSet {
            open = power == .on
        }
    }
    let id, host, model, location: String
    var bright: Float
    var hue: Int
    var port: UInt16
    let date: String
    let colorMode, sat: Int
    let support: String
    let fwVer, rgb: Int
    let server, ext: String
    
    var open: Bool = false
    
    var high: Bool = false

    enum CodingKeys: String, CodingKey {
        case ct, name, port
        case cacheControl = "Cache-Control"
        case power, id, host, model, hue, bright
        case date = "Date"
        case colorMode = "color_mode"
        case sat, support
        case fwVer = "fw_ver"
        case rgb
        case server = "Server"
        case ext = "Ext"
        case location = "Location"
    }
    
    mutating func update() -> Void {
        open = power == .on
    }
}
