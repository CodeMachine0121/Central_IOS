//
//  Cipher.swift
//  Central
//
//  Created by James on 2019/8/29.
//  Copyright © 2019年 James. All rights reserved.
//

import Foundation
import CryptoSwift

class Cipher {
    func aesEncrypt(plaintext:String,key:String,iv:String)->String{
        
        do{
            var text = plaintext
            let key = key.hexadecimal()!
            let iv = iv.hexadecimal()!
            print("encrypt(plaintext:\(plaintext) , key:\(key) , iv:\(iv) )")
            print("plaintext count:\(plaintext.count)")
            if(!(plaintext.count%16 == 0)){
                for i in 1...plaintext.count%16{
                    text.append(" ")
                }
                print("text count:\(text.count)")
            }
            
            let encrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes)).encrypt(Array(text.utf8))
            print("en: \(encrypted.toHexString())")
            return encrypted.toHexString()
        }catch{
            print("\(error.localizedDescription)")
        }
        return "empty"
    }
    func aesDecrypt(ciphertext:String , key:String,iv:String)->String{
        
        do{
            let key = key.hexadecimal()!
            let iv = iv.hexadecimal()!
            let cipher = ciphertext.hexadecimal()!
            print("decrypt(ciphertext:\(ciphertext) , key:\(key) , iv:\(iv) )")
            let decrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes)).decrypt(cipher.bytes)
            print("de: \(String(bytes: decrypted, encoding: String.Encoding.ascii))")
            return String(bytes: decrypted, encoding: String.Encoding.ascii)?.trimmingCharacters(in: .whitespaces) ?? "empty"
        }catch{
            print("\(error.localizedDescription)")
        }
        return "empty"
    }
}
extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    func hexadecimal() -> Data? {
        var data = Data(capacity: characters.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}
