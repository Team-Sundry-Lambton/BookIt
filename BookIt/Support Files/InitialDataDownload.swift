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
            CoreDataManager.shared.deleteCategory()
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
            CoreDataManager.shared.deleteClients()
            let snapshot = try await db.collection("client").getDocuments();  snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                        let client = Client(context: self.context)
                        client.firstName = data["firstName"] as? String ?? ""
                        client.lastName =  data["lastName"] as? String ?? ""
                        client.email =  data["email"] as? String ?? ""
                        client.password =  data["password"] as? String ?? ""
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
            CoreDataManager.shared.deleteVendors()
            let snapshot = try await db.collection("vendor").getDocuments(); snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                    let vendor = Vendor(context: self.context)
                    vendor.firstName = data["firstName"] as? String ?? ""
                    vendor.lastName =  data["lastName"] as? String ?? ""
                    vendor.email =  data["email"] as? String ?? ""
                    vendor.password =  data["password"] as? String ?? ""
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
            CoreDataManager.shared.deleteServices()
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
                service.serviceId = data["serviceId"]  as? Int16 ?? -1
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
            CoreDataManager.shared.deleteAddresss()
            let snapshot = try await db.collection("address").getDocuments() ; snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let address = Address(context: self.context)
                address.addressLongitude = data["longitude"] as? Double ?? 0
                address.addressLatitude =  data["latitude"] as? Double ?? 0

                address.address =  data["address"] as? String ?? ""
                
                if let parentService = data["parentService"]  as? Int {
                    if parentService != -1 {
                        if let service = CoreDataManager.shared.getService(serviceId: parentService){
                            address.parentService = service
                        }
                    }
                }
                if let clientEmail = data["clientEmailAddress"]  as? String {
                    if clientEmail != "" {
                        if let client = CoreDataManager.shared.getClient(email: clientEmail){
                            address.clientAddress = client
                        }
                    }
                }
                if let vendorEmail = data["vendorEmailAddress"]  as? String {
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
            CoreDataManager.shared.deleteMediaFiles()
            let snapshot = try await db.collection("media").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let media = MediaFile(context: self.context)
                media.mediaName =  data["mediaName"] as? String ?? ""
                media.mediaPath =  data["mediaPath"] as? String ?? ""
                if let picture =  data["mediaContent"] as? String{
                    media.mediaContent = self.urlToData(path: picture)
                }
                
                if let parentService = data["parentService"]  as? Int {
                    if parentService != -1 {
                        print("Service ID: ", parentService);
                        if let service = CoreDataManager.shared.getService(serviceId: parentService){
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
            CoreDataManager.shared.deleteBookings()
            let snapshot = try await db.collection("booking").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let boobking = Booking(context: self.context)
                if let postTimestamp = data["date"] as? Timestamp{
                    boobking.date =  postTimestamp.dateValue()
                }

                boobking.status =  data["status"] as? String ?? ""
                boobking.problemDescription = data["problemDescription"] as? String ?? ""
                
                if let parentService = data["parentService"]  as? Int {
                    if parentService != -1 {
                        if let service = CoreDataManager.shared.getService(serviceId: parentService){
                            boobking.service = service
                        }
                    }
                }
                
                if let clientEmail = data["clientEmailAddress"]  as? String {
                    if clientEmail != "" {
                        if let client = CoreDataManager.shared.getClient(email: clientEmail){
                            boobking.client = client
                        }
                    }
                }
                if let vendorEmail = data["vendorEmailAddress"]  as? String {
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
            CoreDataManager.shared.deletePayments()
            let snapshot = try await db.collection("payment").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let payment = Payment(context: self.context)
                payment.amount =  data["amount"] as? Double ?? 0
                if let postTimestamp = data["date"] as? Timestamp{
                    payment.date =  postTimestamp.dateValue()
                }
                payment.status =  data["status"] as? String ?? ""
                
                if let client = data["clientEmailAddress"]  as? String, let vendor = data["vendorEmailAddress"]  as? String, let serviceId = data["serviceId"] as? Int {
                    if client != ""  && vendor != ""  && serviceId != -1 {
                        if let booking = CoreDataManager.shared.getBooking(client: client, serviceId: serviceId, vendor: vendor){
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
            CoreDataManager.shared.deleteVendorReviews()
            let snapshot = try await db.collection("vendorReview").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let review = VendorReview(context: self.context)
                review.comment =  data["comment"] as? String ?? ""
                if let postTimestamp = data["date"] as? Timestamp{
                    review.date =  postTimestamp.dateValue()
                }
                review.rating = Int16(data["rating"] as? Int ?? 0)
                review.vendorRating = data["vendorRating"] as? Bool ?? false
                if let clientEmail = data["clientEmailAddress"]  as? String {
                    if clientEmail != "" {
                        if let client = CoreDataManager.shared.getClient(email: clientEmail){
                            review.client = client
                        }
                    }
                }
                if let vendorEmail = data["vendorEmailAddress"]  as? String {
                    if vendorEmail != "" {
                        if let vendor = CoreDataManager.shared.getVendor(email: vendorEmail){
                            review.vendor = vendor
                        }
                    }
                }
                if let parentService = data["parentService"]  as? Int {
                    if parentService != -1 {
                        if let service = CoreDataManager.shared.getService(serviceId: parentService){
                            review.service = service
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
            CoreDataManager.shared.deleteAccounts()
            let snapshot = try await db.collection("account").getDocuments();
            snapshot.documents.forEach { documentSnapshot in
                let data = documentSnapshot.data()
                let account = Account(context: self.context)
                account.recipiantName =  data["recipiantName"] as? String ?? ""
                account.recipiantBankName =  data["recipiantBankName"] as? String ?? ""
                account.accountNumber = Int32(data["accountNumber"] as? Int ?? 0)
                account.institutionNumber = Int32(data["institutionNumber"] as? Int ?? 0)
                account.transitNumber = Int32(data["transitNumber"] as? Int ?? 0)

                if let vendorEmail = data["vendorEmailAddress"]  as? String {
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
                                    "password" : client.password ?? "",
                                    
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
                                "password" : client.password ?? "",
                                
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
                                    "password" : client.password ?? "",
                                    
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
                                "password" : client.password ?? "",
                                
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
        
        
        func chedkVendorData(email : String,completion: @escaping (_ status: Bool?) -> Void){
                self.db.collection("vendor")
                    .whereField("email", isEqualTo: email)
                    .getDocuments(){ (document, error) in
                        if let document = document {
                            if document.count >= 1 {
                                completion(true)
                            }else{
                                completion(false)
                            }
                        }else{
                            completion(false)
                        }
            }
        }
        
        func checkClientData(email : String,completion: @escaping (_ status: Bool?) -> Void){
                self.db.collection("client")
                    .whereField("email", isEqualTo: email)
                    .getDocuments(){ (document, error) in
                        if let document = document {
                            if document.count >= 1 {
                                completion(true)
                            }else{
                                completion(false)
                            }
                        }else{
                            completion(false)
                        }
                }
        }
    }
    
    func addServiceData(service : Service,completion: @escaping (_ status: Bool?) -> Void) async {
        
        if let medias = service.medias {
            for media in medias {
                await self.updateMedia(media: media as! MediaFile){ status in
                    if let status = status {
                        if status == false {
                            completion(false)
                        }
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
            "serviceId":  service.serviceId ,
            
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
        var serviceId : Int?
        if let service = address.parentService {
            serviceId = Int(service.serviceId)
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
                "parentService": serviceId ?? -1,
                "clientEmailAddress": clientEmail ?? "",
                "vendorEmailAddress": vendorEmail ?? "",
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

        var serviceId = -1
        if let service = media.parent_Service{
            serviceId = Int(service.serviceId)
        }
        
        if let imageData = media.mediaContent {
            uploadMedia(name:media.mediaName ?? "", media: imageData) { url in
                var ref: DocumentReference? = nil
                ref = self.db.collection("media").addDocument(data: [
                    "mediaName": media.mediaName ?? "",
                    "mediaContent": url ?? "",
                    "mediaPath": url ?? "",
                    "parentService": serviceId,
                    
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(nil)
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        let media = CoreDataManager.shared.getMedia(name: media.mediaName ?? "", serviceId: serviceId)
                        media?.mediaPath = url
                        self.saveData()
                        completion(url)
                    }
                }
            }
        }
    }
    
    func addBookingData(booking : Booking,completion: @escaping (_ status: Bool?) -> Void){
        var serviceId : Int?
        if let service = booking.service {
            serviceId = Int(service.serviceId)
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
            "date": booking.date ?? Date(),
            "status": booking.status ?? "",
            "parentService": serviceId ?? -1,
            "clientEmailAddress": clientEmail ?? "",
            "vendorEmailAddress": vendorEmail ?? "",
            "problemDescription" : booking.problemDescription ?? "",
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
        var serviceId = -1
        if let booking = payment.booking {
            vendorEmail = booking.vendor?.email
            clientEmail = booking.client?.email
            serviceId = Int(booking.service?.serviceId ?? -1)
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("payment").addDocument(data: [
            "amount": payment.amount,
            "date": payment.date ?? Date(),
            "status": payment.status ?? "",
            "clientEmailAddress": clientEmail ?? "",
            "vendorEmailAddress": vendorEmail ?? "",
            "serviceId" :serviceId ,
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
        
        var serviceId : Int?
        if let service = vendorReview.service {
            serviceId = Int(service.serviceId)
        }

        var ref: DocumentReference? = nil
        ref = db.collection("vendorReview").addDocument(data: [
            "rating": vendorReview.rating,
            "date": vendorReview.date ?? Date(),
            "comment": vendorReview.comment ?? "",
            "clientEmailAddress": clientEmail ?? "",
            "vendorEmailAddress": vendorEmail ?? "",
            "vendorRating" : vendorReview.vendorRating,
            "parentService": serviceId ?? -1,
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
    
    func addBankAccountData(account : Account,completion: @escaping (_ status: Bool?) -> Void){
        
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
            "vendorEmailAddress": vendorEmail ?? "",
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
                                if let number = client.contactNumber,let lastName = client.lastName,let firstName = client.firstName,let password = client.password{
                                    if let document = querySnapshot!.documents.first{
                                        document.reference.updateData([
                                            "contactNumber": number,
                                            "email": email,
                                            "lastName": lastName,
                                            "firstName": firstName,
                                            "isPremium": client.isPremium,
                                            "picture": picturePath ?? "",
                                            "password" : password,
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
                                if let number = vendor.contactNumber,let lastName = vendor.lastName,let firstName = vendor.firstName,let password = vendor.password {
                                    if let document = querySnapshot!.documents.first{
                                        document.reference.updateData([
                                            "contactNumber": number,
                                            "email": email,
                                            "lastName": lastName,
                                            "firstName": firstName,
                                            "bannerURL": vendor.bannerURL ?? "",
                                            "picture": picturePath ?? "",
                                            "password" : password,
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
            var serviceId = -1
            if let service = addressObject.parentService {
                serviceId = Int(service.serviceId)
                filterField = "serviceId"
                filterText =  String(serviceId)
            }
            var clientEmail : String?
            if let client = addressObject.clientAddress {
                clientEmail = client.email
                filterField = "clientEmailAddress"
                filterText = clientEmail ?? address
            }
            var vendorEmail : String?
            if let vendor = addressObject.vendorAddress {
                vendorEmail = vendor.email
                filterField = "vendorEmailAddress"
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
//                                "parentService": serviceId ?? -1,
//                                "clientEmailAddress": clientEmail ?? "",
//                                "vendorEmailAddress": vendorEmail ?? "",
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
                        "parentService": media.parent_Service?.serviceId ?? -1,
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
//                                    "parentService": media.parent_Service?.serviceId ?? "",
//                                ])
//                            }
//                    }
//                }
        }
    
    func updateBookingData(booking : Booking,completion: @escaping (_ status: Bool?) -> Void){
        var serviceId = -1
        if let service = booking.service {
            serviceId = Int(service.serviceId)
        }
        var clientEmail = ""
        if let client = booking.client {
            clientEmail = client.email ?? ""
        }
        var vendorEmail = ""
        if let vendor = booking.vendor {
            vendorEmail = vendor.email ?? ""
        }

        db.collection("booking")
            .whereField("parentService", isEqualTo: serviceId).whereField("clientEmailAddress", isEqualTo: clientEmail).whereField("vendorEmailAddress", isEqualTo: vendorEmail)
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
                            "status": booking.status ?? "",
                        ])
                        completion(true)
                    }
                }
            }

        
    }
    
    func updateServiceData(service : Service,completion: @escaping (_ status: Bool?) -> Void) async {
            if let medias = service.medias {
                for media in medias {
                    await self.updateMedia(media: media as! MediaFile){ status in
                        if let status = status {
                            if status == false {
                                completion(false)
                            }
                        }
                    }
                }
            }
            
            if let address = service.address {
                self.updateAddressData(addressObject: address){ status in
                    if let status = status {
                        if status == false {
                            completion(false)
                        }
                    }
                }
            }
        
        var category = ""
        if let vendor = service.parent_Category {
            category = vendor.name ?? ""
        }
        
        var title = ""
        if let st = service.serviceTitle {
            title = st
        }
         
            db.collection("service")
            .whereField("serviceId", isEqualTo: service.serviceId)
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
                                "cancelPolicy": service.cancelPolicy ?? "",
                                "equipment": service.equipment,
                                "price": service.price ?? "",
                                "priceType": service.priceType ?? "",
                                "serviceDescription": service.serviceDescription ?? "",
                                "parentCategory":  category,
                                "serviceTitle":  title,
                                //"parentVendor":  service.parent_Vendor?.email ?? "",
                            ])
                            completion(true)
                        }
                    }
        }
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


