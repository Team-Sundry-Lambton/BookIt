//
//  ServiceResponseObjects.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-04.
//

import Foundation

//Response object for user payment
struct UserPayment: Decodable {
    let message: String
    let result : Bool
    
    enum CodingKeys: String, CodingKey {
    case message
    case result
  }
}
