//
//  TransactionTableViewCell.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-23.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var clientNameLabel: UILabel!
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    
    @IBOutlet weak var bankAccountLabel: UILabel!
    
    @IBOutlet weak var totalIncomeLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
