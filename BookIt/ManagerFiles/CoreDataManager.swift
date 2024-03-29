//
//  CoreDataManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-16.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager : NSObject{
    static let shared = CoreDataManager()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAllClients() -> [Client]{
        var clients = [Client]()
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        do {
            clients = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
        return clients
    }
    
    func getClient(email : String) -> Client?{
        var client : Client?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Client")
        fetchRequest.predicate = NSPredicate(format: "email = %@", email)
        do {
            let users = try context.fetch(fetchRequest)
            client = users.first as? Client
        } catch {
            print(error)
        }
        return client
    }
    
    func getAllVendors() -> [Vendor]{
        var vendors = [Vendor]()
        let request: NSFetchRequest<Vendor> = Vendor.fetchRequest()
        do {
            vendors = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
        return vendors
    }
    
    func getVendor(email : String) -> Vendor?{
        var vendor : Vendor?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Vendor")
        fetchRequest.predicate = NSPredicate(format: "email = %@", email)
        do {
            let users = try context.fetch(fetchRequest)
            vendor = users.first as? Vendor
        } catch {
            print(error)
        }
        return vendor
    }
    
    func getCategory(name : String) -> Category?{
        var category : Category?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "name = %@ ", name)
        do {
            let categories = try context.fetch(fetchRequest)
            category = categories.first as? Category
        } catch {
            print(error)
        }
        return category
    }
    
    func getAllServices() -> [Service]{
        var services = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        do {
            services = try context.fetch(request)

        } catch {
            print(error)
        }
        return services
    }
    
    func getService(serviceId : Int) -> Service?{
        var service : Service?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Service")
        fetchRequest.predicate = NSPredicate(format: "serviceId = %i ", serviceId)
        do {
            let services = try context.fetch(fetchRequest)
            service = services.first as? Service
        } catch {
            print(error)
        }
        return service
    }
    
    func getAllMedias() -> [MediaFile]{
        var medias = [MediaFile]()
        let fetchRequest: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
        do {
            medias = try context.fetch(fetchRequest)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return medias
    }
    
    func getMedia(name : String, serviceId : Int) -> MediaFile?{
        var media : MediaFile?
        let fetchRequest: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
            let folderPredicate = NSPredicate(format: "parent_Service.serviceId=%i AND mediaName=%@", serviceId,name)
        fetchRequest.predicate = folderPredicate
        do {
            let medias = try context.fetch(fetchRequest)
            media = medias.first as? MediaFile
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return media
    }
    
    func getAllBooking() -> [Booking]{
        var bookings = [Booking]()
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
        do {
            bookings = try context.fetch(fetchRequest)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return bookings
    }
    
    func getBooking( bookingId : Int) -> Booking?{
        var booking : Booking?
        let fetchRequest: NSFetchRequest<Booking> = Booking.fetchRequest()
            let folderPredicate = NSPredicate(format: "bookingId=%i", bookingId)
        fetchRequest.predicate = folderPredicate
        do {
            let bookings = try context.fetch(fetchRequest)
            booking = bookings.first as? Booking
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return booking
    }
    
    func getAllPayments() -> [Payment]?{
        var payments = [Payment]()
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        do {
            payments = try context.fetch(fetchRequest)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return payments
    }
    
    func getPayment(bookingId : Int) -> Payment?{
        var payment : Payment?
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
            let folderPredicate = NSPredicate(format: "booking.bookingId=%i", bookingId)
        fetchRequest.predicate = folderPredicate
        do {
            let payments = try context.fetch(fetchRequest)
            payment = payments.first as? Payment
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return payment
    }

    func getServiceFirstMedia(serviceId : Int) -> MediaFile?{
        var media : MediaFile?
        let fetchRequest: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
            let folderPredicate = NSPredicate(format: "parent_Service.serviceId=%i", serviceId)
        fetchRequest.predicate = folderPredicate
        do {
            let medias = try context.fetch(fetchRequest)
            media = medias.first as? MediaFile
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return media
    }
    
    func getMediaList(serviceId : Int) -> [MediaFile]{
        var mediaList = [MediaFile]()
        let request: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
            let folderPredicate = NSPredicate(format: "parent_Service.serviceId=%i", serviceId)
            request.predicate = folderPredicate
        do {
            mediaList = try context.fetch(request)
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
       return mediaList
    }
    
    func getAllVendorReviews(email : String) -> [VendorReview]{
        var vendorReview = [VendorReview]()
        let request: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
        do {
            vendorReview = try context.fetch(request)
        } catch {
            print("Error loading VendorReview \(error.localizedDescription)")
        }
       return vendorReview
    }
    
    func getVendorReviewList(email : String) -> [VendorReview]{
        var vendorReview = [VendorReview]()
        let request: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
            let folderPredicate = NSPredicate(format: "vendor.email=%@ AND vendorRating=true", email)
            request.predicate = folderPredicate
        do {
            vendorReview = try context.fetch(request)
        } catch {
            print("Error loading VendorReview \(error.localizedDescription)")
        }
       return vendorReview
    }
    
    func getUserLocationData(email : String) -> Address? {
        var selectedLocation : Address?
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        let folderPredicate = NSPredicate(format: "clientAddress.email=%@", email)
        request.predicate = folderPredicate
        do {
            let location = try context.fetch(request)
            selectedLocation = location.first
        } catch {
            print("Error loading location data \(error.localizedDescription)")
        }
        
        return selectedLocation
    }
    
    func deleteClientLocation(email: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Address")
            fetchRequest.predicate = NSPredicate(format: "clientAddress.email = %@",email)
        do {
            let location = try context.fetch(fetchRequest)
            if let slectedLocation = location.first as? NSManagedObject {
                context.delete(slectedLocation)
            }
        } catch {
            print(error)
        }
    }
    
    func checkClientLocationInDB(email : String)-> Bool{
        var success = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Address")
        fetchRequest.predicate = NSPredicate(format: "clientAddress.email = %@", email )
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
    
        func loadCategories() -> [Category]{
            var categoryList = [Category]()
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            do {
                categoryList = try context.fetch(request)
            } catch {
                print("Error loading categories \(error.localizedDescription)")
            }
            return categoryList
        }
    
    func getServiceID() -> Int16 {
        var count = 0
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "serviceId", ascending: true)]
        do {
             let serviceList = try context.fetch(request)
            if serviceList.count > 0 {
                count = Int((serviceList.last?.serviceId ?? 0) + 1)
            }
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return Int16(count)
    }
    
    func getBookingID() -> Int16 {
        var count = 0
        let request: NSFetchRequest<Booking> = Booking.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "bookingId", ascending: true)]
        do {
             let serviceList = try context.fetch(request)
            if serviceList.count > 0 {
                count = Int((serviceList.last?.bookingId ?? 0) + 1)
            }
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return Int16(count)
    }
    
    func getAddressID() -> Int16 {
        var count = 0
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "addressId", ascending: true)]
        do {
             let addressIdList = try context.fetch(request)
            if addressIdList.count > 0 {
                count = Int((addressIdList.last?.addressId ?? 0) + 1)
            }
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return Int16(count)
    }
    
    func getPaymentID() -> Int16 {
        var count = 0
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "paymentId", ascending: true)]
        do {
             let paymentList = try context.fetch(request)
            if paymentList.count > 0 {
                count = Int((paymentList.last?.paymentId ?? 0) + 1)
            }
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return Int16(count)
    }
    
    func getReviewID() -> Int16 {
        var count = 0
        let request: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "reviewId", ascending: true)]
        do {
             let reviewList = try context.fetch(request)
            if reviewList.count > 0 {
                count = Int((reviewList.last?.reviewId ?? 0) + 1)
            }
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return Int16(count)
    }
    
    func loadBookingList(email : String, isClient:Bool = false, sortBy: SortType, sortAscending: Bool) -> [Booking]{
            var bookingList = [Booking]()
            let request: NSFetchRequest<Booking> = Booking.fetchRequest()
            var predictString: String = "vendor.email=%@"
            if isClient {
                predictString = "client.email=%@"
            } else {
                predictString = "vendor.email=%@"
            }
            let folderPredicate = NSPredicate(format: predictString, email ?? "")
            request.predicate = folderPredicate
            switch sortBy {
            case .byTitle:
                request.sortDescriptors = [NSSortDescriptor(key: "service.serviceTitle", ascending: sortAscending)]
            case .byDate:
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: sortAscending)]
            case .byPrice:
                request.sortDescriptors = [NSSortDescriptor(key: "service.price", ascending: sortAscending)]
            default:
                request.sortDescriptors = [NSSortDescriptor(key: "service.serviceTitle", ascending: sortAscending)]
            }
            
            do {
                bookingList = try context.fetch(request)

            } catch {
                print("Error loading Service \(error.localizedDescription)")
            }
            return bookingList
        }
    
    func loadAllServices() -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func loadServices() -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        let predicate = NSPredicate(format: "status=%@ " ,"Accepted")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func loadServicesByVendor(email:String) -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        let folderPredicate = NSPredicate(format: "parent_Vendor.email=%@", email ?? "")
        request.predicate = folderPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func checkUserInDB(email : String , isVendor : Bool) -> Bool{
        var success = false
        var entityName = "Client"
        if (isVendor){
            entityName = "Vendor"
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "email = %@", email)
        do {
            let user = try context.fetch(fetchRequest)
            if user.count >= 1 {
                success = true
            }
        } catch {
            print(error)
        }
        return success
    }
    
    func deleteUser(user : LoginUser , isVendor : Bool) {        
        var entityName = "Client"
        if (isVendor){
            entityName = "Vendor"
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "email = %@", user.email)
        do {
            let user = try context.fetch(fetchRequest)
            if let slectedUser = user.first as? NSManagedObject {
                context.delete(slectedUser)
            }
        } catch {
            print(error)
        }
    }
    
    func getAllReviews() -> [VendorReview]{
        var vendorReview = [VendorReview]()
        let request: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
        do {
            vendorReview = try context.fetch(request)
        } catch {
            print("Error loading VendorReview \(error.localizedDescription)")
        }
       return vendorReview
    }
    
    func getServiceReviewList(serviceId : Int) -> [VendorReview]{
        var vendorReview = [VendorReview]()
        let request: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
            let folderPredicate = NSPredicate(format: "service.serviceId=%i AND vendorRating=true", serviceId)
            request.predicate = folderPredicate
        do {
            vendorReview = try context.fetch(request)
        } catch {
            print("Error loading VendorReview \(error.localizedDescription)")
        }
       return vendorReview
    }
    
    func loadNewVendors() -> [Vendor]{
        var vendorList = [Vendor]()
        let request: NSFetchRequest<Vendor> = Vendor.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        request.fetchLimit = 10
        do {
            vendorList = try context.fetch(request)
        } catch {
            print("Error loading Vendor \(error.localizedDescription)")
        }
        return vendorList
    }
    
    func loadTopVendors() -> [Vendor]{
        var vendorList = [Vendor]()
        let request: NSFetchRequest<Vendor> = Vendor.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        request.fetchLimit = 10
        do {
            vendorList = try context.fetch(request)
        } catch {
            print("Error loading Vendor \(error.localizedDescription)")
        }
        return vendorList
    }
    
    func getMostRatedVendor() -> [Vendor]{
        var vendorList = [Vendor]()
        let fetchRequest: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
        let predicate = NSPredicate(format: "vendorRating=true")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: false)]
        fetchRequest.fetchLimit = 10
        do {
            // Execute the fetch request and get the vendors
            let vendorReview = try context.fetch(fetchRequest)
            
            if vendorReview.count > 0 {
                for review in vendorReview {
                    if let vendor = review.vendor {
                        if !vendorList.contains(vendor){
                            vendorList.append(vendor)
                        }
                    }
                }
                if vendorList.count < 10 {
                    for vendor in loadTopVendors(){
                        if !vendorList.contains(vendor){
                            vendorList.append(vendor)
                        }
                    }
                }
                
            }else{
                vendorList = loadTopVendors()
            }
        } catch {
            print("Error fetching vendors: \(error.localizedDescription)")
        }
        return vendorList
    }
    
    func loadTopServices() -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        let predicate = NSPredicate(format: "status=%@ " ,"Accepted")
        request.predicate = predicate
        request.fetchLimit = 10
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func getMostRatedServices() -> [Service]{
        var serviceList = [Service]()
        let fetchRequest: NSFetchRequest<VendorReview> = VendorReview.fetchRequest()
        let predicate = NSPredicate(format: "vendorRating=true")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: false)]
        fetchRequest.fetchLimit = 10
        do {
            // Execute the fetch request and get the vendors
            let vendorReview = try context.fetch(fetchRequest)
            
            if vendorReview.count > 0 {
                for review in vendorReview {
                    if let service = review.service {
                        if !serviceList.contains(service){
                            serviceList.append(service)
                        }
                    }
                }
                if serviceList.count < 10 {
                    for service in loadTopServices(){
                        if !serviceList.contains(service){
                            serviceList.append(service)
                        }
                    }
                }
            }else{
                serviceList = loadTopServices()
            }
        } catch {
            print("Error fetching vendors: \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func loadServicesWithSearch(searchText : String) -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        let statusPredicate = NSPredicate(format: "status=%@ " ,"Accepted")
        if !searchText.isEmpty{
            let predicate = NSPredicate(format: "serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@", searchText, searchText)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,statusPredicate])
        }else{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [statusPredicate])
        }
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func loadServicesForSelectedCategory(category : String, searchText : String, sortBy: SortType, sortAscending: Bool) -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
                var categoryPredicate = NSPredicate(format: "parent_Category.name == %@", category)
        let statusPredicate = NSPredicate(format: "status=%@ " ,"Accepted")
                if !searchText.isEmpty{
                    categoryPredicate = NSPredicate(format: "parent_Category.name == %@ AND ( serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@ )", category, searchText, searchText)
                }
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,statusPredicate])
        switch sortBy {
        case .byTitle:
            request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: sortAscending)]
        case .byDate:
            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: sortAscending)]
        case .byPrice:
            request.sortDescriptors = [NSSortDescriptor(key: "price", ascending: sortAscending)]
        default:
            request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: sortAscending)]
        }
        do {
            serviceList = try context.fetch(request)
            
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func loadServicesForSelectedVendor(email : String, searchText : String) -> [Service]{
        var serviceList = [Service]()
        let request: NSFetchRequest<Service> = Service.fetchRequest()
                var vendorPredicate = NSPredicate(format: "parent_Vendor.email == %@", email)
        let statusPredicate = NSPredicate(format: "status=%@ " ,"Accepted")
                if !searchText.isEmpty{
                    vendorPredicate = NSPredicate(format: "parent_Vendor.email == %@ AND ( serviceTitle CONTAINS[cd] %@ OR serviceDescription CONTAINS[cd] %@ )", email, searchText, searchText)
                }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [vendorPredicate,statusPredicate])
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        do {
            serviceList = try context.fetch(request)
            
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return serviceList
    }
    
    func deleteVendors() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Vendor")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func getAllLocations()-> [Address]? {
        var locations = [Address]()
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        do {
            locations = try context.fetch(request)
        } catch {
            print("Error loading location data \(error.localizedDescription)")
        }
        
        return locations
    }
    
    func getLocationData(addressId: Int)-> Address? {
        var selectedLocation : Address?
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        let folderPredicate = NSPredicate(format: "addressId=%i", addressId)
        request.predicate = folderPredicate
        do {
            let location = try context.fetch(request)
            selectedLocation = location.first
        } catch {
            print("Error loading location data \(error.localizedDescription)")
        }
        
        return selectedLocation
    }
    
    func loadTransactionList(email : String) -> [Payment]{
        var transactionList = [Payment]()
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        let folderPredicate = NSPredicate(format: "booking.vendor.email=%@", email)
        request.predicate = folderPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        request.fetchLimit = 10
        do {
            transactionList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
        }
        return transactionList
    }
    
    func deleteClients() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Client")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteServices() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Service")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteAddresss() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Address")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteBookings() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Booking")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteMediaFiles() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"MediaFile")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteAccounts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Account")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteCategory() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Category")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deletePayments() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"Payment")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func deleteVendorReviews() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName:"VendorReview")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func getVendorBankAccount(email : String) -> Account?{
        var account : Account?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Account")
        fetchRequest.predicate = NSPredicate(format: "parent_vendor.email=%@",email)
        do {
            let accounts = try context.fetch(fetchRequest)
            account = accounts.first as? Account
        } catch {
            print(error)
        }
        return account
    }
    
    func fetchSelectedBooking(bookingId : Int16) -> Booking? {
        var selectedBooking : Booking?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Booking")
        fetchRequest.predicate = NSPredicate(format: "bookingId=%i", bookingId)
        do {
            let booking = try context.fetch(fetchRequest)
            selectedBooking = booking.first as? Booking
        } catch {
            print(error)
        }
        return selectedBooking
    }
    
    func checkClientBooking(email : String , serviceId : Int16) -> Bool{
        var success = false
        let statusArray = ["New", "Pending", "In Progress"]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Booking")
        fetchRequest.predicate = NSPredicate(format: "client.email=%@ AND service.serviceId=%i AND status IN %@" ,email, serviceId, statusArray)
        do {
            let booking = try context.fetch(fetchRequest)
            if booking.count >= 1 {
                success = true
            }
        } catch {
            print(error)
        }
        return success
    }
}
