//
//  ClientBookVendorViewController.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-22.
//

import UIKit

class ClientBookVendorViewController: UIViewController {
    
    var selectedService: Service?
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var priceTextField: UIButton!
    @IBOutlet weak var btnImmediately: CustomRadioButton!
    @IBOutlet weak var btnAccordingToMe: CustomRadioButton!
    @IBOutlet weak var describeProblemTextView: BorderTextView!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        createTimePicker()
        customDesign()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
    }
    

    func customDesign(){
        let titleLabel = UILabel()
        if let service = selectedService{
            titleLabel.text = service.serviceTitle
        }
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        if let price = selectedService?.price, let priceType = selectedService?.priceType {
            priceTextField.setTitle("Total: $\(price)/ \(priceType)", for: .normal)
        } else {
            priceTextField.setTitle("N/A", for: .normal)
        }
    }
    
    func createDatePicker(){
        
        // toolbar
        let toolbar =  UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneDateBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDonePressed))
        toolbar.setItems([doneDateBtn], animated: true)
        // assign toolbar
        dateTextField.inputAccessoryView = toolbar
        
        // assign datepicker to the text field
        datePicker.datePickerMode = .date
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        dateTextField.inputView = datePicker
        
    }
    
    func createTimePicker(){
        
        // toolbar
        let toolbar =  UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneDateBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(timeDonePressed))
        toolbar.setItems([doneDateBtn], animated: true)
        // assign toolbar
        timeTextField.inputAccessoryView = toolbar
        
        // assign datepicker to the text field
        timePicker.datePickerMode = .time
        timePicker.frame.size = CGSize(width: 0, height: 300)
        timePicker.preferredDatePickerStyle = .wheels
        timeTextField.inputView = timePicker
        
    }
    
    @objc func dateDonePressed(){
        //formatter
        let formatter =  DateFormatter()
        formatter.dateStyle =  .medium
        formatter.timeStyle = .none
        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func timeDonePressed(){
        //formatter
        let formatter =  DateFormatter()
        formatter.timeStyle =  .medium
        formatter.dateStyle = .none
        timeTextField.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }
    
    
    @IBAction func radioBtnImmediately(_ sender: UIButton) {
        btnAccordingToMe.isSelected = false
        sender.isSelected = true
        
        // hide date and time fields
        dateTextField.isHidden = true
        timeTextField.isHidden = true
    }
    
    @IBAction func radioBtnAccordingToMe(_ sender: UIButton) {
        btnImmediately.isSelected = false
        sender.isSelected = true
        
        // unhide date and time fields
        dateTextField.isHidden = false
        timeTextField.isHidden = false
    }
    
    
    @IBAction func requestBtnPressed() {
        
    }
    

}
