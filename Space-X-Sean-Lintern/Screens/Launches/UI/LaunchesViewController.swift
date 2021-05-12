import UIKit

class LaunchesViewController: UIViewController {

    static func instantiate(viewModel: LaunchesViewModel) -> LaunchesViewController {
        let controller = UIStoryboard(name: "Launches", bundle: nil).instantiateInitialViewController() as! LaunchesViewController
        controller.viewModel = viewModel
        return controller
    }
    
    private var viewModel: LaunchesViewModel!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    @IBOutlet private weak var errorText: UILabel!
    
    private var sectionData: [LaunchesViewModel.Section]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "f.circle"), style: .plain, target: self, action: #selector(filterPress))
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = filterButton
        
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl

        setupBindings()
        setupAccessibility()
        
        // remove unneeded seperators
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: CompanyCellViewModelType.self))
        tableView.register(UINib(nibName: String(describing: LaunchDetailsTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: LaunchDetailsTableViewCell.self))

        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.inputs.viewDidLoad()
    }
    
    private func setupBindings() {
        viewModel.outputs.errorHandler = { [weak self] error in
            self?.errorText.text = error
        }
        
        viewModel.outputs.loadingHandler = { [weak self] loading in
            if loading {
                self?.loader.startAnimating()
            } else {
                self?.loader.stopAnimating()
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.outputs.tableDataHandler = { [weak self] data in
            self?.sectionData = data
        }
        
        navigationItem.title = viewModel.outputs.title
        navigationItem.rightBarButtonItems = [filterButton]
    }
    
    @objc private func filterPress() {
        viewModel.inputs.filtersPress()
    }
    
    @objc private func refreshPulled() {
        viewModel.inputs.refreshPulled()
    }
    
    private func setupAccessibility() {
        errorText.accessibilityIdentifier = "errorLabel"
        filterButton.accessibilityIdentifier = "filterButton"
    }
}

extension LaunchesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData?[section].data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionData?[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let model = sectionData?[indexPath.section].data[indexPath.row] {
            var cell: UITableViewCell!
            
            // Should porbably move to an enum cell type identifier?
            if let model = model as? CompanyCellViewModelType {
                let companyCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CompanyCellViewModelType.self), for: indexPath)
                companyCell.textLabel?.numberOfLines = 0
                companyCell.textLabel?.text = model.text
                cell = companyCell
            } else if let model = model as? LaunchCellViewModelType,
                      let launchCell = tableView.dequeueReusableCell(withIdentifier: String(describing: LaunchDetailsTableViewCell.self), for: indexPath) as? LaunchDetailsTableViewCell {
                launchCell.configure(model: model)
                cell = launchCell
            }
            cell.accessibilityIdentifier = "section.\(indexPath.section).row.\(indexPath.row)"
            return cell
        }
        return UITableViewCell()
    }
}
