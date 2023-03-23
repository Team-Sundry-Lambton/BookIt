//
//  CategoryServiceListTableViewController.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-17.
//

import UIKit
import CoreData

class CategoryServiceListTableViewController: UITableViewController {
    
    var serviceList = [Service]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let search = UISearchController(searchResultsController: nil)
    var searchText = ""
    var isFiltered = false
    var selectedCategory: Category?
    var selectedVendor: Vendor?
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the search controller
//        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
//        customView.backgroundColor = .red
//        self.navigationItem.titleView = customView
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
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
            present(viewController, animated: true)
        }
    }
    
    func loadServices(){
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        if let category = selectedCategory{
            if let categoryName = category.name{
                var categoryPredicate = NSPredicate(format: "parent_Category.name == %@", categoryName)
                if !searchText.isEmpty{
                    categoryPredicate = NSPredicate(format: "parent_Category.name == %@ AND ( serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@ )", categoryName, searchText, searchText)
                }
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
            }
        }else if let vendor = selectedVendor{
            if let vendorName = vendor.email{
                var categoryPredicate = NSPredicate(format: "parent_Vendor.email == %@", vendorName)
                if !searchText.isEmpty{
                    categoryPredicate = NSPredicate(format: "parent_Vendor.email == %@ AND ( serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@ )", vendorName, searchText, searchText)
                }
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
            }
        }
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
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
    func applySortBy(selectedSort: SortType) {
        print("sort by" + "\(selectedSort)")
    }
}
