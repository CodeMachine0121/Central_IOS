//
//  UserViewController.swift
//  Central
//
//  Created by James on 2019/7/26.
//  Copyright © 2019年 James. All rights reserved.
//

import UIKit


class UserViewController: UIViewController {
    
    var web3 = Web3working()
    //var ble = central()
    //var WB = WalletBLE()
    var address:String? = nil
    var id:String? = nil
    var token:String? = nil
    var balance:String? = nil
    var nonce:String? = nil
    
    var refresh:UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = id{
            self.id = id
            print("User: ",id)
        }
        if let address = address{
            self.address = address
            print("User: ",self.address!)
        }
        if let nonce = nonce {
            self.nonce = nonce
            print("User: ",self.nonce!)
        }
        if let token = token{
            self.token = token
            print("User: \(self.token!)")
        }
        self.balance = web3.GetBalance(id: self.id! ,token: self.token!,address: self.address!)
        
        Address.text = self.address
        Nonce.text = self.nonce
        Balance.text = self.balance
        
        
    }
    
   
    

    @IBOutlet weak var Address: UITextView!

    @IBOutlet weak var Nonce: UILabel!
    
    @IBOutlet weak var Balance: UITextView!
    
    
    @IBAction func Refresh(_ sender: Any) {
        self.balance = web3.GetBalance(id: self.id!, token: self.token!, address: self.address!)
        Balance.text = self.balance
    }
    
    
   
   
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
