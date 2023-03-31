//
//  ClientBookingViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit
import CoreData

class ClientBookingViewController: UIViewController {
    var client : Client?
    var bookingList = [Booking]()
    var bookingListOngoing = [Booking]()
    var bookingListHistory = [Booking]()
    var selectedService: Service?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var emptyView: UIView!
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
        getClient()
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
        if let client = client{
            bookingList = CoreDataManager.shared.loadBookingList(email: client.email ?? "", isClient: true)
            bookingListOngoing = bookingList.filter({
                $0.status == "New" || $0.status == "Pending" || $0.status == "Inprogress"
            })
            bookingListHistory = bookingList.filter({
                $0.status == "Rejected" || $0.status == "Completed" || $0.status == "Cancelled"
            })
        }
    }
    
    func getClient(){
        let user =  UserDefaultsManager.shared.getUserData()
        client = CoreDataManager.shared.getClient(email: user.email)
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
        if segmentSelectedIndex == 0{
            let rowCount = bookingListOngoing.count
            if rowCount == 0 {
                emptyView.isHidden = false
                tableView.backgroundView = emptyView
            }else{
                 tableView.backgroundView = nil
            }
            return rowCount
            
        }else{
            let rowCount = bookingListHistory.count
            if rowCount == 0 {
                emptyView.isHidden = false
                tableView.backgroundView = emptyView
            }else{
                 tableView.backgroundView = nil
            }
            return rowCount
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
        var booking:Booking? = nil
        if segmentSelectedIndex == 0 && bookingListOngoing.count > 0 {
            booking = bookingListOngoing[indexPath.row]
        } else if segmentSelectedIndex == 1 && bookingListHistory.count > 0 {
            booking = bookingListHistory[indexPath.row]
        }
        
        if let viewController = UIStoryboard(name: "ClientBookingDetail", bundle: nil).instantiateViewController(withIdentifier: "ClientBookingDetail") as? ClientBookingDetailController {
            if let navigator = navigationController {
                viewController.booking = booking
                navigator.pushViewController(viewController, animated: true)
                
            }
        }
    }
}

extension ClientBookingViewController: FilterCallBackProtocal {
    func applySortBy(selectedSort: SortType) {
        print("sort by" + "\(selectedSort)")
    }
}
