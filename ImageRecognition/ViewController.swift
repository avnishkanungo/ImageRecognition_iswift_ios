//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Avnish Kanungo on 01/02/18.
//  Copyright © 2018 Avnish Kanungo. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Label"
        label.font = label.font.withSize(30)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCaptureSession()
        
        view.addSubview(label)
        setupLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCaptureSession(){
        
        let captureSession = AVCaptureSession()
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        do {
            if let captureDevice = availableDevices.first {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
        let captureOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(captureOutput)
        
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()

    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sample: CMSampleBuffer,from connection: AVCaptureConnection){
        guard let model = try? VNCoreMLModel(for:Resnet50().model)else{return}
        let request = VNCoreMLRequest(model: model) { (finishedRequests, error) in
            guard let results = finishedRequests.results as? [VNClassificationObservation] else {return}
            guard let Observations = results.first else {return}
            
            DispatchQueue.main.async(execute: {
                self.label.text = "\(Observations.identifier)"
            })
            
        }
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample) else {return}
        try? VNImageRequestHandler(cvPixelBuffer:pixelBuffer, options:[:]).perform([request])
    }
    func setupLabel() {
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }

}

