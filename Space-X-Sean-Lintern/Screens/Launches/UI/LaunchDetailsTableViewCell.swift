import UIKit

class LaunchDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var patchImageView: UIImageView!
    @IBOutlet weak var detailsStack: UIStackView!
    @IBOutlet weak var successLabel: UILabel!
    
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var missionStack: UIStackView!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var dateTimeStack: UIStackView!
    
    @IBOutlet weak var rocketLabel: UILabel!
    @IBOutlet weak var rocketStack: UIStackView!
    
    @IBOutlet weak var daysSinceStack: UIStackView!
    @IBOutlet weak var daysSinceTitleLabel: UILabel!
    @IBOutlet weak var daysSinceValueLabel: UILabel!
    
    override func prepareForReuse() {
        patchImageView.image = nil
        
        if let url = model?.patchImageURL {
            ImageLoader.shared.cancelRequest(resource: url)
        }

        super.prepareForReuse()
    }
    
    private var model: LaunchCellViewModelType?
    
    func configure(model: LaunchCellViewModelType) {
        self.model = model
        successLabel.text = model.launchSuccessString
        missionLabel.text = model.missionName
        
        dateTimeStack.isHidden = model.launchTime == nil
        dateTimeLabel.text = model.launchTime
        
        rocketLabel.text = model.rocketDetails
        
        daysSinceStack.isHidden = model.daysSince == nil
        daysSinceTitleLabel.text = model.daysSince?.title
        daysSinceValueLabel.text = "\(model.daysSince?.days ?? 0)"
        
        if let url = model.patchImageURL {
            patchImageView.loadImage(resource: url)
        }
    }
}
