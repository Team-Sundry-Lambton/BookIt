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
    
    func downloadAllData(completion: @escaping () -> Void)  async{
        
        CoreDataManager.shared.deleteAllTables()

           await getAllCategoryData()
            await getAllClientData()
            await getAllVendorData()
            await getAllServiceData()
            await getAllAddressData()
            await getAllMediaData()
            await getAllBookingData()
            await getAllPaymentData()
           
            await getAllVendorReviewData()
        
        completion()
    }
    
    func getAllCategoryData() async{
        do {
            let snapshot = try await db.collection("categories").getDocuments()
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let category = Category(context: self.context)
                category.name = data["name"] as? String ?? ""
                category.picture =  data["picture"] as? String ?? ""
                self.saveData()
            }
        }
        catch{
            print("Error loading location data \(error.localizedDescription)")
        }
    }
    
    func getAllClientData() async{
        do {
            let snapshot = try await db.collection("client").getDocuments();  snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
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
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }
    }
    
    func getAllVendorData() async{
        do {
            let snapshot = try await db.collection("vendor").getDocuments(); snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
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
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }
    }
    
    func getAllServiceData() async{
        do {
            let snapshot = try await  db.collection("service").getDocuments()
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let service = Service(context: self.context)
                service.serviceTitle = data["serviceTitle"] as? String ?? ""
                service.serviceDescription =  data["serviceDescription"] as? String ?? ""
                service.cancelPolicy =  data["cancelPolicy"] as? String ?? ""
                service.price =  data["price"] as? String ?? ""
                service.priceType =  data["priceType"]  as? String ?? ""
                service.equipment = data["equipment"]  as? Bool ?? false
  
                if let parentVendor = data["parentVendor"]  as? String {
                    if parentVendor != "" {
                        if  let vendor = CoreDataManager.shared.getVendor(email: parentVendor){
                            service.parent_Vendor = vendor
                        }
                    }
                }
                
                if let parentCategory = data["parentCategory"]  as? String {
                    if parentCategory != "" {
                        if let category = CoreDataManager.shared.getCategory(name: parentCategory){
                            service.parent_Category = category
                        }
                    }
                }
                
                self.saveData()
            }
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }
    }
    
    func getAllAddressData()async{
        do {
            let snapshot = try await db.collection("address").getDocuments() ; snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let address = Address(context: self.context)
                address.addressLongitude = data["longitude"] as? Double ?? 0
                address.addressLatitude =  data["latitude"] as? Double ?? 0

                address.address =  data["address"] as? String ?? ""
                
                if let parentService = data["parentService"]  as? String {
                    if parentService != "" {
                        if let service = CoreDataManager.shared.getService(title: parentService){
                            address.parentService = service
                        }
                    }
                }
                if let clientEmail = data["clientAddress"]  as? String {
                    if clientEmail != "" {
                        if let client = CoreDataManager.shared.getClient(email: clientEmail){
                            address.clientAddress = client
                        }
                    }
                }
                if let vendorEmail = data["vendorAddress"]  as? String {
                    if vendorEmail != "" {
                        if let vendor = CoreDataManager.shared.getVendor(email: vendorEmail){
                            address.vendorAddress = vendor
                        }
                    }
                }
                self.saveData()
            }
            }catch{
                print("Error loading location data \(error.localizedDescription)")
            }
        }
    
    func getAllMediaData()async{
        do {
            let snapshot = try await db.collection("media").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let media = MediaFile(context: self.context)
                media.mediaName =  data["mediaName"] as? String ?? ""
                media.mediaPath =  data["mediaPath"] as? String ?? ""
                if let picture =  data["mediaContent"] as? String{
                    media.mediaContent = self.urlToData(path: picture)
                }
                
                if let parentService = data["parentService"]  as? String {
                    if parentService != "" {
                        if let service = CoreDataManager.shared.getService(title: parentService){
                            media.parent_Service = service
                        }
                    }
                }
                self.saveData()
            }
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }
    }
    
    func getAllBookingData()async{
        do {
            let snapshot = try await db.collection("booking").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let boobking = Booking(context: self.context)
                boobking.date =  data["date"] as? Date
                boobking.status =  data["status"] as? String ?? ""

                
                if let parentService = data["parentService"]  as? String {
                    if parentService != "" {
                        if let service = CoreDataManager.shared.getService(title: parentService){
                            boobking.service = service
                        }
                        
//                        if let amount = data["amount"]  as? Double {
//                            let payment = CoreDataManager.shared.getPayment(amount: amount, serviceTitle:service?.serviceTitle ?? "" )
//                                boobking.payment = payment
//                        }
                    }
                }
                
                if let clientEmail = data["clientAddress"]  as? String {
                    if clientEmail != "" {
                        if let client = CoreDataManager.shared.getClient(email: clientEmail){
                            boobking.client = client
                        }
                    }
                }
                if let vendorEmail = data["vendorAddress"]  as? String {
                    if vendorEmail != "" {
                        if let vendor = CoreDataManager.shared.getVendor(email: vendorEmail){
                            boobking.vendor = vendor
                        }
                    }
                }
                
                self.saveData()
            }
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }

    }
    
    func getAllPaymentData()async{
        do {
            let snapshot = try await db.collection("payment").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let payment = Payment(context: self.context)
                payment.amount =  data["amount"] as? Double ?? 0
                payment.date =  data["date"] as? Date
                payment.status =  data["status"] as? String ?? ""
                
                if let client = data["clientAddress"]  as? String, let vendor = data["vendorAddress"]  as? String, let serviceTitle = data["serviceTitle"]  as? String  {
                    if client != ""  && vendor != ""  && serviceTitle != "" {
                        if let booking = CoreDataManager.shared.getBooking(client: client, serviceTitle: serviceTitle, vendor: vendor){
                            payment.booking = booking
                        }
                    }
                }
                self.saveData()
            }
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }

    }
    
    func getAllVendorReviewData()async{
        do {
            let snapshot = try await db.collection("vendorReview").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let review = VendorReview(context: self.context)
                review.comment =  data["comment"] as? String ?? ""
                review.date =  data["date"] as? Date
                review.rating = Int16(data["rating"] as? Int ?? 0)
                if let clientEmail = data["clientAddress"]  as? String {
                    if clientEmail != "" {
                        if let client = CoreDataManager.shared.getClient(email: clientEmail){
                            review.client = client
                        }
                    }
                }
                if let vendorEmail = data["vendorAddress"]  as? String {
                    if vendorEmail != "" {
                        if let vendor = CoreDataManager.shared.getVendor(email: vendorEmail){
                            review.vendor = vendor
                        }
                    }
                }
                self.saveData()
            }
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }

    }
    
    func getAllAccountData() async{
        do {
            let snapshot = try await db.collection("account").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let account = Account(context: self.context)
                account.recipiantName =  data["recipiantName"] as? String ?? ""
                account.recipiantBankName =  data["recipiantBankName"] as? String ?? ""
                account.accountNumber = Int32(data["accountNumber"] as? Int ?? 0)
                account.institutionNumber = Int32(data["institutionNumber"] as? Int ?? 0)
                account.transitNumber = Int32(data["transitNumber"] as? Int ?? 0)

                if let vendorEmail = data["vendorAddress"]  as? String {
                    if vendorEmail != "" {
                        if let vendor = CoreDataManager.shared.getVendor(email: vendorEmail){
                            account.parent_vendor = vendor
                        }
                    }
                }
                self.saveData()
            }
        }catch{
            print("Error loading location data \(error.localizedDescription)")
        }
    }
}

