//
//  NetworkManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-04.
//

import Foundation
import Alamofire

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    //Get the base url
    func getBaseUrl() -> String {
        
        if let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: infoPlistPath)
                
                if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                    guard let urlString = dict["Base url"] as? String else { return "" }
                    return urlString
                }
            } catch {
                print(error)
            }
        }
        return "http://34.201.209.204:8009/"
    }
    
    //User make the payment
    func makePayment(urlStr: String,postData: [String: Any],completionHandler:@escaping ( _ success: Bool, _ resultVal: UserPayment?) -> Void) {
        
        let serviceURl = getBaseUrl() + urlStr
        let request =  AF.request(serviceURl, method: .post, parameters: postData,
                                  encoding: JSONEncoding.default)
        
        request.responseData { (response) in
            switch response.result {
            case .success( let data):
                
                do {
                    let payment = try JSONDecoder().decode(UserPayment.self, from: data)
                    print(payment.userEmail)
                    completionHandler(true,payment)
                }
                catch {
                    print(error)
                    completionHandler(false,nil)
                }
                
            case .failure(let error):
                print (error)
                completionHandler(false,nil)
            }
        }
    }
}
