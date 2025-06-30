//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

import UIKit
import SwiftUI

// UIColor -> init(hex:)
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b: CGFloat
        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255

            self.init(red: r, green: g, blue: b, alpha: 1.0)
            return
        }

        return nil
    }
}

// Color -> init(hex:) + toHex()
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        if let uiColor = UIColor(self).cgColor.components {
            let r = Int((uiColor[0] * 255.0).rounded())
            let g = Int((uiColor[1] * 255.0).rounded())
            let b = Int((uiColor[2] * 255.0).rounded())
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        return "#000000"
    }
}
