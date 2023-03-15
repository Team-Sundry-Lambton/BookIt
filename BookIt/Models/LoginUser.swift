//
//  LoginUser.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-02-28.
//

import Foundation

struct LoginUser : Codable{
    var firstName : String
    var lastName : String
    var email : String
    var contactNumber : String
    var picture : URL?
    var isVendor : Bool
    
}