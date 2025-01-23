import Foundation
import SwiftData
import SwiftUI

@Model
final class AppTheme {
    var name: String
    var isDarkMode: Bool
    var isEinkMode: Bool
    var backgroundColor: String
    var textColor: String
    var accentColor: String
    var fontSize: Int
    var lineSpacing: Double
    var paragraphSpacing: Double
    var customFontPath: String?
    var customBackgroundImagePath: String?
    
    init(name: String = "默认主题") {
        self.name = name
        self.isDarkMode = false
        self.isEinkMode = false
        self.backgroundColor = "#FFFFFF"
        self.textColor = "#000000"
        self.accentColor = "#389E0D"
        self.fontSize = 16
        self.lineSpacing = 1.2
        self.paragraphSpacing = 1.0
    }
    
    var backgroundColorValue: Color {
        Color(hex: backgroundColor) ?? .white
    }
    
    var textColorValue: Color {
        Color(hex: textColor) ?? .black
    }
    
    var accentColorValue: Color {
        Color(hex: accentColor) ?? .green
    }
}

private extension Color {
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
}