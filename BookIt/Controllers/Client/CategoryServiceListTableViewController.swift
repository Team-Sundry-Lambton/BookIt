//
//  CategoryServiceListTableViewController.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-17.
//

import UIKit

class CategoryServiceListTableViewController: BaseTableViewController {
    
    var serviceList = [Service]()
    let search = UISearchController(searchResultsController: nil)
    var searchText = ""
    var isFiltered = false
    var selectedCategory: Category?
    var selectedVendor: Vendor?
    @IBOutlet weak var emptyView: UIView!
    var sortAscending = true
    var sortBy: SortType = .byTitle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.search.delegate = self
        self.search.searchBar.delegate = self
        self.search.hidesNavigationBarDuringPresentation = false
        self.search.searchBar.tintColor = UIColor.gray
        self.search.searchBar.placeholder = "Search for Services"
        self.search.searchBar.backgroundImage = UIImage()
        tableView.tableHeaderView = search.searchBar
        self.definesPresentationContext = true
        
        tableView.insertSubview(emptyView, at: 1)
        emptyView.isHidden = true
        
        loadServices()
        customDesign()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func customDesign(){
        let titleLabel = UILabel()
        if let category = selectedCategory{
            titleLabel.text = category.name
        }
        if let vendor = selectedVendor{
            titleLabel.text = (vendor.firstName ?? "") + " " + (vendor.lastName ?? "")
        }
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        // Create a filter icon image
        let filterIcon = UIImage(named: "filterIcon")

        // Create a custom bar button item with the filter icon
        let filterButton = UIBarButtonItem(image: filterIcon, style: .plain, target: self, action: #selector(filterTapped))

        // Add the custom bar button item to the right navigation item
        navigationItem.rightBarButtonItem = filterButton
        
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "ServiceDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceDetailTableViewCell")
        
        
        }
    
    @objc func filterTapped() {
        //popup filter pagesheet
        showFilterPopup()
    }
    
    private func showFilterPopup() {
        if let viewController = UIStoryboard(name: "FilterPopup", bundle: nil).instantiateViewController(withIdentifier: "FilterPopupViewController") as? FilterPopupViewController {
            if let sheet = viewController.sheetPresentationController {
                sheet.detents = [
                    .custom { _ in
                        return 320
                    }
                ]

            }
            viewController.delegate = self
            viewController.selectedSort = self.sortBy
            viewController.isAsc = self.sortAscending
            present(viewController, animated: true)
        }
    }
    
    func loadServices(){
        if let category = selectedCategory{
            if let categoryName = category.name{
                serviceList =  CoreDataManager.shared.loadServicesForSelectedCategory(category: categoryName, searchText: searchText, sortBy: sortBy, sortAscending: sortAscending)
            }
        }else if let vendor = selectedVendor{
            if let vendorName = vendor.email{
                serviceList =  CoreDataManager.shared.loadServicesForSelectedVendor(email: vendorName, searchText: searchText)
            }
        }
      self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let numRows = serviceList.count // determine number of rows to display
        emptyView.isHidden = numRows != 0
        return numRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceDetailTableViewCell", for: indexPath) as? ServiceDetailTableViewCell
        if serviceList.count > 0 {
            let service = serviceList[indexPath.row]
            cell?.configureCell(service: service)
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let viewController = UIStoryboard(name: "ServiceDetail", bundle: nil).instantiateViewController(withIdentifier: "ClientServiceDetailViewController") as? ClientServiceDetailViewController {
            if let navigator = navigationController {
                let selectedService = serviceList[indexPath.item]
                viewController.selectedService = selectedService
                navigator.pushViewController(viewController, animated: true)
                
            }
        }
    }
}

extension CategoryServiceListTableViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        isFiltered = false
        loadServices()
    }
}

extension CategoryServiceListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.searchText = ""
            isFiltered = false
            loadServices()
            return
        }
        self.searchText = searchText
        isFiltered = true
        loadServices()
    }
    
}

extension CategoryServiceListTableViewController: FilterCallBackProtocal {
    func applySortBy(selectedSort: SortType, isAsc: Bool) {
        sortBy = selectedSort
        sortAscending = isAsc
        loadServices()
    }
       
}
