//
//  ServiceRequestObjects.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-04.
//

import Foundation

//Patameter object for user make payment
struct UserPaymentParam: Codable {
    let bookingId: String
    
    func toJSON() -> [String: Any] {
        return [
            "bookingId": bookingId as Any
        ]
    }
}
