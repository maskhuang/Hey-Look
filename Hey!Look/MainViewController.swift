import UIKit

class MainViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeholderLabel: UILabel! // Placeholder UILabel

    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextView.delegate = self
        addDoneButtonOnKeyboard()
        //submitButton.isEnabled = false // 初始禁用
        placeholderLabel.isHidden = false // 初始显示
    }
    
    // MARK: - 添加键盘工具栏
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.tintColor = .systemBlue
        
        inputTextView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        inputTextView.resignFirstResponder()
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            // 提示用户输入文本
            let alert = UIAlertController(title: "提示", message: "请输入要放大的文本。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 跳转到放大显示页面
        navigateToMagnifyView(with: text)
    }
    
    // MARK: - 提交按钮点击事件
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            // 提示用户输入文本
            let alert = UIAlertController(title: "提示", message: "请输入要放大的文本。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 跳转到放大显示页面
        navigateToMagnifyView(with: text)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        //submitButton.isEnabled = !text.isEmpty
        adjustTextViewHeight()
        
        // 控制 Placeholder 显示和隐藏
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // 按下 Enter 键时触发提交
            let trimmedText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedText.isEmpty else {
                // 提示用户输入文本
                let alert = UIAlertController(title: "提示", message: "请输入要放大的文本。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return false
            }
            
            // 跳转到放大显示页面
            navigateToMagnifyView(with: trimmedText)
            
            return false // 阻止插入新行
        }
        return true
    }
    
    // MARK: - 动态调整 UITextView 高度
    
    func adjustTextViewHeight() {
        let size = CGSize(width: inputTextView.frame.width, height: CGFloat.infinity)
        let estimatedSize = inputTextView.sizeThatFits(size)
        
        // 设置一个最大高度（可选）
        let maxHeight: CGFloat = 200
        let newHeight = min(estimatedSize.height, maxHeight)
        
        if textViewHeightConstraint.constant != newHeight {
            textViewHeightConstraint.constant = newHeight
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - 页面跳转方法
    
    func navigateToMagnifyView(with text: String) {
        // 使用 Storyboard ID 进行页面跳转
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let magnifyVC = storyboard.instantiateViewController(withIdentifier: "MagnifyViewController") as? MagnifyViewController {
            magnifyVC.displayText = text
            magnifyVC.modalPresentationStyle = .fullScreen
            self.present(magnifyVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - 菜单按钮点击事件
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        // 跳转到设置页面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settingsVC.modalPresentationStyle = .fullScreen
            self.present(settingsVC, animated: true, completion: nil)
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 强制方向为竖屏
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        // 通知系统更新支持的方向
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
        
        print("MainViewController: Enforcing portrait orientation")
    }




}