extension InitialDataDownloadManager {
    
    func addClientData(client : Client,completion: @escaping (_ status: Bool?) -> Void){
        var picturePath : String?

        if let imageData = client.picture {
            var ref: DocumentReference? = nil
            self.db.collection("client")
                .whereField("email", isEqualTo: client.email ?? "")
                .getDocuments(){ (document, error) in
                    if let document = document {
                        if document.count >= 1 {
                            completion(true)
                        }else{
                            self.uploadMedia(name:client.email ?? "", media: imageData) { url in
                                picturePath = url
                               
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
                                        completion(false)
                                    } else {
                                        print("Document added with ID: \(ref!.documentID)")
                                        CoreDataManager.shared.deleteClients()
                                        Task { await self.getAllClientData() }
                                        completion(true)
                                    }
                                }
                            }
                        }
                    }else{
                        self.uploadMedia(name:client.email ?? "", media: imageData) { url in
                            picturePath = url
                           
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
                                    completion(false)
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                    CoreDataManager.shared.deleteClients()
                                    Task { await self.getAllClientData() }
                                    completion(true)
                                }
                            }
                        }
                    }
            }

        }
    }
    
    func addVendorData(vendor : Vendor,completion: @escaping (_ status: Bool?) -> Void){
        
        if let imageData = vendor.picture {
            var ref: DocumentReference? = nil
            self.db.collection("vendor")
                .whereField("email", isEqualTo: vendor.email ?? "")
                .getDocuments(){ (document, error) in
                    if let document = document {
                        if document.count >= 1 {
                            completion(true)
                        }else{
                            self.uploadMedia(name:vendor.email ?? "", media: imageData) { url in
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
                                        completion(false)
                                    } else {
                                        print("Document added with ID: \(ref!.documentID)")
                                        CoreDataManager.shared.deleteVendors()
                                        Task { await  self.getAllVendorData() }
                                        completion(true)
                                    }
                                }
                            }
                        }
                    }else{
                        self.uploadMedia(name:vendor.email ?? "", media: imageData) { url in
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
                                    completion(false)
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                    CoreDataManager.shared.deleteVendors()
                                    Task { await  self.getAllVendorData() }
                                    completion(true)
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func addServiceData(service : Service,completion: @escaping (_ status: Bool?) -> Void) async {
        
        if let media = service.medias {
            await self.updateMedia(media: media){ status in
                if let status = status {
                    if status == false {
                        completion(false)
                    }
                }
            }
        }
        
        if let address = service.address {
            self.addAddressData(address: address){ status in
                if let status = status {
                    if status == false {
                        completion(false)
                    }
                }
            }
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
                completion(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(true)
            }
        }
    }
    
    func addAddressData(address: Address,completion: @escaping (_ status: Bool?) -> Void){
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
                    completion(false)
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    completion(true)
                }
            }
    }
    
        func addMediaData(media : MediaFile,completion: @escaping (_ url: String?) -> Void){

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
                        completion(nil)
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        if let media = CoreDataManager.shared.getMedia(name: media.mediaName ?? "", serviceTitle: media.parent_Service?.serviceTitle ?? "") {
                            media.mediaPath = url
                            self.saveData()
                        }
                        completion(url)
                    }
                }
            }
        }
    }
    
    func addBookingData(booking : Booking,completion: @escaping (_ status: Bool?) -> Void){
        var parentService : String?
        if let service = booking.service {
            parentService = service.serviceTitle
        }
        var clientEmail : String?
        if let client = booking.client {
            clientEmail = client.email
        }
        var vendorEmail : String?
        if let vendor = booking.vendor {
            vendorEmail = vendor.email
        }
        var ref: DocumentReference? = nil
        ref = db.collection("booking").addDocument(data: [
            "date": booking.date,
            "status": booking.status ?? "",
            "parentService": parentService ?? "",
            "clientAddress": clientEmail ?? "",
            "vendorAddress": vendorEmail ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(true)
            }
        }
    }
    
    func addPaymentData(payment:Payment,completion: @escaping (_ status: Bool?) -> Void){

        var vendorEmail : String?
        var clientEmail : String?
        var serviceTitle : String?
        if let booking = payment.booking {
            vendorEmail = booking.vendor?.email
            clientEmail = booking.client?.email
            serviceTitle = booking.service?.serviceTitle
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("payment").addDocument(data: [
            "amount": payment.amount,
            "date": payment.date,
            "status": payment.status ?? "",
            "clientAddress": clientEmail ?? "",
            "vendorAddress": vendorEmail ?? "",
            "serviceTitle" :serviceTitle ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(true)
            }
        }
    }
    
    func addVendorReviewData(vendorReview : VendorReview,completion: @escaping (_ status: Bool?) -> Void){
        
        var clientEmail : String?
        if let client = vendorReview.client {
            clientEmail = client.email
        }
        var vendorEmail : String?
        if let vendor = vendorReview.vendor {
            vendorEmail = vendor.email
        }

        var ref: DocumentReference? = nil
        ref = db.collection("vendorReview").addDocument(data: [
            "rating": vendorReview.rating,
            "date": vendorReview.date,
            "comment": vendorReview.comment ?? "",
            "clientAddress": clientEmail ?? "",
            "vendorAddress": vendorEmail ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(true)
            }
        }
    }
    
    func addAccountData(account : Account,completion: @escaping (_ status: Bool?) -> Void){
        
        var vendorEmail : String?
        if let vendor = account.parent_vendor {
            vendorEmail = vendor.email
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("account").addDocument(data: [
            "accountNumber": account.accountNumber,
            "institutionNumber": account.institutionNumber,
            "transitNumber": account.transitNumber,
            "recipiantName": account.recipiantName ?? "",
            "recipiantBankName": account.recipiantBankName ?? "",
            "vendorAddress": vendorEmail ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(true)
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
    
    func updateClientData(client : Client,completion: @escaping (_ status: Bool?) -> Void){
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
                                completion(false)
                            } else if querySnapshot!.documents.count != 1 {
                                // Perhaps this is an error for you?
                                completion(false)
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
                                        completion(true)
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func updateVendorData(vendor : Vendor,completion: @escaping (_ status: Bool?) -> Void){
        var picturePath : String?
        if let imageData = vendor.picture {
            uploadMedia(name:vendor.email ?? "", media: imageData) { url in
                picturePath = url
                if let email = vendor.email{
                    self.db.collection("vendor")
                        .whereField("email", isEqualTo: email)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                completion(false)
                            } else if querySnapshot!.documents.count != 1 {
                                // Perhaps this is an error for you?
                                completion(false)
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
                                        completion(true)
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func updateAddressData(addressObject : Address,completion: @escaping (_ status: Bool?) -> Void){
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
                        
                        completion(false)
                    } else if querySnapshot!.documents.count != 1 {
                        // Perhaps this is an error for you?
                        completion(false)
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
                            completion(true)
                        }
                    }
                }
        }
    }
        
    func updateMedia(media : MediaFile,completion: @escaping (_ status: Bool?) -> Void) async{
            
            do {
                let snapshot = try await db.collection("media")
                    .whereField("mediaName", isEqualTo: media.mediaName)
                    .getDocuments()
                if let document = snapshot.documents.first {
                    try await document.reference.updateData([
                        "parentService": media.parent_Service?.serviceTitle ?? "",
                    ])
                    completion(true)
                }else{
                    completion(false)
                }
            }catch{
                completion(false)
            }
            
//           await db.collection("media")
//                .whereField("mediaName", isEqualTo: media.mediaName)
//                .getDocuments() { (querySnapshot, err) in
//                    if let err = err {
//                        // Some error occured
//                    } else if querySnapshot!.documents.count != 1 {
//                        // Perhaps this is an error for you?
//                    } else {
//                            if let document = querySnapshot!.documents.first{
//                                document.reference.updateData([
//                                    "parentService": media.parent_Service?.serviceTitle ?? "",
//                                ])
//                            }
//                    }
//                }
        }
}

extension InitialDataDownloadManager{
    func deleteMediaData(media : MediaFile,completion: @escaping (_ status: Bool?) -> Void){
        if let imagePath = media.mediaPath {
            deleteMedia(downloadURL:imagePath) { status in
                if let status = status {
                    if(status){
                        self.db.collection("media").whereField("mediaPath", isEqualTo: imagePath).getDocuments(){ (querySnapshot, err) in
                            if let err = err {
                                // Some error occured
                                completion(false)
                            } else if querySnapshot!.documents.count != 1 {
                                // Perhaps this is an error for you?
                                completion(false)
                            } else {
                                if let document = querySnapshot!.documents.first{
                                    document.reference.delete()
                                    completion(true)
                                }else{
                                    completion(false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteMedia(downloadURL : String,completion: @escaping (_ status: Bool?) -> Void) {
        
        let storage = Storage.storage()
        if downloadURL != "" {
            let storageRef = storage.reference(forURL: downloadURL)
            
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


