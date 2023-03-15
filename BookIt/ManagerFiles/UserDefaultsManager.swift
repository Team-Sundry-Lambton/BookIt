//
//  UserDefaultsManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-04.
//

import Foundation

class UserDefaultsManager : NSObject{
    static let shared = UserDefaultsManager()
    let defaults = UserDefaults.standard
    
    func saveUserData(user: LoginUser) {
        // To store in UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            defaults.set(encoded, forKey: "UserObject")
        }
    }
    
    func getUserData() -> LoginUser {
       
        // Retrieve from UserDefaults
        if let data = defaults.object(forKey: "UserObject") as? Data,
           let user = try? JSONDecoder().decode(LoginUser.self, from: data) as? LoginUser {
            return user
        }
        
        return LoginUser(firstName: "", lastName: "", email: "", contactNumber: "", isVendor: false)
    }
    
    func removeUserData() {
        defaults.removeObject(forKey: "UserObject")
    }
    
    func setUserLogin(status : Bool){
        defaults.set(status, forKey: "UserLogin")
    }
    
    func getUserLogin() -> Bool{
        return defaults.bool(forKey: "UserLogin")
    }
    
    func removeUserLogin() {
        defaults.removeObject(forKey: "UserLogin")
    }
    
    func setIsVendor(status : Bool){
        defaults.set(status, forKey: "Vender")
    }
    
    func getIsVendor() -> Bool{
        return defaults.bool(forKey: "Vender")
    }
    
    func setFaceIdEnable(status : Bool){
        defaults.set(status, forKey: "EnableFaceID")
    }
    
    func getFaceIdEnable() -> Bool{
        return defaults.bool(forKey: "EnableFaceID")
    }
    
    func setNotificationEnable(status : Bool){
        defaults.set(status, forKey: "EnableNotification")
    }
    
    func getNotificationEnable() -> Bool{
        return defaults.bool(forKey: "EnableNotification")
    }
}
