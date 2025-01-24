import SwiftUI
import SwiftData

@Observable
class ReadingConfig {
    var fontSize: CGFloat
    var lineSpacing: CGFloat
    var paragraphSpacing: CGFloat
    var backgroundColor: Color
    var textColor: Color
    var pageMargins: EdgeInsets
    var charactersPerPage: Int
    
    // 存储颜色的RGB值
    var backgroundColorRed: Double
    var backgroundColorGreen: Double
    var backgroundColorBlue: Double
    var backgroundColorOpacity: Double
    
    var textColorRed: Double
    var textColorGreen: Double
    var textColorBlue: Double
    var textColorOpacity: Double
    
    var fontName: String = ".SFUI-Regular"
    var brightness: Double = 1.0
    var isNightMode: Bool = false
    
    init(
        fontSize: CGFloat = 18,
        lineSpacing: CGFloat = 8,
        paragraphSpacing: CGFloat = 12,
        backgroundColor: Color = .white,
        textColor: Color = .black,
        pageMargins: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        charactersPerPage: Int = 1000
    ) {
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.pageMargins = pageMargins
        self.charactersPerPage = charactersPerPage
        
        // 解析背景色
        let backgroundComponents = backgroundColor.components
        self.backgroundColorRed = backgroundComponents.red
        self.backgroundColorGreen = backgroundComponents.green
        self.backgroundColorBlue = backgroundComponents.blue
        self.backgroundColorOpacity = backgroundComponents.opacity
        
        // 解析文字颜色
        let textComponents = textColor.components
        self.textColorRed = textComponents.red
        self.textColorGreen = textComponents.green
        self.textColorBlue = textComponents.blue
        self.textColorOpacity = textComponents.opacity
    }
}

// 扩展 Color 以获取 RGB 分量
extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        return (red, green, blue, opacity)
    }
} 