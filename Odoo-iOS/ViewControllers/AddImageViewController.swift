//
//  AddImageViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 4.06.2023.
//

import UIKit
import AVFoundation

class AddImageViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var photoRollButton: UIButton!
    @IBOutlet weak var captureImageButton: UIButton!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        configurePreviewLayer()
        startCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.setTitle("", for: .normal)
        photoRollButton.setTitle("", for: .normal)
        captureImageButton.setTitle("", for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = cameraView.bounds
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func configureCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access the camera.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
        } catch {
            print("Error setting up capture device input: \(error)")
        }
    }
    
    private func configurePreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = cameraView.bounds
        cameraView.layer.insertSublayer(videoPreviewLayer!, at: 0)
    }
    
    private func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCaptureSession() {
        captureSession?.stopRunning()
    }
}
