//
//  Web3working.swift
//  Central
//
//  Created by James on 2019/7/22.
//  Copyright © 2019年 James. All rights reserved.
//

import Foundation
class Web3working{
    
    var cipher = Cipher()
    var uri = "http://192.168.50.20:5000"

    
    func DeleteRequest(id:String){
        let url = URL(string: uri+"/"+id)
        print("Delete url: \(url)")
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
      
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        var resp:String=""
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            resp = "successful"
            print(resp)
        }
        task.resume()
    }
    func GetRequest(urlString:String) -> String {
        let u = uri  + urlString
        let url = URL(string: u)
        do{
            let Response = try String(contentsOf: url!)
            return Response
        }catch{
            return "error"
        }
    }
    // Post then Get
    func PostRequest(urlString:String , parameters:[String:String]){
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        let jsonString = String(data: jsonData!, encoding: String.Encoding.ascii)!
        print (jsonString)
        
        let u = uri + urlString
        let url = URL(string: u)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            var responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if var responseJSON = responseJSON as? [String: Any]{
                print("urlString: \(urlString)")
                self.setResponse(res: responseJSON["response"],urlString: urlString)
            }
        }
        task.resume()
    } 
    
    
   public var token:String = "empty"
   public var balance:String = "empty"
   public var nonce:String = "empty"
   public var response:String="empty"
    
    private func setResponse(res:Any? , urlString:String){
        if let r = res{
            
            switch urlString{
            case "/transaction":
                self.response = r as! String
            case "/nonce":
                self.nonce = r as! String
            case "/balance":
                self.balance = r as! String
            case "/get_token":
                self.token = r as! String
            default:
                print("urlString error")
            }
        }
        
    }
    
    
    func GetToken(id:String)->String{
        guard id != "" else {
            print("empty id")
            return self.response
        }
        print("w:id: \(id)")
        PostRequest(urlString: "/get_token", parameters: ["id":id])
        
        sleep(2)
        return self.token
    }
    
    func GetNonce(id:String,token:String,address:String)->String{
        guard token != nil , id != "" ,address != "" else {
            print("empty data")
            return self.nonce
        }
        let tokens = token.components(separatedBy: "xx")
      
        let key = tokens[0]
        let iv = tokens[1]
        var enaddress = cipher.aesEncrypt(plaintext: address, key: key, iv: iv)
        
        PostRequest(urlString: "/nonce", parameters: ["id":id, "token":token,"data":enaddress])
        
        sleep(1)
        
        self.nonce = cipher.aesDecrypt(ciphertext: self.nonce, key: key, iv: iv)
        
        return self.nonce
    }
    
    func GetBalance(id:String,token:String,address:String)->String{
        guard token != "", id != "" ,address != "" else {
            print("empty data")
            return "empty"
        }
        let tokens = token.components(separatedBy: "xx")
        let key = tokens[0]
        let iv = tokens[1]
        
        let enaddress = cipher.aesEncrypt(plaintext: address, key: key, iv: iv)
        
        PostRequest(urlString: "/balance", parameters: ["id":id, "token":token,"data":enaddress])
      
        sleep(1)
        self.balance = cipher.aesDecrypt(ciphertext: self.balance, key: key, iv: iv)
        return self.balance
    }
    
    func requestTransaction(id:String,token:String,txn:String)->String{
        guard token != nil , id != "" ,txn != "" else {
            print("empty data")
            return "fail"
        }
        let tokens = token.components(separatedBy: "xx")
        let key = tokens[0]
        let iv = tokens[1]
        let entxn = cipher.aesEncrypt(plaintext: txn, key: key, iv: iv)
        PostRequest(urlString: "/transaction", parameters: ["id":id, "token":token,"data":entxn])
        sleep(1)
        
        return self.response
        
    }
}
