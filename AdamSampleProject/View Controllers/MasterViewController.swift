//  AdamSampleProject

import UIKit
import CoreData

class MasterViewController: UIViewController, ViewWithViewModel, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {
    //MARK: General Variable Declarations
    var tableViewModel: TableViewModel!
    let apiClient = APIClient()
    var numberOfSelectionsOnTable: Int = 0
    
    var weatherTableViewModel: WeatherTableViewModel!
    var viewModel: ViewModel! {
        didSet {
            self.tableViewModel = (viewModel as! TableViewModel)
        }
    }

    @IBOutlet weak var locationEntryField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UITableView!
    
    //MARK: General Lifecycle Handling and View Load Operations
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewModel = WeatherTableViewModel.init()
        assert(self.tableViewModel != nil)
        
        locationEntryField.clearButtonMode = .whileEditing
        locationEntryField.delegate = self
        
        self.tableViewModel.viewWillAppear()
        self.tableViewModel.viewDidLoadActions()
        self.configureView()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weatherTableViewModel = self.tableViewModel as? WeatherTableViewModel
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewModel.viewAppeared()
        weatherTableViewModel = self.tableViewModel as? WeatherTableViewModel
        tableView.reloadData()
    }
    
    //MARK: UI Component Setup
     func configureView() {
         setUpTable()
    }
    
    
    func setUpTable() {
        self.searchView.dataSource = self
        self.searchView.delegate = self
        self.searchView.rowHeight = UITableView.automaticDimension

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.allowsMultipleSelection = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = true
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        self.title = tableViewModel.title
        self.tableViewModel.containingVC = self

        let nibInfoArray = self.tableViewModel.getCellNibs()
        if let unwrappedNibInfoArray = nibInfoArray {
            for nibInfo in unwrappedNibInfoArray {
                if nibInfo.identifier == NibNameValue {
                    self.tableView.register(nibInfo.nib, forCellReuseIdentifier: nibInfo.identifier)
                }
                if nibInfo.identifier == NibNameValueSearch {
                    self.searchView.register(nibInfo.nib, forCellReuseIdentifier: nibInfo.identifier)
                }
            }
        }
        
        self.navigationItem.leftBarButtonItems = tableViewModel.leftBarButtonItems()
        self.navigationItem.rightBarButtonItems = tableViewModel.rightBarButtonItems()
    }
        
    func close(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    //MARK: Navigation Bar Button Operations
    @IBAction func began(_ sender: Any) {
        if locationEntryField.text?.count == 0 { refreshPressed(self) }
        self.weatherTableViewModel.getGeolocation(text: (locationEntryField.text ?? "") + "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            asyncMainThread { [self] in
                self.searchView.reloadData()
            }
        }
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.weatherTableViewModel.getGeolocation(text: (locationEntryField.text ?? "") + "")
        
        asyncMainThread { [self] in
            self.searchView.reloadData()
        }
        
        return false
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        weatherTableViewModel.refreshValues()
        locationEntryField.text = ""
        asyncMainThread { [self] in
            tableView.reloadData()
        }
    }

    //MARK: TableViewLogic
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return weatherTableViewModel.weatherData.count
        } else {
            return weatherTableViewModel.geoLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return weatherInformationHeight
        } else {
            return searchCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return weatherInformationHeight
        } else {
            return searchCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewModel.cellIdentifier, for: indexPath) as? DefaultTableViewCell else {
                return UITableViewCell()
            }

            if let object = weatherTableViewModel.weatherData as? [WeatherInformation] {
                return tableViewModel.configureCellForWeather(cell, object: object, indexPath: indexPath)
            } else {
                return UITableViewCell.init()
            }
        }
        else  {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewModel.cellIdentifierSearch, for: indexPath) as? DefaultTableViewCell else {
                return UITableViewCell()
            }

            return tableViewModel.configureCellForSearch(cell, object: weatherTableViewModel.geoLocations, indexPath: indexPath)
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewModel.handleDidSelectOnTable(indexPath: indexPath)
    }
}
