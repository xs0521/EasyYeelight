//
//  YeelightApp.swift
//  Yeelight
//
//  Created by xs0521 on 2023/2/18.
//

import SwiftUI

@main
struct MacOSApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        Settings {
            AnyView(_fromValue: EmptyView())
        }
        
    }
}
