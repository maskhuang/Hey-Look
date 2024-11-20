import UIKit
import AVFoundation

// MARK: - UILabel Extension for Dynamic Font Size

extension UILabel {
    func adjustFontSizeToFitHeight(maxHeight: CGFloat, minFontSize: CGFloat = 12.0, maxFontSize: CGFloat = 500.0) {
        guard let text = self.text, !text.isEmpty else { return }

        var min = minFontSize
        var max = maxFontSize
        var fontSize = maxFontSize

        while min <= max {
            fontSize = (min + max) / 2
            if let font = UIFont(name: self.font.fontName, size: fontSize) {
                let attributes: [NSAttributedString.Key: Any] = [.font: font]
                let textHeight = (text as NSString).size(withAttributes: attributes).height

                if textHeight > maxHeight {
                    max = fontSize - 1
                } else {
                    min = fontSize + 1
                }
            } else {
                break
            }
        }

        self.font = self.font.withSize(fontSize)
    }
}


// MARK: - MagnifyViewController

class MagnifyViewController: UIViewController {
    var displayText: String?
    
    @IBOutlet weak var magnifyLabel: UILabel!
    @IBOutlet weak var readAloudButton: UIButton!
    @IBOutlet weak var scrollButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // 滚动文本标签
    private var scrollingLabel1 = UILabel()
    private var scrollingLabel2 = UILabel()
    private var isScrolling = false
    
    // 滚动速度（点/秒）
    private let scrollingSpeed: CGFloat = 200.0
    
    // 容器视图
    private let scrollContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applySettings()
        // 设置放大文本
        magnifyLabel.text = displayText
        magnifyLabel.adjustFontSizeToFitHeight(maxHeight: view.frame.height)
        magnifyLabel.sizeToFit()
        
        // 初始化朗读按钮标题
        readAloudButton.setTitle("朗读", for: .normal)
        view.bringSubviewToFront(backButton)
        backButton.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true

        // 配置滚动容器视图
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 强制方向为横屏
        forceOrientation(to: .landscapeLeft)
        
