//
//  ClientServiceDetailViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-22.
//

import UIKit
import CoreData

class ClientServiceDetailViewController: UIViewController{
  
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedService: Service?


    @IBOutlet weak var interfaceSegmented: CustomSegmentedControl!{
        didSet{
            interfaceSegmented.setButtonTitles(buttonTitles: ["Descriptions","Reviews", "Location"])
            interfaceSegmented.selectorViewColor = #colorLiteral(red: 0.2415007949, green: 0.3881379962, blue: 0.6172356606, alpha: 1)
            interfaceSegmented.selectorTextColor = #colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1)
            interfaceSegmented.textColor = #colorLiteral(red: 0.6947146058, green: 0.7548407912, blue: 0.8478365541, alpha: 1)
            interfaceSegmented.baseLineColor = #colorLiteral(red: 0.9490194917, green: 0.9490197301, blue: 0.9533253312, alpha: 1)
        }
    }

    @IBOutlet weak var bannerTableView: UITableView!
    @IBOutlet weak var lblVendorName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UIButton!
    @IBOutlet weak var tvDescription: UITextView!
    

    @IBOutlet weak var viewDescription: UIView!
    
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewReviews: UIView!
    
    let fullSizeWidth = UIScreen.main.bounds.width
    var bannerViews: [UIImageView] = []
    var timer = Timer()
    var xOffset: CGFloat = 0
    var currentPage = 0 {
        didSet{
            xOffset = fullSizeWidth * CGFloat(self.currentPage)
            bannerTableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
 
        interfaceSegmented.delegate = self
        loadServiceDetail()
                
    }
    
    func loadServiceDetail(){
        lblTitle.text = selectedService?.serviceTitle
        
        if let price = selectedService?.price, let priceType = selectedService?.priceType {
            lblPrice.setTitle("$ \(price)/ \(priceType)", for: .normal)
        } else {
            lblPrice.setTitle("N/A", for: .normal)
        }
        
        if let user =  selectedService?.parent_Vendor {
            if let firstName = user.firstName, let lastName = user.lastName {
                lblVendorName.text = firstName + " " + lastName
            }else{
                lblVendorName.text = " "
            }
        } else {
            lblVendorName.text = " "
        }
        
        tvDescription.text = selectedService?.serviceDescription
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ClientServiceDetailViewController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
         switch (index)  {
          case 1:
            viewDescription.isHidden = true
            viewReviews.isHidden = false
            viewLocation.isHidden = true
          case 2:
            viewDescription.isHidden = true
            viewReviews.isHidden = true
            viewLocation.isHidden = false
          default:
             viewDescription.isHidden = false
            viewReviews.isHidden = true
            viewLocation.isHidden = true
        }
        
    }
}
