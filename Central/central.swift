//
//  central.swift
//  Central
//
//  Created by James on 2019/7/26.
//  Copyright © 2019年 James. All rights reserved.
//

import Foundation
import CoreBluetooth

class central:NSObject,CBCentralManagerDelegate , CBPeripheralDelegate{
   
    //GATT
    let Service="1823"
    let URI = "2AB6"
    let Body = "2AB9"
    let Contol = "2ABA"
    let TransData = "1001"
    let To_Addr = "1000"
    
    var body:String?
  
    override init() {
        super.init()
    }
    
    func GetBody() -> String{
        return body ?? "empty"
    }
    
    func SetBody(str:String){
        body = str
    }
    
    func ReadBody(){
        let characteristic = self.charDictionary[Body]!
        self.connectPeripheral.readValue(for: characteristic)
    }
    
    func ToAddress(address:String){
        let data = address.data(using: .utf8)
        do{
            try sendData(data!, uuidString: To_Addr, writeType: .withResponse)
        }catch{
            print("\(error)")
        }
    }
    func WriteTransactionData(trandata:String){
        let data = trandata.data(using: .utf8)
        do{
            try sendData(data!, uuidString: TransData, writeType: .withResponse)
        }catch{
            print("\(error)")
        }
        
    }       
    func WriteUri(uri:String){
        let data = uri.data(using: .utf8)
        do{
            try sendData(data!, uuidString: URI, writeType: .withResponse)
        }catch{
            print( "\(error)")
        }
    }
    func WriteControl(control:String){
        let data = control.data(using: .utf8)
        do{
            try sendData(data!, uuidString: Contol, writeType: .withResponse)
        }catch{
            print("\(error)")
        }
    }
    
    
    
    enum SendDataError :Error{
        case CharacteristicNotFound
    }
    
    
    var centralManager:CBCentralManager!
    var connectPeripheral:CBPeripheral!
    var charDictionary = [String:CBCharacteristic]()
    
    
    func Startconnect(){
        let queue = DispatchQueue.global()
        // trig first method
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    // The first method
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("Turn on bluetooth service please!")
            return
        }
        print("jump 2")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
    }
    
    // second method
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard  let deviceName = peripheral.name  else{
            return
        }
        print("find device: \(peripheral.name)")
        guard deviceName.range(of: "EthereumWallet") != nil || deviceName.range(of: "HPService") != nil else {
            print("Can't find device !")
            return
        }
        print("Get device")
        central.stopScan()
        
        
        // 斷線處理
        
        
        connectPeripheral = peripheral
        connectPeripheral.delegate=self
        
        //trig third method
        print("jump 3")
        centralManager.connect(connectPeripheral, options: nil)
    }
    
    //third method
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //init characteristic
        charDictionary=[:]
        //trig forth method
        print("jump 4")
        peripheral.discoverServices(nil)
    }
    
    //forth method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("\(#file , #function)")
            print("worng")
            return
        }
        
        for service in peripheral.services!{
            // trig fifth method
            print("5")
            connectPeripheral.discoverCharacteristics(nil, for: service)
        
        }
    }
    
    //fifth method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("\(#file , #function)")
            return
        }
        for characteristic in service.characteristics!{
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            print("find characteristic: \(uuidString)")
        }
        print("5 end")
    }
    
    // write ble
    func sendData(_ data:Data , uuidString:String , writeType:CBCharacteristicWriteType)throws {
        guard let characteristic = charDictionary[uuidString] else  {
            print( "Characteristic not found!")
            throw SendDataError.CharacteristicNotFound
        }
        connectPeripheral.writeValue(data, for: characteristic,type: writeType )
    }
    
    
    // read value change from perpheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error==nil else {
            print("\(#file,#function)")
            return
        }
        if characteristic.uuid.uuidString == Body{
            let data = characteristic.value! as NSData
            var body = String(data:data as Data,encoding:.utf8)!
            print("body",body)
            self.SetBody(str: body)
            
            //textview.text = body
            
        }else if characteristic.uuid.uuidString == "2AB8"{
            let data = characteristic.value! as NSData
            var status = String(data:data as Data, encoding:.utf8)!
            
        }
        
    }
    
    
    
    // if there's a error during transfering data
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil{
            print( "寫入資料錯誤\(error!)")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("連線中斷")
    }
    
    func unpair(){
        
        let user = UserDefaults.standard
        user.removeObject(forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        centralManager.cancelPeripheralConnection(connectPeripheral)
    }
   
}
