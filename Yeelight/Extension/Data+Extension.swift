//
//  Data+Extension.swift
//  Yeelight
//
//  Created by xs0521 on 2023/10/21.
//

import Foundation

extension Data {
    
    func toDictionary() ->Dictionary<String, Any>?{
        do{
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let dic = json as! Dictionary<String, Any>
            return dic

        }catch (let error) {
            print("toDictionary fail \(error)")
            return nil
        }
    }
}
