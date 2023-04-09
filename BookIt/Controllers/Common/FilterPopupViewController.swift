//
//  FilterPopupViewController.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-19.
//

import UIKit

enum SortType: Int {
    case byDate = 0
    case byPrice = 1
    case byTitle = 2
    case none = 4
}

protocol FilterCallBackProtocal {
    func applySortBy(selectedSort: SortType)
}

class FilterPopupViewController: UIViewController {

    @IBOutlet weak var checkBoxPrice: UIImageView!
    @IBOutlet weak var checkBoxDate: UIImageView!
    @IBOutlet weak var checkBoxTitle: UIImageView!
    private var selectedSort: SortType = .byTitle
    var delegate: FilterCallBackProtocal?
    let sortByDefault = UserDefaults.standard.integer(forKey: "sortByValue")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sortByAction(nil)
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        delegate?.applySortBy(selectedSort: selectedSort)
        dismiss(animated: true)
    }
    
    @IBAction func sortByAction(_ sender: UIButton?) {
        checkBoxDate.image = UIImage(named: "CheckBox")
        checkBoxPrice.image = UIImage(named: "CheckBox")
        checkBoxTitle.image = UIImage(named: "CheckBox")
        
        switch sender?.tag {
        case 0: //Date
            checkBoxDate.image = UIImage(named: "CheckBoxFill")
            selectedSort = .byDate
        case 1: //Price
            checkBoxPrice.image = UIImage(named: "CheckBoxFill")
            selectedSort = .byPrice
        case 2: //Title
            checkBoxTitle.image = UIImage(named: "CheckBoxFill")
            selectedSort = .byTitle
        default:
            if let sortByDefault = SortType(rawValue: sortByDefault){
                switch sortByDefault {
                case .byDate: //Date
                    checkBoxDate.image = UIImage(named: "CheckBoxFill")
                    selectedSort = .byDate
                case .byPrice: //Price
                    checkBoxPrice.image = UIImage(named: "CheckBoxFill")
                    selectedSort = .byPrice
                case .byTitle: //Title
                    checkBoxTitle.image = UIImage(named: "CheckBoxFill")
                    selectedSort = .byTitle
                default:
                    checkBoxTitle.image = UIImage(named: "CheckBoxFill")
                    selectedSort = .byTitle
                }
            }else{
                checkBoxTitle.image = UIImage(named: "CheckBoxFill")
                selectedSort = .byTitle
            }
        }
    }
    
}
