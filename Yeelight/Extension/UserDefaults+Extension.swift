//
//  UserDefaults+Extension.swift
//  Yeelight
//
//  Created by xs0521 on 2023/2/19.
//

import Foundation

extension UserDefaults {
    
    static func set(_ value: Any?, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        UserDefaults.standard.synchronize()
    }
}
