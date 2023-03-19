//
//  VendorHomeViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-14.
//

import UIKit
import CoreData

class VendorHomeViewController: UIViewController {
    var loginUser : LoginUser?
    var bookingList = [Booking]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var interfaceSegmented: CustomSegmentedControl! {
        didSet{
            interfaceSegmented.setButtonTitles(buttonTitles: ["Ongoing","History"])
            interfaceSegmented.selectorViewColor = #colorLiteral(red: 0.2415007949, green: 0.3881379962, blue: 0.6172356606, alpha: 1)
            interfaceSegmented.selectorTextColor = #colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1)
            interfaceSegmented.textColor = #colorLiteral(red: 0.6947146058, green: 0.7548407912, blue: 0.8478365541, alpha: 1)
            interfaceSegmented.baseLineColor = #colorLiteral(red: 0.9490194917, green: 0.9490197301, blue: 0.9533253312, alpha: 1)
        }
    }
    
    var segmentSelectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        interfaceSegmented.delegate = self
        tableView.register(UINib(nibName: "ServiceStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceStatusTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    private func loadData() {
        loadBookingList()
        tableView.reloadData()
    }
    
    private func loadBookingList(){
        let request: NSFetchRequest<Booking> = Booking.fetchRequest()
        let folderPredicate = NSPredicate(format: "vendor.email=%@", loginUser?.email ?? "")
        request.predicate = folderPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "status", ascending: true)]
//        request.fetchLimit = 10
        do {
            bookingList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
    }
}

extension VendorHomeViewController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        segmentSelectedIndex = index
    }
}

extension VendorHomeViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceStatusTableViewCell", for: indexPath) as? ServiceStatusTableViewCell
        return cell ?? UITableViewCell()
    }
}

