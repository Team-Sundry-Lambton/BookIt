//
//  VendorTransactionViewController.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-23.
//

import UIKit
import CoreData

class VendorTransactionViewController: UIViewController {

    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var loginUser : LoginUser?
    var transactionList = [Payment]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func loadData() {
        loadTransactionList()
        calculateTotalIncomePerMonth()
        tableView.reloadData()
    }
    
    private func calculateTotalIncomePerMonth() {
        totalIncomeLabel.text = "\(transactionList.reduce(0,{ $0 + $1.amount}))"
    }
    
    private func loadTransactionList(){
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        let folderPredicate = NSPredicate(format: "booking.vendor.email=%@", loginUser?.email ?? "")
        request.predicate = folderPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        request.fetchLimit = 10
        do {
            transactionList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
    }
}

extension VendorTransactionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionList.count > 0 {
            return transactionList.count
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as? TransactionTableViewCell
        if transactionList.count > 0 {
            let transaction = transactionList[indexPath.row]
            
            cell?.clientNameLabel.text = transaction.booking?.client?.firstName
            cell?.serviceNameLabel.text = transaction.booking?.service?.serviceTitle
            cell?.bankAccountLabel.text = "\(transaction.booking?.vendor?.account?.accountNumber)".masked(reversed: true)
            cell?.totalIncomeLabel.text = "\(transaction.amount)"
            cell?.dateTimeLabel.text = transaction.date?.dateAndTimetoString()
        }
        return cell ?? UITableViewCell()
    }
    
}
