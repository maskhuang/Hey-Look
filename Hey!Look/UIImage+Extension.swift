import UIKit

extension UIImage {
    /// 从 UIColor 创建一个纯色 UIImage
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 20, height: 20)) {
        // 确保 size 是有效的
        guard size.width > 0, size.height > 0 else { return nil }
        
        // 创建画布
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // 填充颜色
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // 获取生成的 UIImage
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
