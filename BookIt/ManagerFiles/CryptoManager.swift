//
//  CryptoManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-04-07.
//

import CryptoSwift

let encryptionKey:String = "2tC2H19lkVDGRTWkxcrtNMQdd0FloLyw";
let encryptionIV:String = "bbC2H19lRE3gwbQDfak";

public func encryptString(test : String) -> String{
    let encryptedString:String = try! test.aesEncrypt(key: encryptionKey, iv: encryptionIV)
    print("Test : ", test)
    print("Encrypted Test : ", encryptedString)
    return encryptedString
}

public func dencryptString(encyrptedString : String) ->String {
    let dencryptedString:String = try! encyrptedString.aesDecrypt(key: encryptionKey, iv: encryptionIV)
    print("Encrypted Test : ", encyrptedString )
    print("Decrypted Test : ",dencryptedString)
    return dencryptedString
}
