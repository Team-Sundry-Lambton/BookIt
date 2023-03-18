//
//  InitialDataDownload.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-16.
//

import Foundation
import Firebase
import CoreData
import FirebaseStorage

class InitialDataDownloadManager : NSObject{
    static let shared = InitialDataDownloadManager()
    let db = Firestore.firestore()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func DownloadAllData(){
        
        CoreDataManager.shared.deleteAllTables()
        GetAllCategoryData()
        GetAllClientData()
        GetAllVendorData()
        GetAllServiceData()
        GetAllAddressData()
        GetAllMediaData()
        
        GetAllBookingData()
        GetAllPaymentData()
        GetAllVendorReviewData()
    }
    
    func GetAllCategoryData(){
        db.collection("categories").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let category = Category(context: self.context)
                    category.name = data["name"] as? String ?? ""
                    category.picture =  data["picture"] as? String ?? ""
                    self.saveData()
                    
                }
            }
        }
    }
    
    func GetAllClientData(){
        db.collection("client").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let client = Client(context: self.context)
                    client.firstName = data["firstName"] as? String ?? ""
                    client.lastName =  data["lastName"] as? String ?? ""
                    client.email =  data["email"] as? String ?? ""
                    if let picture =  data["picture"] as? String{
                        client.picture = self.urlToData(path: picture)
                    }
                    client.contactNumber =  data["contactNumber"] as? String ?? ""
                    client.isPremium =  data["isPremium"] as? Bool ?? false
                    
                    self.saveData()
                }
            }
        }
    }
    
    func GetAllVendorData(){
        db.collection("vendor").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let vendor = Vendor(context: self.context)
                    vendor.firstName = data["firstName"] as? String ?? ""
                    vendor.lastName =  data["lastName"] as? String ?? ""
                    vendor.email =  data["email"] as? String ?? ""
                    if let picture =  data["picture"] as? String{
                        vendor.picture = self.urlToData(path: picture)
                    }
                    vendor.contactNumber =  data["contactNumber"] as? String ?? ""
                    vendor.bannerURL =  data["bannerURL"]  as? String ?? ""
                    
                    self.saveData()
                }
            }
        }
    }
    
    func GetAllServiceData(){
        db.collection("service").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let service = Service(context: self.context)
                    service.serviceTitle = data["serviceTitle"] as? String ?? ""
                    service.serviceDescription =  data["serviceDescription"] as? String ?? ""
                    service.cancelPolicy =  data["cancelPolicy"] as? String ?? ""
                    service.price =  data["price"] as? String ?? ""
                    service.priceType =  data["priceType"]  as? String ?? ""
                    service.equipment = data["equipment"]  as? Bool ?? false
                    let parentCategory = data["parentCategory"]  as? String ?? ""
                    let parentVendor = data["parentVendor"]  as? String ?? ""
                    let vendor = CoreDataManager.shared.getVendor(email: parentVendor)
                    service.parent_Vendor = vendor
                    
                    let category = CoreDataManager.shared.getCategory(name: parentCategory)
                    service.parent_Category = category
                    
                    self.saveData()
                    self.saveData()
                }
            }
        }
    }
    
    func GetAllAddressData(){
        db.collection("address").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let address = Address(context: self.context)
                    address.addressLongitude = data["longitude"] as? Double ?? 0
                    address.addressLatitude =  data["latitude"] as? Double ?? 0
                    address.address =  data["address"] as? String ?? ""
                    
                    if let parentService = data["parentService"]  as? String {
                        let service = CoreDataManager.shared.getService(title: parentService)
                        address.parentService = service
                    }
                    if let clientEmail = data["clientAddress"]  as? String {
                        let client = CoreDataManager.shared.getClient(email: clientEmail)
                        address.clientAddress = client
                    }
                    if let vendorEmail = data["vendorAddress"]  as? String {
                        let vendor = CoreDataManager.shared.getVendor(email: vendorEmail)
                        address.vendorAddress = vendor
                    }
                    self.saveData()
                }
            }
        }
    }
    
    func GetAllMediaData(){
        db.collection("media").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let media = MediaFile(context: self.context)
                    media.mediaName =  data["mediaName"] as? String ?? ""
                    if let picture =  data["mediaContent"] as? String{
                        media.mediaContent = self.urlToData(path: picture)
                    }
                    
                    let parentService = data["parentService"]  as? String ?? ""
                    let service = CoreDataManager.shared.getService(title: parentService)
                    media.parent_Service = service
                    self.saveData()
                }
            }
        }
    }
    
    func GetAllBookingData(){
        db.collection("booking").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func GetAllPaymentData(){
        db.collection("payment").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func GetAllVendorReviewData(){
        db.collection("payment").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func GetAllAccountData(){
        db.collection("account").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
}

extension InitialDataDownloadManager {
    
    func AddClientData(client : Client){
        var picturePath : String?
        var picture : String?
        if let imageData = client.picture {
            uploadMedia(name:client.email ?? "", media: imageData) { url in
                picturePath = url
                var ref: DocumentReference? = nil
                ref = self.db.collection("client").addDocument(data: [
                    "contactNumber": client.contactNumber ?? "",
                    "email": client.email ?? "",
                    "lastName": client.lastName ?? "",
                    "firstName": client.firstName ?? "",
                    "isPremium": client.isPremium,
                    "picture":  picturePath ?? "",
                    
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
    }
    
    func AddVendorData(vendor : Vendor){
        
        var picture : String?
        if let imageData = vendor.picture {
            uploadMedia(name:vendor.email ?? "", media: imageData) { url in
                var ref: DocumentReference? = nil
                ref = self.db.collection("vendor").addDocument(data: [
                    "contactNumber": vendor.contactNumber ?? "",
                    "email": vendor.email ?? "",
                    "lastName": vendor.lastName ?? "",
                    "firstName": vendor.firstName ?? "",
                    "bannerURL": vendor.bannerURL ?? "",
                    "picture": url ?? "",
                    
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
        
        
    }
    
    func AddServiceData(service : Service){
        
        if let media = service.medias {
            AddMediaData(media: media)
        }
        
        if let address = service.address {
            AddAddressData(address: address)
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("service").addDocument(data: [
            "cancelPolicy": service.cancelPolicy ?? "",
            "equipment": service.equipment,
            "price": service.price ?? "",
            "priceType": service.priceType ?? "",
            "serviceDescription": service.serviceDescription ?? "",
            "serviceTitle":  service.serviceTitle ?? "",
            "parentCategory":  service.parent_Category?.name ?? "",
            "parentVendor":  service.parent_Vendor?.email ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func AddAddressData(address: Address){
        var parentService : String?
        if let service = address.parentService {
            parentService = service.serviceTitle
        }
        var clientEmail : String?
        if let client = address.clientAddress {
            clientEmail = client.email
        }
        var vendorEmail : String?
        if let vendor = address.vendorAddress {
            vendorEmail = vendor.email
        }
        var ref: DocumentReference? = nil
        ref = db.collection("address").addDocument(data: [
            "longitude": address.addressLongitude,
            "latitude": address.addressLatitude,
            "address": address.address ?? "",
            "parentService": parentService ?? "",
            "clientAddress": clientEmail ?? "",
            "vendorAddress": vendorEmail ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func AddMediaData(media : MediaFile){
        var picture : String?
        if let imageData = media.mediaContent {
            uploadMedia(name:media.mediaName ?? "", media: imageData) { url in
                var ref: DocumentReference? = nil
                ref = self.db.collection("media").addDocument(data: [
                    "mediaName": media.mediaName ?? "",
                    "mediaContent": url ?? "",
                    "parentService": media.parent_Service?.serviceTitle ?? "",
                    
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
        
        
    }
    
    func AddBookingData(){
        db.collection("booking").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func AddPaymentData(){
        db.collection("payment").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func AddVendorReviewData(){
        db.collection("payment").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func AddAccountData(){
        db.collection("account").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func uploadMedia(name : String,media : Data,completion: @escaping (_ url: String?) -> Void) {
        let storageRef = Storage.storage().reference().child(name)
        storageRef.putData(media, metadata: nil
                           , completion: { (metadata, error) in
            //                self.hideActivityIndicator(view: self.view)
            if error != nil {
                
                completion(nil)
            }
            else{
                storageRef.downloadURL(completion: { (url, error) in
                    print("Image URL: \((url?.absoluteString)!)")
                    completion(url?.absoluteString)
                })
            }
        })
    }
}

extension InitialDataDownloadManager{
    
    func UpdateClientData(client : Client){
        var picturePath : String?
        if let imageData = client.picture {
            uploadMedia(name:client.email ?? "", media: imageData) { url in
                picturePath = url
                if let email = client.email{
                    self.db.collection("client")
                        .whereField("email", isEqualTo: email)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                // Some error occured
                            } else if querySnapshot!.documents.count != 1 {
                                // Perhaps this is an error for you?
                            } else {
                                if let number = client.contactNumber,let lastName = client.lastName,let firstName = client.firstName{
                                    if let document = querySnapshot!.documents.first{
                                        document.reference.updateData([
                                            "contactNumber": number,
                                            "email": email,
                                            "lastName": lastName,
                                            "firstName": firstName,
                                            "isPremium": client.isPremium,
                                            "picture": picturePath ?? "",
                                        ])
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func UpdateVendorData(vendor : Vendor){
        var picturePath : String?
        if let imageData = vendor.picture {
            uploadMedia(name:vendor.email ?? "", media: imageData) { url in
                picturePath = url
                if let email = vendor.email{
                    self.db.collection("client")
                        .whereField("email", isEqualTo: email)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                // Some error occured
                            } else if querySnapshot!.documents.count != 1 {
                                // Perhaps this is an error for you?
                            } else {
                                if let number = vendor.contactNumber,let lastName = vendor.lastName,let firstName = vendor.firstName {
                                    if let document = querySnapshot!.documents.first{
                                        document.reference.updateData([
                                            "contactNumber": number,
                                            "email": email,
                                            "lastName": lastName,
                                            "firstName": firstName,
                                            "bannerURL": vendor.bannerURL,
                                            "picture": picturePath ?? "",
                                        ])
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func UpdateLocation(addressObject : Address){
        
        var parentService : String?
        if let service = addressObject.parentService {
            parentService = service.serviceTitle
        }
        var clientEmail : String?
        if let client = addressObject.clientAddress {
            clientEmail = client.email
        }
        var vendorEmail : String?
        if let vendor = addressObject.vendorAddress {
            vendorEmail = vendor.email
        }
        
        if let address = addressObject.address {
            db.collection("address")
                .whereField("parentService", isEqualTo: address)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        // Some error occured
                    } else if querySnapshot!.documents.count != 1 {
                        // Perhaps this is an error for you?
                    } else {
                            if let document = querySnapshot!.documents.first{
                                document.reference.updateData([
                                    "longitude": addressObject.addressLongitude,
                                    "latitude": addressObject.addressLatitude,
                                    "address": address,
                                    "parentService": parentService ?? "",
                                    "clientAddress": clientEmail ?? "",
                                    "vendorAddress": vendorEmail ?? "",
                                ])
                            }
                    }
                }
        }
    }
}

extension InitialDataDownloadManager {
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func urlToData(path : String) -> Data?{
        if let url = URL(string: path) {
            do {
                let imageData = try Data(contentsOf: url as URL)
                return imageData
            } catch {
                print("Unable to load data: \(error)")
            }
        }
        return nil
    }
}


//extension UIImage {
//    var base64: String? {
//        self.jpegData(compressionQuality: 1)?.base64EncodedString()
//    }
//}
//
//extension String {
//    var imageFromBase64: UIImage? {
//        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
//            return nil
//        }
//        return UIImage(data: imageData)
//    }
//}


