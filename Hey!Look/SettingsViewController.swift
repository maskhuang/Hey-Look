import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontPickerView: UIPickerView!
    @IBOutlet weak var backgroundColorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var colorPickerButton: UIButton!

    let fontNames = ["System", "ArialMT", "Helvetica", "TimesNewRomanPSMT"]

    override func viewDidLoad() {
        super.viewDidLoad()

        fontPickerView.delegate = self
        fontPickerView.dataSource = self

        // 设置初始值
        let settings = SettingsManager.shared
        fontSizeSlider.value = Float(settings.fontSize)

        if let fontIndex = fontNames.firstIndex(of: settings.fontName) {
            fontPickerView.selectRow(fontIndex, inComponent: 0, animated: false)
        }

        // 设置背景颜色选择器
        setupBackgroundColorSegmentedControl()
    }

    func setupBackgroundColorSegmentedControl() {
        print("set up back ground color semented")
        let settings = SettingsManager.shared

        // 移除所有段
        backgroundColorSegmentedControl.removeAllSegments()

        // 添加新的段
        for (index, color) in settings.backgroundColors.enumerated() {
            if let colorImage = UIImage(color: color)?.withRenderingMode(.alwaysOriginal) {
                backgroundColorSegmentedControl.insertSegment(with: colorImage, at: index, animated: false)
                print("Inserted segment \(index) with color: \(color)")
            } else {
                backgroundColorSegmentedControl.insertSegment(withTitle: settings.backgroundColorNames[index], at: index, animated: false)
                print("Inserted segment \(index) with title: \(settings.backgroundColorNames[index])")
            }
        }


        // 设置选中的段
        backgroundColorSegmentedControl.selectedSegmentIndex = settings.backgroundColorIndex

        // 可选：调整 segmented control 的外观以更好地显示图像
        backgroundColorSegmentedControl.backgroundColor = .clear
        backgroundColorSegmentedControl.selectedSegmentTintColor = .clear
    }

    @IBAction func fontSizeSliderChanged(_ sender: UISlider) {
        SettingsManager.shared.fontSize = CGFloat(sender.value)
    }

    // MARK: - UIPickerViewDelegate & DataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNames.count
    }
  
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontNames[row]
    }
  
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsManager.shared.fontName = fontNames[row]
    }

    @IBAction func backgroundColorChanged(_ sender: UISegmentedControl) {
        SettingsManager.shared.backgroundColorIndex = sender.selectedSegmentIndex
    }

    @IBAction func colorPickerButtonTapped(_ sender: UIButton) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.selectedColor = SettingsManager.shared.backgroundColor
        present(colorPicker, animated: true, completion: nil)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let settings = SettingsManager.shared
        let selectedColor = viewController.selectedColor

        // 检查颜色是否已存在
        if let existingIndex = settings.backgroundColors.firstIndex(where: { $0.isEqual(selectedColor) }) {
            settings.backgroundColorIndex = existingIndex
        } else {
            // 添加自定义颜色
            settings.backgroundColors.append(selectedColor)
            settings.backgroundColorNames.append("Custom \(settings.backgroundColors.count)")
            settings.backgroundColorIndex = settings.backgroundColors.count - 1
            setupBackgroundColorSegmentedControl()
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        SettingsManager.shared.saveSettings()
        self.dismiss(animated: true, completion: nil)
    }
}
