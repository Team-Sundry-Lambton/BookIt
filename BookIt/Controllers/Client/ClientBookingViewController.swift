//
//  ClientBookingViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit
import CoreData

class ClientBookingViewController: UIViewController {
    var loginUser : LoginUser?
    var bookingList = [Booking]()
    var bookingListOngoing = [Booking]()
    var bookingListHistory = [Booking]()
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
        resetSegment()
    }
        
    private func loadData() {
        loadBookingList()
        tableView.reloadData()
    }
        
    private func loadBookingList(){
            bookingList = CoreDataManager.shared.loadBookingList(email: loginUser?.email ?? "")
            bookingListOngoing = bookingList.filter({
                $0.status == "new" || $0.status == "pending" || $0.status == "inprogress"
            })
            bookingListHistory = bookingList.filter({
                $0.status == "cancel" || $0.status == "completed"
            })
    }
        
    @IBAction func filterAction(_ sender: Any) {
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
        
    private func resetSegment() {
        segmentSelectedIndex = 0
    }
}
    
extension ClientBookingViewController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        segmentSelectedIndex = index
        tableView.reloadData()
    }
}

extension ClientBookingViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentSelectedIndex == 0 && bookingListOngoing.count > 0 {
            return bookingListOngoing.count
        } else if segmentSelectedIndex == 1 && bookingListHistory.count > 0 {
            return bookingListHistory.count
        } else {
            return 10 //dummy
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceStatusTableViewCell", for: indexPath) as? ServiceStatusTableViewCell
            
        var booking:Booking? = nil
        if segmentSelectedIndex == 0 && bookingListOngoing.count > 0 {
            booking = bookingListOngoing[indexPath.row]
        } else if segmentSelectedIndex == 1 && bookingListHistory.count > 0 {
            booking = bookingListHistory[indexPath.row]
        }
            
        if let booking = booking {
            cell?.serviceName.text = booking.service?.serviceTitle
            cell?.bookDateTimeLabel.text = booking.date?.dateAndTimetoString()
            cell?.customerNameLabel.text = booking.client?.firstName
            cell?.locationLabel.text = booking.client?.address?.address
            cell?.priceLabel.text = booking.service?.price
            cell?.statusLabel.text = booking.status
        }
            
        return cell ?? UITableViewCell()
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //go to service detail page.
        print("selected" + "\(indexPath.row)")
    }
}

extension ClientBookingViewController: FilterCallBackProtocal {        func applySortBy(selectedSort: SortType) {
        print("sort by" + "\(selectedSort)")
    }
}
