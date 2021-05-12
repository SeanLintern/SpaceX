import UIKit

class FiltersViewController: UIViewController {

    static func instantiate(viewModel: FiltersViewModel) -> FiltersViewController {
        let controller = UIStoryboard(name: "Filters", bundle: nil).instantiateInitialViewController() as! FiltersViewController
        controller.viewModel = viewModel
        return controller
    }
        
    @IBOutlet weak var successSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var yearPickerButton: UIButton!
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var yearPickerViewContainer: UIView!
    @IBOutlet weak var pickerViewTopConstraint: NSLayoutConstraint!
        
    private var viewModel: FiltersViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerViewTopConstraint.constant = 0
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        
        setupAccessibility()
        setupBindings()
        
        viewModel.inputs.viewDidLoad()
    }
    
    private func setupBindings() {
        viewModel.outputs.launchYearUpdate = { [weak self] in
            self?.yearPickerButton.setTitle($0, for: [])
            self?.updatePicker(value: $0)
        }
        
        viewModel.outputs.successUpdate = { [weak self] in
            self?.successSegmentedControl.selectedSegmentIndex = $0
        }
        
        viewModel.outputs.ascendingUpdate = { [weak self] in
            self?.sortedSegmentedControl.selectedSegmentIndex = $0
        }
    }
    
    private func updatePicker(value: String) {
        if let index = viewModel.outputs.yearPickerData.firstIndex(of: value) {
            yearPickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func successSegementChanged(_ sender: UISegmentedControl) {
        viewModel.inputs.setLandingSuccess(segment: sender.selectedSegmentIndex)
    }
    
    @IBAction func sortedSegementChanged(_ sender: UISegmentedControl) {
        viewModel.inputs.setAscending(segment: sender.selectedSegmentIndex)
    }
    
    @IBAction func yearButtonPress(_ sender: Any) {
        animateYearPicker(open: true)
    }
    
    @IBAction func applyButtonPress(_ sender: Any) {
        viewModel.inputs.applyPress()
    }
    
    @IBAction func clearButtonPress(_ sender: Any) {
        viewModel.inputs.clearPress()
    }
    
    @IBAction func yearPickerDoneButtonPress(_ sender: Any) {
        animateYearPicker(open: false)
    }
    
    private func animateYearPicker(open: Bool) {
        pickerViewTopConstraint.constant = open ? -yearPickerViewContainer.frame.height : 0
        
        UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.8, animations: {
            self.view.layoutIfNeeded()
        }).startAnimation()
    }
    
    private func setupAccessibility() {
        yearPickerViewContainer.accessibilityIdentifier = "pickerContainer"
        yearPickerView.accessibilityIdentifier = "yearPicker"
        yearPickerButton.accessibilityIdentifier = "yearValueButton"
        successSegmentedControl.accessibilityIdentifier = "successControl"
        sortedSegmentedControl.accessibilityIdentifier = "sortedControl"
    }
}

extension FiltersViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.outputs.yearPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.outputs.yearPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.inputs.setLaunchYear(value: viewModel.outputs.yearPickerData[row])
    }
}
