//
//  NSColor+Extension.swift
//  Yeelight
//
//  Created by xs0521 on 2024/12/1.
//

import Foundation
import AppKit

extension NSColor {
    /// 创建 NSColor 对象，支持 HEX 值输入
    /// - Parameters:
    ///   - hex: 十六进制颜色值，支持 3、6 或 8 位（例如 "#FFF"、"#FFFFFF"、"#FFFFFFFF"）
    ///   - alpha: 可选的透明度（当 HEX 不包含 alpha 时生效），默认值为 1.0
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        // 移除前缀
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedHex.hasPrefix("#") {
            cleanedHex.removeFirst()
        }

        // 解析 HEX 长度
        var rgbValue: UInt64 = 0
        guard Scanner(string: cleanedHex).scanHexInt64(&rgbValue) else {
            return nil // 无法解析 HEX 值
        }

        let length = cleanedHex.count
        switch length {
        case 3: // #RGB
            let r = CGFloat((rgbValue & 0xF00) >> 8) / 15.0
            let g = CGFloat((rgbValue & 0x0F0) >> 4) / 15.0
            let b = CGFloat(rgbValue & 0x00F) / 15.0
            self.init(red: r, green: g, blue: b, alpha: alpha)

        case 6: // #RRGGBB
            let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgbValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: alpha)

        case 8: // #RRGGBBAA
            let r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(rgbValue & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)

        default:
            return nil // 非法的 HEX 长度
        }
    }

    /// 将 NSColor 转为 HEX 格式
    /// - Parameter includeAlpha: 是否包含透明度，默认值为 `false`
    func toHex(includeAlpha: Bool = false) -> String? {
        guard let rgbColor = usingColorSpace(.deviceRGB) else { return nil }

        let r = Int(rgbColor.redComponent * 255.0)
        let g = Int(rgbColor.greenComponent * 255.0)
        let b = Int(rgbColor.blueComponent * 255.0)

        if includeAlpha {
            let a = Int(rgbColor.alphaComponent * 255.0)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}
