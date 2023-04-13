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
    
    var categories : [Category]?
    var clients : [Client]?
    var vendors : [Vendor]?
    var addresses : [Address]?
    var medias :[MediaFile]?
    var services : [Service]?
    var bookings : [Booking]?
    var reviews : [VendorReview]?
    var payments : [Payment]?
    
    var userEmail : String?
    func downloadAllData(email: String,completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.categories = CoreDataManager.shared.loadCategories()
                strongSelf.clients = CoreDataManager.shared.getAllClients()
                strongSelf.vendors = CoreDataManager.shared.getAllVendors()
                strongSelf.addresses = CoreDataManager.shared.getAllLocations()
                strongSelf.medias = CoreDataManager.shared.getAllMedias()
                strongSelf.services = CoreDataManager.shared.getAllServices()
                strongSelf.bookings = CoreDataManager.shared.getAllBooking()
                strongSelf.reviews = CoreDataManager.shared.getAllReviews()
                strongSelf.payments = CoreDataManager.shared.getAllPayments()
                strongSelf.userEmail = email
                
                strongSelf.getAllCategoryData(completion: {
                    completion()
                })
                //                await strongSelf.getAllClientData()
                //                await strongSelf.getAllVendorData()
                //                await strongSelf.getAllAddressData()
                //                await strongSelf.getAllServiceData()
                //                await strongSelf.getAllMediaData()
                //                await strongSelf.getAllBookingData()
                //                await strongSelf.getAllPaymentData()
                //                await strongSelf.getAllVendorReviewData()
            
                
            }
        }
    }
    
    private func getAllCategoryData(completion: @escaping () -> Void) {
       db.collection("categories").addSnapshotListener(){snapshot, error in
                DispatchQueue.main.async {
                    
                    snapshot?.documentChanges.forEach { documentSnapshot in
                        self.setCategoryData(documentSnapshot: documentSnapshot)
                    }
                    self.saveData()
                    self.categories = CoreDataManager.shared.loadCategories()
                    self.getAllClientData(completion: {
                        completion()
                    })
                }
            }
    }
    
    private func setCategoryData(documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let categoryName = data["name"]  as? String {
            var category : Category?
            if categoryName != "" {
                category = getCategory(name: categoryName)
                
                if category == nil {
                    category = Category(context: self.context)
                }
            }
            
            if (documentSnapshot.type == .removed){ //remove
                if let selectedCat = category {
                    context.delete(selectedCat)
                }
            }else{ //save
                category?.name = data["name"] as? String ?? ""
                category?.picture =  data["picture"] as? String ?? ""
            }
        }
    }
    
    private func getCategory(name : String) -> Category? {
        return  categories?.filter({ category in
            category.name == name
        }).first
    }
    
    func getAllClientData(completion: @escaping () -> Void) {
        db.collection("client").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setClientData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.clients = CoreDataManager.shared.getAllClients()
                self.getAllVendorData(completion: {
                    completion()
                })
            }
        }
    }
    
    func setClientData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let clientEmail = data["email"]  as? String {
            var client : Client?
            if clientEmail != "" {
                client = getClient(email: clientEmail)
                if client == nil {
                    client = Client(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedClient = client {
                        context.delete(selectedClient)
                    }
                }else{
                    client?.firstName = data["firstName"] as? String ?? ""
                    client?.lastName =  data["lastName"] as? String ?? ""
                    client?.email =  data["email"] as? String ?? ""
                    client?.password =  data["password"] as? String ?? ""
                    if let picture =  data["picture"] as? String{
                        client?.picture = self.urlToData(path: picture)
                    }
                    client?.contactNumber =  data["contactNumber"] as? String ?? ""
                    client?.isPremium =  data["isPremium"] as? Bool ?? false
                }
            }
        }
        
    }
    
    private func getClient(email : String) -> Client? {
        return  clients?.filter({ client in
            client.email == email
        }).first
    }
    
    func getClientData(email : String,completion: @escaping (_ client: Client?) -> Void) {
        db.collection("client").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
            if let err = err {
                // Some error occured
                completion(nil)
            } else if querySnapshot!.documents.count == 0 {
                // Perhaps this is an error for you?
                completion(nil)
            } else {
                if let data = querySnapshot?.documents.first {
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
                    completion(client)
                }
            }
        }
    }
    
    func getAllVendorData(completion: @escaping () -> Void) {
        db.collection("vendor").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setVendorData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.vendors = CoreDataManager.shared.getAllVendors()
                self.getAllAddressData(completion: {
                    completion()
                })
            }
        }
    }
    
    func setVendorData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let vendorEmail = data["email"]  as? String {
            var vendor : Vendor?
            if vendorEmail != "" {
                vendor = getVendors(email: vendorEmail)
                if vendor == nil {
                    vendor = Vendor(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedVendor = vendor {
                        context.delete(selectedVendor)
                    }
                }else{
                    vendor?.firstName = data["firstName"] as? String ?? ""
                    vendor?.lastName =  data["lastName"] as? String ?? ""
                    vendor?.email =  data["email"] as? String ?? ""
                    vendor?.password =  data["password"] as? String ?? ""
                    if let picture =  data["picture"] as? String{
                        vendor?.picture = self.urlToData(path: picture)
                    }
                    vendor?.contactNumber =  data["contactNumber"] as? String ?? ""
                    vendor?.bannerURL =  data["bannerURL"]  as? String ?? ""
                }
            }
        }
        
    }
    
    private func getVendors(email : String) -> Vendor? {
        return  vendors?.filter({ vendor in
            vendor.email == email
        }).first
    }
    
    func getVendorData(email : String,completion: @escaping (_ vendor: Vendor?) -> Void) {
        self.db.collection("vendor")
            .whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // Some error occured
                    completion(nil)
                } else if querySnapshot!.documents.count == 0 {
                    // Perhaps this is an error for you?
                    completion(nil)
                } else {
                    if let data = querySnapshot?.documents.first {
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
                        completion(vendor)
                    }
                }
            }
    }
    
    func getAllServiceData(completion: @escaping () -> Void) {
        db.collection("service").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setServiceData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.services = CoreDataManager.shared.getAllServices()
                self.getAllMediaData(completion: {
                    completion()
                })
            }
        }
    }
    
    
    func setServiceData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let serviceId = data["serviceId"]  as? Int {
            var service : Service?
            if serviceId != -1 {
                service = getService(serviceId: serviceId)
                if service == nil {
                    service = Service(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedService = service {
                        context.delete(selectedService)
                    }
                }else{
                    service?.serviceTitle = data["serviceTitle"] as? String ?? ""
                    service?.serviceDescription =  data["serviceDescription"] as? String ?? ""
                    service?.cancelPolicy =  data["cancelPolicy"] as? String ?? ""
                    service?.price =  data["price"] as? String ?? ""
                    service?.priceType =  data["priceType"]  as? String ?? ""
                    service?.equipment = data["equipment"]  as? Bool ?? false
                    service?.serviceId = data["serviceId"]  as? Int16 ?? -1
                    service?.createdDate = data["createdDate"] as? Date ?? Date()
                    service?.status = data["status"]  as? String ?? ""
                    if let parentVendor = data["parentVendor"]  as? String {
                        if parentVendor != "" {
                            service?.parent_Vendor = getVendors(email: parentVendor)
                        }
                    }
                    
                    if let parentCategory = data["parentCategory"]  as? String {
                        if parentCategory != "" {
                            service?.parent_Category = getCategory(name: parentCategory)
                        }
                    }
                    
                    if let addressId = data["parentAddress"]  as? Int {
                        if addressId != -1 {
                            service?.address = getAddress(addressId: addressId)
                        }
                    }
                }
            }
        }
        
    }
    
    private func getService(serviceId : Int) -> Service? {
        return  services?.filter({ service in
            service.serviceId == serviceId
        }).first
    }
    
    func getAllAddressData(completion: @escaping () -> Void) {
        db.collection("address").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setAddressData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.addresses = CoreDataManager.shared.getAllLocations()
                self.getAllServiceData(completion: {
                    completion()
                })
            }
        }
    }
    
    
    func setAddressData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let addressId = data["addressId"]  as? Int {
            var address : Address?
            if addressId != -1 {
                address = getAddress(addressId: addressId)
                if address == nil {
                    address = Address(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedAddress = address {
                        context.delete(selectedAddress)
                    }
                }else{
                    address?.addressLongitude = data["longitude"] as? Double ?? 0
                    address?.addressLatitude =  data["latitude"] as? Double ?? 0
                    address?.addressId = data["addressId"] as? Int16 ?? -1
                    address?.address =  data["address"] as? String ?? ""
                    if let clientEmail = data["clientEmailAddress"]  as? String {
                        if clientEmail != "" {
                            address?.clientAddress = getClient(email: clientEmail)
                        }
                    }
                    if let vendorEmail = data["vendorEmailAddress"]  as? String {
                        if vendorEmail != "" {
                            address?.vendorAddress = getVendors(email: vendorEmail)
                        }
                    }
                }
            }
        }
        
    }
    
    private func getAddress(addressId : Int) -> Address? {
        return  addresses?.filter({ address in
            address.addressId == addressId
        }).first
    }
    
    
    func getAllMediaData(completion: @escaping () -> Void) {
        db.collection("media").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setMediaData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.medias = CoreDataManager.shared.getAllMedias()
                self.getAllBookingData(completion: {
                    completion()
                })
            }
        }
    }
    
    
    func setMediaData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let mediaName = data["mediaName"]  as? String {
            var media : MediaFile?
            if mediaName != "" {
                media = getMedia(mediaName: mediaName)
                if media == nil {
                    media = MediaFile(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedMedia = media {
                        context.delete(selectedMedia)
                    }
                }else{
                    media?.mediaName =  data["mediaName"] as? String ?? ""
                    media?.mediaPath =  data["mediaPath"] as? String ?? ""
                    if let picture =  data["mediaContent"] as? String{
                        media?.mediaContent = self.urlToData(path: picture)
                    }
                    
                    if let parentService = data["parentService"]  as? Int {
                        if parentService != -1 {
                            media?.parent_Service = getService(serviceId: parentService)
                        }
                    }
                }
            }
        }
        
    }
    
    private func getMedia(mediaName : String) -> MediaFile? {
        return  medias?.filter({ media in
            media.mediaName == mediaName
        }).first
    }
    
    
    func getAllBookingData(completion: @escaping () -> Void) {
        db.collection("booking").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setBookingData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.bookings = CoreDataManager.shared.getAllBooking()
                self.getAllPaymentData(completion: {
                    completion()
                })
            }
        }
    }
    
    
    func setBookingData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let bookingId = data["bookingId"]  as? Int {
            var booking : Booking?
            if bookingId != -1 {
                booking = getBooking(bookingId: bookingId)
                if booking == nil {
                    booking = Booking(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedBooking = booking {
                        context.delete(selectedBooking)
                    }
                }else{
                    if let postTimestamp = data["date"] as? Timestamp{
                        booking?.date =  postTimestamp.dateValue()
                    }
                    booking?.bookingId = data["bookingId"]  as? Int16 ?? -1
                    
                    booking?.status =  data["status"] as? String ?? ""
                    booking?.problemDescription = data["problemDescription"] as? String ?? ""
                    
                    if let parentService = data["parentService"]  as? Int {
                        if parentService != -1 {
                            booking?.service = getService(serviceId: parentService)
                        }
                    }
                    
                    if let clientEmail = data["clientEmailAddress"]  as? String {
                        if clientEmail != "" {
                            booking?.client = getClient(email: clientEmail)
                        }
                    }
                    if let vendorEmail = data["vendorEmailAddress"]  as? String {
                        if vendorEmail != "" {
                            booking?.vendor = getVendors(email: vendorEmail)
                        }
                    }
                }
            }
        }
        
    }
    
    private func getBooking(bookingId : Int) -> Booking? {
        return  bookings?.filter({ booking in
            booking.bookingId == bookingId
        }).first
    }
    
    
    func getAllPaymentData(completion: @escaping () -> Void) {
        db.collection("payment").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setPaymentData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.payments = CoreDataManager.shared.getAllPayments()
                self.getAllVendorReviewData(completion: {
                    completion()
                })
            }
        }
    }
    
    
    func setPaymentData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let paymentId = data["paymentId"]  as? Int {
            var payment : Payment?
            if paymentId != -1 {
                payment = getPayment(paymentId: paymentId)
                if payment == nil {
                    payment = Payment(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedPayment = payment {
                        context.delete(selectedPayment)
                    }
                }else{
                    payment?.amount =  data["amount"] as? Double ?? 0
                    if let postTimestamp = data["date"] as? Timestamp{
                        payment?.date =  postTimestamp.dateValue()
                    }
                    payment?.status =  data["status"] as? String ?? ""
                    payment?.paymentId = data["paymentId"]  as? Int16 ?? -1
                    
                    if let bookingId = data["bookingId"] as? Int {
                        if bookingId != -1 {
                            payment?.booking = getBooking(bookingId: bookingId)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    private func getPayment(paymentId : Int) -> Payment? {
        return  payments?.filter({ payments in
            payments.paymentId == paymentId
        }).first
    }
    
    func getAllVendorReviewData(completion: @escaping () -> Void) {
        db.collection("vendorReview").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setVendorReviewData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                self.reviews = CoreDataManager.shared.getAllReviews()
                self.getAccountData(completion: {
                    completion()
                })
            }
        }
    }
    
    
    func setVendorReviewData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let reviewId = data["reviewId"]  as? Int {
            var review : VendorReview?
            if reviewId != -1 {
                review = getVendorReview(reviewId: reviewId)
                if review == nil {
                    review = VendorReview(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedReview = review {
                        context.delete(selectedReview)
                    }
                }else{
                    review?.comment =  data["comment"] as? String ?? ""
                    if let postTimestamp = data["date"] as? Timestamp{
                        review?.date =  postTimestamp.dateValue()
                    }
                    review?.reviewId = data["reviewId"]  as? Int16 ?? -1
                    review?.rating = Int16(data["rating"] as? Int ?? 0)
                    review?.vendorRating = data["vendorRating"] as? Bool ?? false
                    if let clientEmail = data["clientEmailAddress"]  as? String {
                        if clientEmail != "" {
                            review?.client = getClient(email: clientEmail)
                        }
                    }
                    if let vendorEmail = data["vendorEmailAddress"]  as? String {
                        if vendorEmail != "" {
                            review?.vendor = getVendors(email: vendorEmail)
                        }
                    }
                    if let parentService = data["parentService"]  as? Int {
                        if parentService != -1 {
                            review?.service = getService(serviceId: parentService)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    private func getVendorReview(reviewId : Int) -> VendorReview? {
        return  reviews?.filter({ review in
            review.reviewId == reviewId
        }).first
    }
    
    func getAccountData(completion: @escaping () -> Void) {
        db.collection("account").addSnapshotListener(){snapshot, error in
            DispatchQueue.main.async {
                snapshot?.documentChanges.forEach { documentSnapshot in
                    self.setAccountData(documentSnapshot: documentSnapshot)
                }
                self.saveData()
                completion()
            }
        }
    }
    
    
    func setAccountData( documentSnapshot : DocumentChange){
        let data = documentSnapshot.document.data()
        
        if let accountNumber = data["accountNumber"]  as? Int {
            var account : Account?
            if accountNumber != -1 {
                account = CoreDataManager.shared.getVendorBankAccount(email: userEmail ?? "")
                if account == nil {
                    account = Account(context: self.context)
                }
                if (documentSnapshot.type == .removed){ //remove
                    if let selectedAccount = account {
                        context.delete(selectedAccount)
                    }
                }else{
                    account?.recipiantName =  data["recipiantName"] as? String ?? ""
                    account?.recipiantBankName =  data["recipiantBankName"] as? String ?? ""
                    account?.accountNumber = Int32(data["accountNumber"] as? Int ?? 0)
                    account?.institutionNumber = Int32(data["institutionNumber"] as? Int ?? 0)
                    account?.transitNumber = Int32(data["transitNumber"] as? Int ?? 0)
                    
                    if let vendorEmail = data["vendorEmailAddress"]  as? String {
                        if vendorEmail != "" {
                            account?.parent_vendor = getVendors(email: vendorEmail)
                        }
                    }
                    
                }
            }
        }
        
    }
}

extension InitialDataDownloadManager {
    
    func addClientData(client : Client,completion: @escaping (_ status: Bool?) -> Void){
        var picturePath : String?
        var ref: DocumentReference? = nil
        if let imageData = client.picture {
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
                                    "fcmToken" : UserDefaultsManager.shared.getFCM(),
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                        completion(false)
                                    } else {
                                        print("Document added with ID: \(ref?.documentID)")
//                                        CoreDataManager.shared.deleteClients()
//                                        Task { await self.getAllClientData() }
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
                                "fcmToken" : UserDefaultsManager.shared.getFCM(),
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    completion(false)
                                } else {
                                    print("Document added with ID: \(ref?.documentID)")
//                                    CoreDataManager.shared.deleteClients()
//                                    Task { await self.getAllClientData() }
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            
        }else{
            ref = self.db.collection("client").addDocument(data: [
                "contactNumber": client.contactNumber ?? "",
                "email": client.email ?? "",
                "lastName": client.lastName ?? "",
                "firstName": client.firstName ?? "",
                "isPremium": client.isPremium,
                "picture":  "",
                "password" : client.password ?? "",
                "fcmToken" : UserDefaultsManager.shared.getFCM(),
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(false)
                } else {
                    print("Document added with ID: \(ref?.documentID ?? "")")
//                    CoreDataManager.shared.deleteClients()
//                    Task { await self.getAllClientData() }
                    completion(true)
                }
            }
        }
    }
    
    func addVendorData(vendor : Vendor,completion: @escaping (_ status: Bool?) -> Void){
        var ref: DocumentReference? = nil
        if let imageData = vendor.picture {
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
                                    "password" : vendor.password ?? "",
                                    "fcmToken" : UserDefaultsManager.shared.getFCM(),
                                    
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                        completion(false)
                                    } else {
                                        print("Document added with ID: \(ref?.documentID)")
//                                        CoreDataManager.shared.deleteVendors()
//                                        Task { await  self.getAllVendorData() }
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
                                "password" : vendor.password ?? "",
                                "fcmToken" : UserDefaultsManager.shared.getFCM(),
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    completion(false)
                                } else {
                                    print("Document added with ID: \(ref?.documentID)")
//                                    CoreDataManager.shared.deleteVendors()
//                                    Task { await  self.getAllVendorData() }
                                    completion(true)
                                }
                            }
                        }
                    }
                }
        }else{
            ref = self.db.collection("vendor").addDocument(data: [
                "contactNumber": vendor.contactNumber ?? "",
                "email": vendor.email ?? "",
                "lastName": vendor.lastName ?? "",
                "firstName": vendor.firstName ?? "",
                "bannerURL": vendor.bannerURL ?? "",
                "picture": "",
                "password" : vendor.password ?? "",
                "fcmToken" : UserDefaultsManager.shared.getFCM(),
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    completion(false)
                } else {
                    print("Document added with ID: \(ref?.documentID)")
//                    CoreDataManager.shared.deleteVendors()
//                    Task { await  self.getAllVendorData() }
                    completion(true)
                }
            }
        }
    }
    
    func chedkUserData(email : String, isVendor : Bool,completion: @escaping (_ status: Bool?) -> Void){
        var dataCollection = "client"
        if isVendor {
            dataCollection = "vendor"
        }
        self.db.collection(dataCollection)
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
        var addressID = -1
        if let address = service.address {
            addressID = Int(address.addressId)
            self.addAddressDataForService(address: address, serviceId: Int(service.serviceId)){ status in
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
            "createdDate" : service.createdDate ?? Date(),
            "status" : service.status ?? "",
            "parentAddress" : addressID,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref?.documentID)")
                completion(true)
            }
        }
    }
    
    func addAddressData(address: Address,completion: @escaping (_ status: Bool?) -> Void){
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
            "addressId" : address.addressId ,
            //                "parentService": serviceId ?? -1,
            "clientEmailAddress": clientEmail ?? "",
            "vendorEmailAddress": vendorEmail ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref?.documentID)")
                completion(true)
            }
        }
    }
    
    func addAddressDataForService(address: Address, serviceId : Int ,completion: @escaping (_ status: Bool?) -> Void){
        var ref: DocumentReference? = nil
        ref = db.collection("address").addDocument(data: [
            "longitude": address.addressLongitude,
            "latitude": address.addressLatitude,
            "address": address.address ?? "",
            "addressId" : address.addressId ,
            "parentService": serviceId ,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref?.documentID)")
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
                        print("Document added with ID: \(ref?.documentID)")
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
            "bookingId":  booking.bookingId ,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref?.documentID)")
                completion(true)
            }
        }
    }
    
    func addPaymentData(payment:Payment,completion: @escaping (_ status: Bool?) -> Void){
        
        var bookingId = -1
        if let booking = payment.booking {
            bookingId = Int(booking.bookingId)
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("payment").addDocument(data: [
            "amount": payment.amount,
            "date": payment.date ?? Date(),
            "status": payment.status ?? "",
            "bookingId" :bookingId ,
            "paymentId":  payment.paymentId ,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref?.documentID)")
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
            "reviewId":  vendorReview.reviewId ,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref?.documentID)")
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
                print("Document added with ID: \(ref?.documentID)")
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
                            } else if querySnapshot!.documents.count == 0 {
                                // Perhaps this is an error for you?
                                completion(false)
                            } else {
                                if let number = client.contactNumber,let lastName = client.lastName,let firstName = client.firstName{
                                    let password = client.password
                                    if let document = querySnapshot?.documents.first{
                                        document.reference.updateData([
                                            "contactNumber": number,
                                            "email": email,
                                            "lastName": lastName,
                                            "firstName": firstName,
                                            "isPremium": client.isPremium,
                                            "picture": picturePath ?? "",
                                            "password" : password,
                                            "fcmToken" : UserDefaultsManager.shared.getFCM(),
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
                            } else if querySnapshot!.documents.count == 0 {
                                // Perhaps this is an error for you?
                                completion(false)
                            } else {
                                if let number = vendor.contactNumber,let lastName = vendor.lastName,let firstName = vendor.firstName {
                                    let password = vendor.password
                                    if let document = querySnapshot?.documents.first{
                                        document.reference.updateData([
                                            "contactNumber": number,
                                            "email": email,
                                            "lastName": lastName,
                                            "firstName": firstName,
                                            "bannerURL": vendor.bannerURL ?? "",
                                            "picture": picturePath ?? "",
                                            "password" : password,
                                            "fcmToken" : UserDefaultsManager.shared.getFCM(),
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
                .whereField("addressId", isEqualTo: addressObject.addressId)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        // Some error occured
                        
                        completion(false)
                    } else if querySnapshot!.documents.count == 0 {
                        // Perhaps this is an error for you?
                        completion(false)
                    } else {
                        if let document = querySnapshot?.documents.first{
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
    
    func updateAddressDataForService(addressObject : Address , serviceId : Int ,completion: @escaping (_ status: Bool?) -> Void){
        var addressLat = 0.0
        var addressLog = 0.0
        var address = ""
        if let serviceAddress = addressObject.address {
            address = serviceAddress
        }
        if let service = addressObject.parentService {
            addressLat = addressObject.addressLatitude
            addressLog = addressObject.addressLongitude
            //                addressLat = String(addressObject.addressLatitude)
            //                addressLog = String(addressObject.addressLongitude)
        }
        
        db.collection("address")
        //                .whereField("parentService", isEqualTo: serviceId)
            .whereField("addressId", isEqualTo: addressObject.addressId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // Some error occured
                    
                    completion(false)
                } else if querySnapshot!.documents.count == 0 {
                    // Perhaps this is an error for you?
                    completion(false)
                } else {
                    if let document = querySnapshot?.documents.first{
                        document.reference.updateData([
                            "longitude": addressLat,
                            "latitude": addressLog,
                            "address": address
                            //                                "parentService": serviceId ?? -1,
                            //                                "clientEmailAddress": clientEmail ?? "",
                            //                                "vendorEmailAddress": vendorEmail ?? "",
                        ])
                        completion(true)
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
        var bookingId = Int(booking.bookingId)
        
        db.collection("booking")
            .whereField("bookingId", isEqualTo: bookingId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // Some error occured
                    
                    completion(false)
                } else if querySnapshot!.documents.count == 0 {
                    // Perhaps this is an error for you?
                    completion(false)
                } else {
                    if let document = querySnapshot?.documents.first{
                        document.reference.updateData([
                            "status": booking.status ?? "",
                            "date": booking.date ?? Date(),
                            "problemDescription" : booking.problemDescription ?? "",
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
        var addressID = -1
        if let address = service.address {
            addressID = Int(address.addressId)
            self.updateAddressDataForService(addressObject: address, serviceId: Int(service.serviceId)){ status in
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
        
        var status = ""
        if let serviceStatus = service.status {
            status = serviceStatus
        }
        
        db.collection("service")
            .whereField("serviceId", isEqualTo: service.serviceId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    // Some error occured
                    
                    completion(false)
                } else if querySnapshot!.documents.count == 0 {
                    // Perhaps this is an error for you?
                    completion(false)
                } else {
                    if let document = querySnapshot?.documents.first{
                        document.reference.updateData([
                            "cancelPolicy": service.cancelPolicy ?? "",
                            "equipment": service.equipment,
                            "price": service.price ?? "",
                            "priceType": service.priceType ?? "",
                            "serviceDescription": service.serviceDescription ?? "",
                            "parentCategory":  category,
                            "serviceTitle":  title,
                            "status" : status,
                            "parentAddress" : addressID,
                            
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
                            } else if querySnapshot!.documents.count == 0 {
                                // Perhaps this is an error for you?
                                completion(false)
                            } else {
                                if let document = querySnapshot?.documents.first{
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
