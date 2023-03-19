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
    
    func downloadAllData(){
        
        CoreDataManager.shared.deleteAllTables()
        getAllCategoryData()
        getAllClientData()
        getAllVendorData()
        getAllServiceData()
        getAllAddressData()
        getAllMediaData()
        
        getAllBookingData()
        getAllPaymentData()
        getAllVendorReviewData()
    }
    
    func getAllCategoryData(){
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
    
    func getAllClientData(){
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
    
    func getAllVendorData(){
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
    
    func getAllServiceData(){
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
//                    let parentCategory = data["parentCategory"]  as? String ?? ""
//                    let parentVendor = data["parentVendor"]  as? String ?? ""

                    if let parentVendor = data["parentVendor"]  as? String {
                        if parentVendor != "" {
                            let vendor = CoreDataManager.shared.getVendor(email: parentVendor)
                            service.parent_Vendor = vendor
                        }
                    }
                    
                        if let parentCategory = data["parentCategory"]  as? String {
                            if parentCategory != "" {
                                let category = CoreDataManager.shared.getCategory(name: parentCategory)
                                service.parent_Category = category
                            }
                        }
                    
                    self.saveData()
                }
            }
        }
    }
    
    func getAllAddressData(){
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
                        if parentService != "" {
                            let service = CoreDataManager.shared.getService(title: parentService)
                            address.parentService = service
                        }
                    }
                    if let clientEmail = data["clientAddress"]  as? String {
                        if clientEmail != "" {
                            let client = CoreDataManager.shared.getClient(email: clientEmail)
                            address.clientAddress = client
                        }
                    }
                    if let vendorEmail = data["vendorAddress"]  as? String {
                        if vendorEmail != "" {
                            let vendor = CoreDataManager.shared.getVendor(email: vendorEmail)
                            address.vendorAddress = vendor
                        }
                    }
                    self.saveData()
                }
            }
        }
    }
    
    func getAllMediaData(){
        db.collection("media").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let media = MediaFile(context: self.context)
                    media.mediaName =  data["mediaName"] as? String ?? ""
                    media.mediaPath =  data["mediaPath"] as? String ?? ""
                    if let picture =  data["mediaContent"] as? String{
                        media.mediaContent = self.urlToData(path: picture)
                    }
                    
                    if let parentService = data["parentService"]  as? String {
                        if parentService != "" {
                            let service = CoreDataManager.shared.getService(title: parentService)
                            media.parent_Service = service
                        }
                    }
                    self.saveData()
                }
            }
        }
    }
    
    func getAllBookingData(){
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
    
    func getAllPaymentData(){
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
    
    func getAllVendorReviewData(){
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
    
    func getAllAccountData(){
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
    
    func addClientData(client : Client){
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
                        CoreDataManager.shared.deleteClients()
                        self.getAllClientData()
                    }
                }
            }
        }
    }
    
    func addVendorData(vendor : Vendor){
        
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
                        CoreDataManager.shared.deleteVendors()
                        self.getAllVendorData()
                    }
                }
            }
        }
    }
    
    func addServiceData(service : Service){
        
        if let media = service.medias {
            self.updateMedia(media: media)
        }
        
        if let address = service.address {
            addAddressData(address: address)
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
    
    func addAddressData(address: Address){
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
    
    func addMediaData(media : MediaFile){

        if let imageData = media.mediaContent {
            uploadMedia(name:media.mediaName ?? "", media: imageData) { url in
                var ref: DocumentReference? = nil
                ref = self.db.collection("media").addDocument(data: [
                    "mediaName": media.mediaName ?? "",
                    "mediaContent": url ?? "",
                    "mediaPath": url ?? "",
                    "parentService": media.parent_Service?.serviceTitle ?? "",
                    
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        let media = CoreDataManager.shared.getMedia(name: media.mediaName ?? "", serviceTitle: media.parent_Service?.serviceTitle ?? "")
                        media?.mediaPath = url
                        self.saveData()
                    }
                }
            }
        }
    }
    
    func addBookingData(){
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
    
    func addPaymentData(){
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
    
    func addVendorReviewData(){
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
    
    func addAccountData(){
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
    
    func updateClientData(client : Client){
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
    
    func updateVendorData(vendor : Vendor){
        var picturePath : String?
        if let imageData = vendor.picture {
            uploadMedia(name:vendor.email ?? "", media: imageData) { url in
                picturePath = url
                if let email = vendor.email{
                    self.db.collection("vendor")
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
    
    func updateAddressData(addressObject : Address){
        if let address = addressObject.address {
            var filterField = ""
            var filterText = ""
            var parentService : String?
            if let service = addressObject.parentService {
                parentService = service.serviceTitle
                filterField = "parentService"
                filterText = parentService ?? address
            }
            var clientEmail : String?
            if let client = addressObject.clientAddress {
                clientEmail = client.email
                filterField = "clientAddress"
                filterText = clientEmail ?? address
            }
            var vendorEmail : String?
            if let vendor = addressObject.vendorAddress {
                vendorEmail = vendor.email
                filterField = "vendorAddress"
                filterText = vendorEmail ?? address
            }
            
            db.collection("address")
                .whereField(filterField, isEqualTo: filterText)
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
        
        func updateMedia(media : MediaFile){
            db.collection("media")
                .whereField("mediaName", isEqualTo: media.mediaName)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        // Some error occured
                    } else if querySnapshot!.documents.count != 1 {
                        // Perhaps this is an error for you?
                    } else {
                            if let document = querySnapshot!.documents.first{
                                document.reference.updateData([
                                    "parentService": media.parent_Service?.serviceTitle ?? "",
                                ])
                            }
                    }
                }
        }
}

extension InitialDataDownloadManager{
    func deleteMediaData(media : MediaFile){
        if let imagePath = media.mediaPath {
            deleteMedia(downloadURL:imagePath) { status in
                self.db.collection("media").whereField("mediaPath", isEqualTo: imagePath).getDocuments(){ (querySnapshot, err) in
                        if let err = err {
                            // Some error occured
                        } else if querySnapshot!.documents.count != 1 {
                            // Perhaps this is an error for you?
                        } else {
                                if let document = querySnapshot!.documents.first{
                                    document.reference.delete()
                                }
                        }
                    }
                }
            }
        }
    
    func deleteMedia(downloadURL : String,completion: @escaping (_ status: Bool?) -> Void) {
        
        let storage = Storage.storage()
        let url = downloadURL
        let storageRef = storage.reference(forURL: url)

        //Removes image from storage
        storageRef.delete { error in
            if let error = error {
                completion(false)
            } else {
                completion(true)
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


