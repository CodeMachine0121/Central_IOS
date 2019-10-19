//
//  WalletBLE.swift
//  Central
//
//  Created by James on 2019/7/30.
//  Copyright © 2019年 James. All rights reserved.
//

import Foundation

class WalletBLE{
    
    var address:String=""
    var id:String=""
    var ble = central()
    var response:String=""
   
    func DisConnect(){
        ble.unpair()
    }
    func Connect(){
        ble.Startconnect()
        sleep(2)
    }
    func Login(password:String)->String{
        ble.WriteUri(uri: "login")
        ble.WriteTransactionData(trandata: password)
        ble.WriteControl(control: "3")
        ble.ReadBody()
        var re:String = "empty"
        while true {
            re = ble.GetBody()
            if re != "empty"{
                ble.body = "empty"
                break
            }
        }
        
        self.response = re
        return re
    }
    
    func yourBalance(balance:String)->String{
        ble.WriteUri(uri: "yourBalance")
        ble.WriteTransactionData(trandata: balance)
        ble.WriteControl(control: "3")
        ble.ReadBody()
        var re:String = "empty"
        while true{
            re = ble.GetBody()
            if re != "empty"{
                ble.body = "empty"
                break
            }
        }
        self.response = re
        return re
    }
    
    func SetBalance(balance:String)->String{
        ble.WriteUri(uri: "setBalance")
        ble.WriteTransactionData(trandata: balance)
        ble.WriteControl(control: "3")
        ble.ReadBody()
        var re:String = "empty"
        while true{
            re = ble.GetBody()
            if re != "empty"{
                ble.body = "empty"
                break
            }
        }
        self.response = re
        return re
    }
    
   
    
    func GetPrivHash()->String{
        ble.WriteUri(uri: "priv_hash")
        ble.WriteControl(control: "1")
        ble.ReadBody()
        var id:String="empty"
        while true{
            id = ble.GetBody()
        
            if id != "empty"{
                ble.body = "empty"
                break
            }
        }
        self.id = id
        return id
    }
    
    func GetAddress()->String {
        ble.WriteUri(uri: "address")
        ble.WriteControl(control: "1")
        ble.ReadBody()
        var address="empty"
        while true{
            address = ble.GetBody()
            if address != "empty"{
                ble.body = "empty"
                break
            }
        }
        self.address = address
        return address
    }
    
    
    
    func GetTransaction(password:String, recv:String , value:String , nonce:String , gas:String , gasprice:String)->String{
        
        let trandata = value+String(",")+nonce+String(",")+gasprice+String(",")+gas
        var recv = password+String(",")+recv
        
        
        ble.WriteUri(uri: "ethertxn")
        
        ble.WriteTransactionData(trandata: trandata)
        
        ble.ToAddress(address: recv)
        
        ble.WriteControl(control: "3")
        sleep(2)
        ble.ReadBody()
        
        var txn = "empty"
        
        while true{
            txn = ble.GetBody()
            if txn != "empty"{
                ble.body = "empty"
                break
            }
        }
        return txn
    }
    
}
