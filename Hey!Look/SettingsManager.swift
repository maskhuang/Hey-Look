import UIKit

class SettingsManager {
    static let shared = SettingsManager()

    var fontSize: CGFloat = 100
    var fontName: String = "System"
    var backgroundColorIndex: Int = 0

    // 背景颜色数组
    var backgroundColors: [UIColor] = [.white, .black, .yellow, .blue, .red, .green, .gray, .orange]
    var backgroundColorNames: [String] = ["White", "Black", "Yellow", "Blue", "Red", "Green", "Gray", "Orange"]

    private init() {
        loadSettings()
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(Float(fontSize), forKey: "fontSize")
        defaults.set(fontName, forKey: "fontName")
        defaults.set(backgroundColorIndex, forKey: "backgroundColorIndex")

        // 保存自定义颜色（如果有）
        if backgroundColorIndex >= backgroundColors.count {
            let customColor = backgroundColors.last ?? UIColor.white
            let colorHex = customColor.toHexString()
            defaults.set(colorHex, forKey: "customBackgroundColor")
        } else {
            defaults.removeObject(forKey: "customBackgroundColor")
        }
    }

    func loadSettings() {
        let defaults = UserDefaults.standard
        let savedFontSize = defaults.float(forKey: "fontSize")
        if savedFontSize != 0 {
            fontSize = CGFloat(savedFontSize)
        }
        fontName = defaults.string(forKey: "fontName") ?? "System"
        backgroundColorIndex = defaults.integer(forKey: "backgroundColorIndex")

        // 加载自定义颜色
        if backgroundColorIndex >= backgroundColors.count {
            if let colorHex = defaults.string(forKey: "customBackgroundColor"),
               let color = UIColor(hexString: colorHex) {
                backgroundColors.append(color)
                backgroundColorNames.append("Custom \(backgroundColors.count)")
            } else {
                // 如果无法加载自定义颜色，重置为默认颜色
                backgroundColorIndex = 0
            }
        }
    }

    // 获取当前的背景颜色
    var backgroundColor: UIColor {
        return backgroundColors[backgroundColorIndex % backgroundColors.count]
    }
}
