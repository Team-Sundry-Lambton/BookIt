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
    var categoryName: String?
    
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
        
        loadServices()
        customDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func customDesign(){
        let titleLabel = UILabel()
        titleLabel.text = categoryName
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    func loadServices(){
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parent_Category.name == %@", "Cleaning")
        let predicate = NSPredicate(format: "serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@", searchText, searchText)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,predicate])
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
        return serviceList.count
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
