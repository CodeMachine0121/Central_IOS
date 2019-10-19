//
//  LoginController.swift
//  Central
//
//  Created by James on 2019/9/3.
//  Copyright © 2019年 James. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var JmpBtn: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    let WB = WalletBLE()
    override func viewDidLoad() {
        super.viewDidLoad()
        WB.Connect()
        loading.stopAnimating()
        JmpBtn.isHidden=true
        JmpBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onclick(_ sender: Any) {
        loading.startAnimating()
        let pa = password.text
        let v = WB.Login(password: pa!)
        Confirm(msg: v)
        
        if v != "Login success"{
            print("wrong")
           return
        }
    }
    
    
  

    func Confirm(msg:String){
        let ViewController = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "是的", style: .default) { (action) in
            
            if msg == "Login success" {
                
                //self.WB.DisConnect()
                print("msg\(msg)")
                
                self.JmpBtn.isEnabled=true
                self.password.isEnabled = false
                self.JmpBtn.sendActions(for: .touchUpInside)
                
               
               
            }
            self.password.text=""
            //print("yes")
            self.loading.stopAnimating()
        }
        
        ViewController.addAction(okAction)
        
        present(ViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogSegue"{
            let vc = segue.destination as! ViewController
            vc.WB = self.WB
            vc.password = self.password.text
        }
    }
    
    // 收鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
