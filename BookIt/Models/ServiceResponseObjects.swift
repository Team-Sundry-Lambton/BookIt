//
//  ServiceResponseObjects.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-04.
//

import Foundation

//Response object for user payment
struct UserPayment: Decodable {
    let userEmail: String
    let status : Bool
    
    enum CodingKeys: String, CodingKey {
    case userEmail
    case status
  }
}
