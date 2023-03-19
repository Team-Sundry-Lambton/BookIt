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
    
    func getClient(email : String) -> Client?{
        var client : Client?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Client")
        fetchRequest.predicate = NSPredicate(format: "email = %@ ", email)
        do {
            let users = try context.fetch(fetchRequest)
            client = users.first as? Client
        } catch {
            print(error)
        }
        return client
    }
    
    func getVendor(email : String) -> Vendor?{
        var vendor : Vendor?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Vendor")
        fetchRequest.predicate = NSPredicate(format: "email = %@ ", email)
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
    
    func getService(title : String) -> Service?{
        var service : Service?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Service")
        fetchRequest.predicate = NSPredicate(format: "serviceTitle = %@ ", title)
        do {
            let services = try context.fetch(fetchRequest)
            service = services.first as? Service
        } catch {
            print(error)
        }
        return service
    }
    
    func getMedia(name : String, serviceTitle : String) -> MediaFile?{
        var media : MediaFile?
        let fetchRequest: NSFetchRequest<MediaFile> = MediaFile.fetchRequest()
            let folderPredicate = NSPredicate(format: "parent_Service.serviceTitle=%@ AND mediaName=%@", serviceTitle,name)
        fetchRequest.predicate = folderPredicate
        do {
            let medias = try context.fetch(fetchRequest)
            media = medias.first as? MediaFile
        } catch {
            print("Error loading medias \(error.localizedDescription)")
        }
        return media
    }

    
    func deleteAllTables(){
        deleteVendors()
        deleteClients()
        deleteAccounts()
        deleteAddresss()
        deleteBookings()
        deleteCategory()
        deletePayments()
        deleteServices()
        deleteMediaFiles()
        deleteVendorReviews()
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
}
