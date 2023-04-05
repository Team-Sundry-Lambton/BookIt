//
//  ServiceRequestObjects.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-04.
//

import Foundation

//Patameter object for user make payment
struct UserPaymentParam: Codable {
    let clientEmail: String
    let bookingId: String
    let vendorEmail : String
    
    func toJSON() -> [String: Any] {
        return [
            "clientEmail": clientEmail as Any,
            "bookingId": bookingId as Any,
            "vendorEmail": vendorEmail as Any,
        ]
    }
}
