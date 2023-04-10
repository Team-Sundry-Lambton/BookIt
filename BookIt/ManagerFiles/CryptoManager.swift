//
//  CryptoManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-07.
//

import CryptoSwift

let encryptionKey = "2tC2H19lkVbQDfakxcrtNMQdd0FloLyw"
 let encryptionIV = "bbC2H19lkVbQDfak"

public func encryptString(test : String) -> String{
    var encryptedString = ""
    do {
    encryptedString = try test.aesEncrypt(key: encryptionKey, iv: encryptionIV)
        print("Test : ", test)
        print("Encrypted Test : ", encryptedString)
       
    } catch {
        print("ERROR")
    }
    return encryptedString
}

public func dencryptString(encyrptedString : String) ->String {
    var dencryptedString = ""
    do {
        dencryptedString = try encyrptedString.aesDecrypt(key: encryptionKey, iv: encryptionIV)
    print("Encrypted Test : ", encyrptedString )
    print("Decrypted Test : ",dencryptedString)
    
} catch {
    print("ERROR")
}
    return dencryptedString
}
