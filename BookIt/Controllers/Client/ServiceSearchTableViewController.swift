//
//  ServiceSearchTableViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-12.
//

import UIKit
import CoreData

class ServiceSearchTableViewController: UITableViewController {

    var serviceList = [Service]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchText = ""
    var isFiltered = false
    let search = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant:10.0).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:-10.0).isActive = true
        
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "ServiceDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceDetailTableViewCell")
        
          self.search.delegate = self
          self.search.searchBar.delegate = self
          self.search.hidesNavigationBarDuringPresentation = false
          self.search.searchBar.tintColor = UIColor.gray
          self.navigationItem.titleView = search.searchBar
          self.definesPresentationContext = true

        searchChange()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
        self.search.searchBar.becomeFirstResponder()
    }
    
    func loadServices(){
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        let predicate = NSPredicate(format: "serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@", searchText, searchText)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ServiceSearchTableViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        isFiltered = false
        searchChange()
    }
}

extension ServiceSearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.searchText = ""
            isFiltered = false
            searchChange()
            return
        }
        self.searchText = searchText
        isFiltered = true
        searchChange()
    }
    
    func searchChange(){
        loadServices()
    }
}
