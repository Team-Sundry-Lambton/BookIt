//
//  ClientBookVendorViewController.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-22.
//

import UIKit
import CoreData
import JGProgressHUD

class ClientBookVendorViewController: UIViewController {
    
    var selectedService: Service?
    var vendor : Vendor?
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var priceTextField: UIButton!
    @IBOutlet weak var btnImmediately: CustomRadioButton!
    @IBOutlet weak var btnAccordingToMe: CustomRadioButton!
    @IBOutlet weak var describeProblemTextView: BorderTextView!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        btnImmediately.isSelected = true
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
        datePicker.minimumDate = Date()
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
        timePicker.minimumDate = Date()
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
        validateBookingData()
    }
    
    func validateBookingData(){
        var finalDate = Date()
        if btnAccordingToMe.isSelected == true{
            // Validate the text fields
            
            guard let dateText = dateTextField.text, !dateText.isEmpty else {
                showErrorMessage("Please choose date")
                return
            }
            guard let timeText = timeTextField.text, !timeText.isEmpty else {
                showErrorMessage("Please choose time")
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let dateString = dateText
            guard let date = dateFormatter.date(from: dateString) else {
                // Handle the case where the date string couldn't be parsed
                return
            }

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm:ss a"
            let timeString = timeText
            guard let time = timeFormatter.date(from: timeString) else {
                // Handle the case where the time string couldn't be parsed
                return
            }

            // Combine the date and time components
            let calendar = Calendar.current
            let finalDate = calendar.date(bySettingHour: calendar.component(.hour, from: time), minute: calendar.component(.minute, from: time), second: 0, of: date)

        }
        
        let description = describeProblemTextView.text ?? ""
        saveBooking(date: finalDate, description: description)
        
    }
    
    func getVendor(){
        if let user =  selectedService?.parent_Vendor {
            if let email = user.email {
                vendor = CoreDataManager.shared.getVendor(email: email)
            }
        }
    }
    
    func saveBooking(date: Date, description: String){
           var booking = Booking(context: context)
            booking.date = date
            booking.problemDescription = describeProblemTextView.text
            booking.status = "New"
            booking.service = selectedService
            getVendor()
            booking.vendor = vendor
            let user =  UserDefaultsManager.shared.getUserData()
            booking.client = CoreDataManager.shared.getClient(email: user.email)
                let hud = JGProgressHUD()
                hud.textLabel.text = "Booking..."
                hud.show(in: self.view)
                Task {
                    await InitialDataDownloadManager.shared.addBookingData(booking:booking){ status in
                        DispatchQueue.main.async {
                            hud.dismiss(animated: true)
                            if let status = status {
                                if status {
                                    self.saveAllContextCoreData()
                                }else{
                                    UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
                                }
                            }
                        }
                    }
                    
                }
        }
        
        private func saveAllContextCoreData() {
            do {
                try context.save()
                showAlert()
            } catch {
                print("Error saving the data \(error.localizedDescription)")
            }
        }
        
        private func showAlert(){
        
            var message = "Successfully Booked.."
        
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default){
                    UIAlertAction in
                    if let navigator = self.navigationController {
                        navigator.popViewController(animated: true)
                    }else{
                        self.dismiss(animated: true)
                    }
                }
                controller.addAction(okAction)
                return controller
            }()
            self.present(alertController, animated: true)
        }
    
    func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    

}
