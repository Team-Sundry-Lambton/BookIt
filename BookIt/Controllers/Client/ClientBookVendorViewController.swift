//
//  ClientBookVendorViewController.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-22.
//

import UIKit
import CoreData

protocol ClientBookVendorProtocol {
    func backFromBookingComfirm()
}

class ClientBookVendorViewController: NavigationBaseViewController, UITextViewDelegate {
    
    var selectedService: Service?
    var vendor : Vendor?
    var selectedBooking : Booking?
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var priceTextField: UIButton!
    @IBOutlet weak var btnImmediately: CustomRadioButton!
    @IBOutlet weak var btnAccordingToMe: CustomRadioButton!
    @IBOutlet weak var describeProblemTextView: BorderTextView!

    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    var placeholderText = "Describe the problem"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        createTimePicker()
        customDesign()

        // Do any additional setup after loading the view.
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
        describeProblemTextView.delegate = self
        // Set the placeholder text
        describeProblemTextView.text = placeholderText
        describeProblemTextView.textColor = UIColor.lightGray
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
            finalDate = calendar.date(bySettingHour: calendar.component(.hour, from: time), minute: calendar.component(.minute, from: time), second: 0, of: date) ?? Date()
        }
        
        let description = describeProblemTextView.text ?? ""
        saveBooking(selectedDate: finalDate, description: description)
        
    }
    
    func getVendor(){
        if let user =  selectedService?.parent_Vendor {
            if let email = user.email {
                vendor = CoreDataManager.shared.getVendor(email: email)
            }
        }
    }
    
    func saveBooking(selectedDate: Date, description: String){
        var booking = Booking(context: context)
        if let bookingId = selectedBooking?.bookingId{
            if let selectedBooking = CoreDataManager.shared.fetchSelectedBooking(bookingId: bookingId){
                booking = selectedBooking
                booking.date = selectedDate
                booking.problemDescription = describeProblemTextView.text
                LoadingHudManager.shared.showSimpleHUD(title: "Rescheduling...", view: self.view)
                Task {
                    InitialDataDownloadManager.shared.updateBookingData(booking:booking){ [weak self] status in
                        DispatchQueue.main.async {
                            LoadingHudManager.shared.dissmissHud()
                            guard let strongSelf = self else {
                                return
                            }
                            if let status = status {
                                if status {
                                    strongSelf.saveAllContextCoreData()
                                    strongSelf.showAlert(title: "Service Rescheduled!", message: "The previously scheduled service appointment has been rescheduled to a new date or time")
                                }else{
                                    UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: strongSelf)
                                }
                            }
                        }
                    }
                    
                }
            }
        }else{
            booking.bookingId  = CoreDataManager.shared.getBookingID()
            booking.date = selectedDate
            booking.problemDescription = describeProblemTextView.text
            booking.status = "New"
            booking.service = selectedService
            getVendor()
            booking.vendor = vendor
            let user =  UserDefaultsManager.shared.getUserData()
            booking.client = CoreDataManager.shared.getClient(email: user.email)
            LoadingHudManager.shared.showSimpleHUD(title: "Booking...", view: self.view)
            Task {
                 InitialDataDownloadManager.shared.addBookingData(booking:booking){ [weak self] status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        guard let strongSelf = self else {
                            return
                        }
                        if let status = status {
                            if status {
                                strongSelf.saveAllContextCoreData()
                                strongSelf.showAlert(title: "Service Booked!", message: "Your service appointment has been successfully booked")
                            }else{
                                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: strongSelf)
                            }
                        }
                    }
                }
                
            }
        }
    }
        
    private func saveAllContextCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
        
    private func showAlert(title: String, message: String){
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default){
                UIAlertAction in
                let storyboard = UIStoryboard(name: "ClientBookingConfirmation", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ClientBookingConfirmation") as! ClientBookingConfirmationViewController
                vc.modalPresentationStyle = .fullScreen
                vc.delegate = self
                if let navigator = self.navigationController {
                    navigator.pushViewController(vc, animated: true)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Check if the text view's text matches the placeholder text
        if textView.text == "Describe the problem" {
            // Clear the text view
            textView.text = ""
            textView.textColor = UIColor.black
        }else{
            
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        // Check if the text view's text is empty
        if textView.text.isEmpty {
            // Set the placeholder text
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            textView.selectedRange = NSMakeRange(0, 0) // Remove cursor
        }
    }
}

extension ClientBookVendorViewController: ClientBookVendorProtocol {
    func backFromBookingComfirm() {
        self.tabBarController?.selectedIndex = 2
    }
}
