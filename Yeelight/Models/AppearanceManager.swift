//
//  AppearanceManager.swift
//  Yeelight
//
//  Created by xs0521 on 2024/12/3.
//

import Foundation
import SwiftUI

class AppearanceManager: ObservableObject {
    
    @Published var colorScheme: ColorScheme = .light
    
    static let shared = AppearanceManager()
    
    var updateColorSchemeCallBack: GeneralCallBack<ColorScheme>?
    

    init() {
        DistributedNotificationCenter.default.addObserver(
                self,
                selector: #selector(systemAppearanceChanged),
                name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
                object: nil
            )
    }

    @objc private func systemAppearanceChanged() {
        updateColorScheme()
        updateColorSchemeCallBack?(colorScheme)
    }

    func updateColorScheme() {
        if let appearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
            colorScheme = (appearance == .darkAqua ? .dark : .light)
        }
    }
    
    func popBackgroundColor() -> NSColor? {
        colorScheme == .dark ? NSColor.init(hex: "323232") : NSColor.init(hex: "EBEBEA")
    }
    
    func colorPickBackgroundColor() -> Color? {
        colorScheme == .dark ? Color.init(hex: "#323232") : Color.init(hex: "#EBEBEA")
    }
    
    
}
