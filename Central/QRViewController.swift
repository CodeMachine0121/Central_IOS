//
//  QRViewController.swift
//  Central
//
//  Created by James on 2019/7/26.
//  Copyright © 2019年 James. All rights reserved.
//

import UIKit
import AVFoundation
class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    
    
    @IBOutlet weak var forPreview: UIView!
    var address :String? = nil
    let session  = AVCaptureSession()
    let deviceInput =  DeviceInput()
    func settingPreviewLayer(){
        let previewer  = AVCaptureVideoPreviewLayer()
        previewer.frame = forPreview.bounds
        previewer.session = session
        previewer.videoGravity = .resizeAspectFill
        forPreview.layer.addSublayer(previewer)
    }
    
    @IBOutlet weak var BackTr: UIButton!
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metaData in metadataObjects{
            if let data = metaData as? AVMetadataMachineReadableCodeObject{
                DispatchQueue.main.async {
                    // back to Transaction View
                    self.address=data.stringValue
                    self.BackTr.sendActions(for: .touchUpInside)
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        settingPreviewLayer()
        session.addInput(deviceInput.backWildAngleCamera!)
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.global())
        
        //start
        session.startRunning()
    }
    
    
    
    

}
