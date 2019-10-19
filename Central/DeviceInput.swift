//
//  DeviceInput.swift
//  TalbeView
//
//  Created by James on 2019/7/26.
//  Copyright © 2019年 James. All rights reserved.
//

import Foundation

import AVFoundation

class DeviceInput: NSObject {
    var frontWildAngleCamera:AVCaptureDeviceInput?
    var backWildAngleCamera:AVCaptureDeviceInput?
    var backTelephotoCamera:AVCaptureDeviceInput?
    
    var backDualCamera: AVCaptureDeviceInput?
    var microphone: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        getAllCameras()
       // getMicroPhone()
    }
    
    func getMicroPhone() {
        if let mic = AVCaptureDevice.default(for: .audio){
            microphone = try!AVCaptureDeviceInput(device: mic)
        }
    }
    
    func getAllCameras(){
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInTelephotoCamera,.builtInDualCamera], mediaType: .video, position: .unspecified).devices
        
        for camera in cameraDevices{
            let inputDevice = try! AVCaptureDeviceInput(device: camera)
            
            if camera.deviceType == .builtInWideAngleCamera,camera.position == .front{
                frontWildAngleCamera = inputDevice
            }
            if camera.deviceType == .builtInWideAngleCamera , camera.position == .back{
                backWildAngleCamera = inputDevice
            }
            if camera.deviceType == .builtInTelephotoCamera{
                backTelephotoCamera = inputDevice
            }
            if camera.deviceType == .builtInDualCamera{
                backDualCamera = inputDevice
            }
        }
        
        
    }
}
