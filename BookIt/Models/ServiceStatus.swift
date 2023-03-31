//
//  ServiceStatus.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-30.
//

import Foundation

enum ServiceStatus{
    case NEW
    case PENDING
    case IN_PROGRESS
    case COMPLETED
    case REJECTED
    case CANCELLED
    
    var title: String {
        switch self
        {
        case .NEW:
                return "New"
        case .PENDING:
                return "Pending"
        case .IN_PROGRESS:
                return "Inprogress"
        case .COMPLETED:
                return "Completed"
        case .REJECTED:
                return "Rejected"
        case .CANCELLED:
                return "Cancelled"
        }
    }
    var desc:(forClient:String,forVendor:String){
        switch self
        {
        case .NEW:
                return ("Requested","New Request")
        case .PENDING:
                return ("Pending Payment","Pending Payment")
        case .IN_PROGRESS:
                return ("In Progress","In Progress")
        case .COMPLETED:
                return ("Completed","Completed")
        case .REJECTED:
                return ("Rejected","Rejected")
        case .CANCELLED:
                return ("Cancelled","Cancelled")
        }
    }
    var nextStep:(forClient:String,forVendor:String){
        switch self
        {
        case .NEW:
                return ("Cancel","Cancel")
        case .PENDING:
                return ("Make a Payment","Payment Pending")
        case .IN_PROGRESS:
                return ("In Progress","Mark as Complete")
        case .COMPLETED:
                return ("Completed","Completed")
        case .REJECTED:
                return ("Rejected","Rejected")
        case .CANCELLED:
                return ("Cancelled","Cancelled")
        }
    }
    
    
}
