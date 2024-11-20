import UIKit

extension UIColor {
    /// 将 UIColor 转换为 Hex 字符串
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }

    /// 从 Hex 字符串创建 UIColor
    convenience init?(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        guard cString.count == 6 else { return nil }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    /// 计算颜色的相对亮度
    var relativeLuminance: CGFloat {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        func adjust(_ component: CGFloat) -> CGFloat {
            return (component <= 0.03928) ? (component / 12.92) : pow((component + 0.055) / 1.055, 2.4)
        }

        let rLum = adjust(r)
        let gLum = adjust(g)
        let bLum = adjust(b)

        // 计算相对亮度
        return 0.2126 * rLum + 0.7152 * gLum + 0.0722 * bLum
    }

    /// 判断颜色是否为浅色
    var isLightColor: Bool {
        return self.relativeLuminance > 0.5
    }
}
