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
    var selectedLocation: Address?
    weak var delegate: ClientHomeViewController!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentAddress : PlaceObject?
    var client : Client?
    var openMap = false
    override func viewDidLoad() {
        super.viewDidLoad()
        getClient()
        uiViewsDesign()
        if let address = currentAddress{
            addressLbl.text = address.title
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if openMap {
            delegate?.openSelectedLocation()
        }
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
            openMap = true
            self.dismiss(animated: true)
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first to continue. Please go to profile tab for register", okActionTitle: "OK", view: self)
        }
    }
    
    @IBAction func confirmLocation() {
      
        if (UserDefaultsManager.shared.getUserLogin()){
            if (checkLocationInDB(place: currentAddress)){
                deleteLocation(place: currentAddress)
                setLocationObject(isUpdate: true)
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "Location updated successfully.", okActionTitle: "OK", view: self)
                
            }else{
                
                setLocationObject(isUpdate: false)
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "Location save successfully.", okActionTitle: "OK", view: self)
            }
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first to continue. Please go to profile tab for register", okActionTitle: "OK", view: self)
        }
    }
    
    //MARK: - Core data interaction methods
    func setLocationObject(isUpdate : Bool) {
        var selectedLocation = Address(context: context)
        selectedLocation.addressLatitude = currentAddress?.coordinate.latitude ?? 0
        selectedLocation.addressLongitude = currentAddress?.coordinate.longitude ?? 0
        selectedLocation.address = currentAddress?.title
        selectedLocation.clientAddress = client
        saveLocation()
        if isUpdate {
            InitialDataDownloadManager.shared.updateAddressData(addressObject: selectedLocation){ status in
                DispatchQueue.main.async {
                    if let status = status{
                        if status == false {
                            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
                        }
                    }
                }
            }
        }else{
            InitialDataDownloadManager.shared.addAddressData(address: selectedLocation){ status in
                DispatchQueue.main.async {
                    if let status = status{
                        if status == false {
                            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
                        }
                    }
                }
                
            }
        }
    }
    
    func getClient(){

        let user =  UserDefaultsManager.shared.getUserData()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Client")
        fetchRequest.predicate = NSPredicate(format: "email = %@", user.email)
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
            fetchRequest.predicate = NSPredicate(format: "clientAddress.email = %@",client?.email ?? "")
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
            fetchRequest.predicate = NSPredicate(format: "clientAddress.email = %@", client?.email ?? "")
        }
        do {
            let location = try context.fetch(fetchRequest)
            if location.count >= 1 {
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
// MARK: - MapViewDelegate
extension ConfirmLocationViewController: MapViewDelegate {
    
    private func openMapView() {
        let mapViewController:MapViewController = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        mapViewController.delegate = self
        mapViewController.selectLocation = true
        let navController = UINavigationController(rootViewController: mapViewController) //Add navigation controller
            navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
        
   //        navigationController?.pushViewController(navController, animated: true)
    }
    
    func setServiceLocation(place : PlaceObject){
        selectedLocation = Address(context: context)
        selectedLocation?.addressLatitude = place.coordinate.latitude
        selectedLocation?.addressLongitude = place.coordinate.longitude
        selectedLocation?.address = place.title
        addressLbl.text = place.title
    }
}
