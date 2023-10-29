//
//  Dictionary+Extension.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/21.
//

import Foundation

extension Dictionary {
    
    func toData() -> Data? {
        
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("is not a valid json object")
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        return data
    }
}
