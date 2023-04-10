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
    func applySortBy(selectedSort: SortType, isAsc: Bool)
}

class FilterPopupViewController: UIViewController {

    @IBOutlet weak var checkBoxPrice: UIImageView!
    @IBOutlet weak var checkBoxDate: UIImageView!
    @IBOutlet weak var checkBoxTitle: UIImageView!
    @IBOutlet weak var sortByImg: UIImageView!
    var selectedSort: SortType?
    var isAsc: Bool?
    var delegate: FilterCallBackProtocal?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sortByAction(nil)
        if let isAsc = isAsc{
            if isAsc{
                sortByImg.image = UIImage(named: "sort_asc")
            }else{
                sortByImg.image = UIImage(named: "sort_desc")
            }
        }
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        if let selectedSort = selectedSort, let isAsc = isAsc{
            delegate?.applySortBy(selectedSort: selectedSort, isAsc: isAsc)
        }
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
            if let selectedSort = selectedSort{
                switch selectedSort {
                case .byDate: //Date
                    checkBoxDate.image = UIImage(named: "CheckBoxFill")
                case .byPrice: //Price
                    checkBoxPrice.image = UIImage(named: "CheckBoxFill")
                case .byTitle: //Title
                    checkBoxTitle.image = UIImage(named: "CheckBoxFill")
                default:
                    checkBoxTitle.image = UIImage(named: "CheckBoxFill")
                }
            }else{
                checkBoxTitle.image = UIImage(named: "CheckBoxFill")
            }
        }
    }
    
    
    @IBAction func sortByImgTapped(_ sender: UITapGestureRecognizer) {
        if sortByImg.image == UIImage(named: "sort_asc") {
            isAsc = false
            sortByImg.image = UIImage(named: "sort_desc")
        } else {
            isAsc = true
            sortByImg.image = UIImage(named: "sort_asc")
        }
    }
    
    
    
}
