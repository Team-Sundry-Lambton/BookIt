//
//  ConfirmLocationViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-12.
//

import UIKit
import CoreData

class ConfirmLocationViewController: UIViewController {

    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentAddress : PlaceObject?
    var client : Client?
    override func viewDidLoad() {
        super.viewDidLoad()
        getClient()
        uiViewsDesign()
        if let address = currentAddress{
            addressLbl.text = address.title
        }
        // Do any additional setup after loading the view.
    }
    
    func uiViewsDesign() {
        editBtn.layer.borderColor = UIColor.switchBackgroundColor.cgColor
        editBtn.layer.masksToBounds = true
        editBtn.layer.borderWidth = 1
        editBtn.layer.cornerRadius = editBtn.frame.height / 2
        
        confirmBtn.layer.backgroundColor = UIColor.switchBackgroundColor.cgColor
        confirmBtn.layer.masksToBounds = true
        confirmBtn.layer.cornerRadius = editBtn.frame.height / 2
    }
    @IBAction func editLocation() {
        if (UserDefaultsManager.shared.getUserLogin()){
            
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first to continue. Please go to profile tab for register", okActionTitle: "OK", view: self)
        }
    }
    
    @IBAction func confirmLocation() {
      
        if (UserDefaultsManager.shared.getUserLogin()){
            if (checkLocationInDB(place: currentAddress)){
                deleteLocation(place: currentAddress)
                setLocationObject()
                saveLocation()
                
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "Location updated successfully.", okActionTitle: "OK", view: self)
                
            }else{
                
                setLocationObject()
                saveLocation()
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "Location save successfully.", okActionTitle: "OK", view: self)
            }
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first to continue. Please go to profile tab for register", okActionTitle: "OK", view: self)
        }
    }
    
    //MARK: - Core data interaction methods
    func setLocationObject(){
        var selectedLocation = Address(context: context)
        selectedLocation.latitude = currentAddress?.coordinate.latitude ?? 0
        selectedLocation.longitude = currentAddress?.coordinate.longitude ?? 0
        selectedLocation.address = currentAddress?.title
        selectedLocation.clientAddress = client
    }
    
    func getClient(){

        let user =  UserDefaultsManager.shared.getUserData()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Client")
        fetchRequest.predicate = NSPredicate(format: "email = %@ ", user.email)
        do {
            let users = try context.fetch(fetchRequest)
            client = users.first as? Client
        } catch {
            print(error)
        }
    }
    
    func deleteLocation(place : PlaceObject?) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Address")
        if let currentPlace = place{
            fetchRequest.predicate = NSPredicate(format: "address = %@ ", currentPlace.title ?? "")
        }
        do {
            let location = try context.fetch(fetchRequest)
            if let slectedLocation = location.first as? NSManagedObject {
                context.delete(slectedLocation)
            }
        } catch {
            print(error)
        }
    }
    
    func checkLocationInDB(place: PlaceObject?)-> Bool{
        var success = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Address")
        if let currentPlace = place{
            fetchRequest.predicate = NSPredicate(format: "address = %@ ", currentPlace.title ?? "")
        }
        do {
            let location = try context.fetch(fetchRequest)
            if location.count == 1 {
                success = true
            }
        } catch {
            print(error)
        }
        return success
    }
    
    func saveLocation() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
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