        print("MagnifyViewController: Enforcing landscape orientation")
    }

    // 使用 UIWindowScene 来安全地强制方向
    func forceOrientation(to orientation: UIInterfaceOrientation) {
        guard let windowScene = view.window?.windowScene else {
            print("Error: No window scene available")
            return
        }
        
        // 创建几何更新的首选项
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation == .portrait ? .portrait : .landscapeLeft)
    }



    private var currentOrientationMask: UIInterfaceOrientationMask = .landscape

    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }



    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Setup Scroll Container View
    func applySettings() {
        let settings = SettingsManager.shared

        // 设置字体大小和字体
        let fontSize = settings.fontSize
        let fontName = settings.fontName
        if fontName == "System" {
            magnifyLabel.font = UIFont.systemFont(ofSize: fontSize)
        } else {
            magnifyLabel.font = UIFont(name: fontName, size: fontSize)
        }

        // 设置背景颜色
        let backgroundColor = settings.backgroundColor
        self.view.backgroundColor = backgroundColor

        // 根据背景颜色调整字体颜色
        let textColor: UIColor = backgroundColor.isLightColor ? .black : .white
        magnifyLabel.textColor = textColor

        // 更新滚动标签的字体和颜色
        scrollingLabel1.font = magnifyLabel.font
        scrollingLabel2.font = magnifyLabel.font
        scrollingLabel1.textColor = textColor
        scrollingLabel2.textColor = textColor

        // 其他设置
        magnifyLabel.numberOfLines = 0
        magnifyLabel.minimumScaleFactor = 0.1
        magnifyLabel.adjustsFontSizeToFitWidth = true
        magnifyLabel.textAlignment = .center
    }

    
    @IBAction func readAloudButtonTapped(_ sender: UIButton) {
        guard let text = displayText, !text.isEmpty else {
            // 提示用户输入文本
            let alert = UIAlertController(title: "提示", message: "请输入要朗读的文本。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 检查是否正在朗读
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            readAloudButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        } else {
            speak(text: text)
            readAloudButton.setImage(UIImage(systemName: "speaker.wave.3.fill"), for: .normal)
        }
    }
    private var isScrollContainerViewSetup = false // 添加一个标志变量

    private func setupScrollContainerView() {
        view.addSubview(scrollContainerView)
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false
        // 在 setupScrollContainerView() 方法中
        scrollContainerView.isUserInteractionEnabled = false
        // 在 setupScrollContainerView() 方法中
        scrollingLabel1.isUserInteractionEnabled = false
        scrollingLabel2.isUserInteractionEnabled = false

        scrollContainerView.clipsToBounds = true

        NSLayoutConstraint.activate([
            scrollContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollContainerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        // 设置滚动标签的文本
        scrollingLabel1.text = displayText
        scrollingLabel2.text = displayText

        // 设置滚动标签的其他属性
        scrollingLabel1.translatesAutoresizingMaskIntoConstraints = false
        scrollingLabel2.translatesAutoresizingMaskIntoConstraints = false

        scrollContainerView.addSubview(scrollingLabel1)
        scrollContainerView.addSubview(scrollingLabel2)
        
        NSLayoutConstraint.activate([
            scrollingLabel1.leadingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor),
            scrollingLabel1.centerYAnchor.constraint(equalTo: scrollContainerView.centerYAnchor),
            scrollingLabel2.leadingAnchor.constraint(equalTo: scrollingLabel1.trailingAnchor, constant: 50),
            scrollingLabel2.centerYAnchor.constraint(equalTo: scrollContainerView.centerYAnchor)
        ])
        
        scrollContainerView.isHidden = true
        // 在 setupScrollContainerView() 方法末尾
        view.bringSubviewToFront(scrollButton)
        view.bringSubviewToFront(readAloudButton)
        view.bringSubviewToFront(backButton)

    }

    // MARK: - Scroll Button Action
    
    @IBAction func scrollButtonTapped(_ sender: UIButton) {
        isScrolling.toggle()

        if isScrolling {
            if !isScrollContainerViewSetup {
                setupScrollContainerView()
                isScrollContainerViewSetup = true
            }

            magnifyLabel.isHidden = true
            scrollContainerView.isHidden = false
            scrollButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)

            view.layoutIfNeeded() // Ensure layout is up to date

            // Adjust font size after layout
            let containerHeight = scrollContainerView.frame.height
            scrollingLabel1.adjustFontSizeToFitHeight(maxHeight: containerHeight)
            scrollingLabel2.adjustFontSizeToFitHeight(maxHeight: containerHeight)

            startScrolling()
        } else {
            stopScrolling()
            scrollContainerView.isHidden = true
            magnifyLabel.isHidden = false
            scrollButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }



    
    // MARK: - Scrolling Implementation
    private var displayLink: CADisplayLink?

    private func startScrolling() {
        stopScrolling() // 停止任何现有动画

        scrollingLabel1.frame.origin.x = scrollContainerView.frame.width
        scrollingLabel2.frame.origin.x = scrollingLabel1.frame.maxX + 50

        displayLink = CADisplayLink(target: self, selector: #selector(updateScroll))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func updateScroll() {
        let delta = scrollingSpeed / 60.0 // 每帧移动的距离（假设 60 FPS）

        scrollingLabel1.frame.origin.x -= delta
        scrollingLabel2.frame.origin.x -= delta

        let screenMidX = scrollContainerView.frame.width / 2.0

        if scrollingLabel1.frame.maxX <= screenMidX, scrollingLabel2.frame.minX > scrollContainerView.frame.width {
            scrollingLabel2.text = displayText
            scrollingLabel2.sizeToFit()
            scrollingLabel2.frame.origin.x = scrollingLabel1.frame.maxX + 50
        }

        if scrollingLabel2.frame.maxX <= screenMidX, scrollingLabel1.frame.minX > scrollContainerView.frame.width {
            scrollingLabel1.text = displayText
            scrollingLabel1.sizeToFit()
            scrollingLabel1.frame.origin.x = scrollingLabel2.frame.maxX + 50
        }

        if scrollingLabel1.frame.maxX < 0 {
            scrollingLabel1.frame.origin.x = scrollingLabel2.frame.maxX + 50
        }
        if scrollingLabel2.frame.maxX < 0 {
            scrollingLabel2.frame.origin.x = scrollingLabel1.frame.maxX + 50
        }
    }

    private func stopScrolling() {
        displayLink?.invalidate()
        displayLink = nil

        scrollingLabel1.layer.removeAllAnimations()
        scrollingLabel2.layer.removeAllAnimations()

        scrollingLabel1.frame.origin.x = scrollContainerView.frame.width
        scrollingLabel2.frame.origin.x = scrollingLabel1.frame.maxX + 50
    }

    
    // MARK: - Read Aloud Functionality
    
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        // 设置语言，自动检测或用户选择
        if isChinese(text: text) {
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // 设置语速、音调和音量（可选）
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // 朗读
        speechSynthesizer.delegate = self
        speechSynthesizer.speak(utterance)
    }
    
    func isChinese(text: String) -> Bool {
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x4E00...0x9FFF, 0x3400...0x4DBF, 0x20000...0x2A6DF,
                 0x2A700...0x2B73F, 0x2B740...0x2B81F, 0x2B820...0x2CEAF,
                 0xF900...0xFAFF, 0x2F800...0x2FA1F:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    // MARK: - Handle Device Rotation
    
    private var hasAdjustedFontSize = false // 添加标志变量

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 确保 scrollContainerView 获取到最终高度后进行字体调整
        if scrollContainerView.frame.height > 0 && !hasAdjustedFontSize {
            let containerHeight = scrollContainerView.frame.height
            scrollingLabel1.adjustFontSizeToFitHeight(maxHeight: containerHeight, maxFontSize: 500.0)
            scrollingLabel2.adjustFontSizeToFitHeight(maxHeight: containerHeight, maxFontSize: 500.0)
            
            hasAdjustedFontSize = true // 标记已调整字体大小
        }
        if backButton.frame.height == 0 {
                backButton.frame.size.height = 44 // 设置合理的高度
            }
            if backButton.frame.width == 0 {
                backButton.frame.size.width = 50 // 设置合理的宽度
            }
        if backButton.frame.origin.y > view.frame.height {
            backButton.frame.origin.y = 350
            }
        print("backButton frame:", backButton.frame)
        print("backButton.isUserInteractionEnabled:", backButton.isUserInteractionEnabled)
        print("backButton.isHidden:", backButton.isHidden)
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print("Back button tapped")

        // 更新当前支持的方向为竖屏
        currentOrientationMask = .portrait

        // 通知系统更新方向支持
        self.setNeedsUpdateOfSupportedInterfaceOrientations()

        // 强制设备方向为竖屏
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

        // 延迟返回，确保方向切换完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true, completion: nil)
        }
    }



    
}

// MARK: - AVSpeechSynthesizerDelegate

extension MagnifyViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 更新按钮标题为“朗读”
        readAloudButton.setTitle("朗读", for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // 更新按钮标题为“朗读”
        readAloudButton.setTitle("朗读", for: .normal)
    }
}
