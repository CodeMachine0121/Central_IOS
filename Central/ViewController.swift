//
//  ViewController.swift
//  BLEsummer
//
//  Created by James on 2019/7/20.
//  Copyright © 2019年 James. All rights reserved.
//

import UIKit
import LocalAuthentication
import CryptoSwift
import AVFoundation


class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    
    var WB:WalletBLE? = nil
    let web3 = Web3working()
  
    
   
    // fingerprint
    let context = LAContext()
    var error : NSError?
    var password:String? = nil
    var id:String = ""
    var token:String = ""
    var address:String = ""
    var nonce:String = ""
    var balance:String = ""
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.turnonQR()
        // 收值
        if let password = password{ 
            self.password = password
            print("Password: ",self.password)
        }
        if let WB = WB{
            self.WB = WB
        }
        
        self.id = WB!.GetPrivHash()
        self.address = WB!.GetAddress()
        
        print("id: \(self.id)")
        print("address: \(self.address)")
        
        self.token = web3.GetToken(id: self.id)
        
        print("token: \(self.token)")
        if self.token == "account exist"{
            web3.DeleteRequest(id: self.id)
            sleep(1)
            self.token = web3.GetToken(id: self.id)
        }
        sleep(1)
        self.nonce = web3.GetNonce(id: self.id, token: self.token, address: self.address)
        
        print("nonce: \(nonce)")
        
        self.balance = web3.GetBalance(id: self.id, token: self.token, address: self.address)
        print("balance: \(balance)")
        verify()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Transaction_to_User"{
            let vc = segue.destination as! UserViewController
            vc.address = self.address
            vc.nonce = self.nonce
            vc.id = self.id
            vc.token = self.token
        }
            
    }
  
    
    
    @IBOutlet weak var Receiver: UITextView!
   // @IBOutlet weak var Receiver: UITextField!
    
    @IBOutlet weak var Value: UITextField!
    
    // QR segue back
    @IBAction func unwind(for segue: UIStoryboardSegue) {
        if segue.identifier == "from_QR_to_Tr"{
            let vc = segue.source as! QRViewController
            if let receiver_address = vc.address{
                Receiver.text = receiver_address
            }
        }
    }
    
    
    // gas
    @IBOutlet weak var gaslabel: UILabel!
    @IBOutlet weak var Gas: UISlider!
    
    @IBAction func GasChanged(_ sender: Any) {
        gaslabel.text = String(Int(Gas.value))
        
    }
    
    // gas price
    @IBOutlet weak var gaspricelabel: UILabel!
    @IBOutlet weak var GasPrice: UISlider!
    @IBAction func Gasprice_Change(_ sender: Any) {
        gaspricelabel.text = String(Int(GasPrice.value))
    }
    
    
    // 交易確定鈕
    
    @IBOutlet weak var submit_btn: UIButton!
    @IBAction func sumbitTransaction(_ sender: Any) {
       // submit_btn.isEnabled = false
        Confirm()
    }
    
   // 打包交易
    var txn:String=""
    func doTransaction(){
        
        submit_btn.isEnabled=false
        let recv :String = Receiver.text!
        let value = Value.text!
        
        print("Value wanted to send: \(value)")
        let gas :String = String(Int(Gas.value))
        let gasprice :String = String(Int(GasPrice.value))
        
        guard  recv != self.address else{
            self.Alert(msg: "Address is same")
            self.Clear()
            return
        }
        Value.isEnabled=false
        Gas.isEnabled=false
        GasPrice.isEnabled=false
        

        self.txn = WB!.GetTransaction(password:self.password!,recv: recv, value: value, nonce: nonce, gas: gas, gasprice: gasprice)
        
        
        print("Txn: \(self.txn)")
        
        if self.txn == "Value Error" ||  self.txn == "Address Error"{
            submit_btn.isEnabled=true
            Alert(msg: self.txn)
            Clear()
        }else{
            send.isEnabled=true
            Alert(msg: "Successfully")
        }
        
        
    }
    
    @IBOutlet weak var send: UIButton!
    //發送讀取txn
    @IBAction func sendTrans_Web3(_ sender: Any) {
        
        
        var txnResp = web3.requestTransaction(id: self.id, token: self.token, txn: self.txn)
        
        if(txnResp == "Successfully"){
            WB!.SetBalance(balance: Value.text!)
            self.nonce = web3.GetNonce(id: self.id, token: self.token, address: self.address)
            self.balance = web3.GetBalance(id: self.id, token: self.token, address: self.address)
            WB?.yourBalance(balance: self.balance)
            print("next\(self.nonce)")
            
        }
        self.Clear()
        Alert(msg: txnResp)
    }
    //清除所有數值
    func Clear(){
        submit_btn.isEnabled = true
        send.isEnabled = false
        Value.isEnabled=true
        Gas.isEnabled=true
        GasPrice.isEnabled=true
        //Receiver.text=nil
        
        Value.text=nil
        
    }
    
    // 確定視窗
    func Confirm(){
        let ViewController = UIAlertController(title: "Info", message: "確定交易資訊正確？ ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "是的", style: .default) { (action) in
            self.doTransaction()
            //print("yes")
        }
        
        ViewController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default ){ (action) in
            self.Clear()
        }
        ViewController.addAction(cancelAction)
        present(ViewController, animated: true, completion: nil)
    }
    
    
    // 警告視窗
    func Alert(msg:String){
        let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style:.default, handler: {(action) in alert.dismiss(animated: true, completion: nil) }  ))
       self.present(alert, animated: true, completion: nil)
    }
    
    
  
    func check()->Bool{
        if #available(iOS 9.0, *){
            let b:Bool = context.canEvaluatePolicy(.deviceOwnerAuthentication
                , error: &error)
            return b
        }
        else{
            return false
        }
    }
    
    func verify(){
        if check(){
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account", reply: {success , error in
                
                if success {
                    self.Alert(msg:"Login Successful")
                    self.WB?.yourBalance(balance: self.balance)
                }else{
                    if let error = error as NSError?{
                        self.Alert(msg: error.localizedDescription )
                        print("Verify Fail")
                          exit(0)
                    }
                }
            })
        }else{
            Alert(msg: "Device not Surpport")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    // 收鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    //QR
    
    @IBOutlet weak var QRView: UIView!
    
    func turnonQR(){
        settingPreviewLayer()
        session.addInput(deviceInput.backWildAngleCamera!)
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.global())
        
        //start
        session.startRunning()
    }
   
    @IBAction func QRBtn(_ sender: Any) {
        QRView.isHidden = false
    }
    
    let session  = AVCaptureSession()
    let deviceInput =  DeviceInput()
    func settingPreviewLayer(){
        let previewer  = AVCaptureVideoPreviewLayer()
        previewer.frame = QRView.bounds
        previewer.session = session
        previewer.videoGravity = .resizeAspectFill
        QRView.layer.addSublayer(previewer)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metaData in metadataObjects{
            if let data = metaData as? AVMetadataMachineReadableCodeObject{
                DispatchQueue.main.async {
                    self.Receiver.text=data.stringValue!
                    self.QRView.isHidden = true
                }
            }
        }
    }
    
    
}
