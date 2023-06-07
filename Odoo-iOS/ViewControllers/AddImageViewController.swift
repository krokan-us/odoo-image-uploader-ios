//
//  AddImageViewController.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 4.06.2023.
//

import UIKit
import AVFoundation
import CropViewController

class AddImageViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var photoRollButton: UIButton!
    @IBOutlet weak var captureImageButton: UIButton!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var isFlashOn = false
    private var photoOutput: AVCapturePhotoOutput?
    
    var productID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        configurePreviewLayer()
        startCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.setTitle("", for: .normal)
        photoRollButton.setTitle("", for: .normal)
        captureImageButton.setTitle("", for: .normal)
        flashButton.setTitle("", for: .normal)
        flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFlashOn {
            toggleFlashlight()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = cameraView.bounds
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func flashButtonTapped(_ sender: Any) {
        toggleFlashlight()
    }
    
    @IBAction func photoRollButtonTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = false
            
        photoOutput?.capturePhoto(with: photoSettings, delegate: self)
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

        // Configure the photo output
        photoOutput = AVCapturePhotoOutput()
        if captureSession?.canAddOutput(photoOutput!) == true {
            captureSession?.addOutput(photoOutput!)
        } else {
            print("Unable to add photo output to the capture session.")
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
    
    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if isFlashOn {
                    device.torchMode = .off
                    flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
                } else {
                    try device.setTorchModeOn(level: 1.0)
                    flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
                }

                device.unlockForConfiguration()
                isFlashOn = !isFlashOn
            } catch {
                print("Flash could not be used")
            }
        } else {
            print("Device does not have a Flash light")
        }
    }
    
    func uploadImage(_ imageData: Data) {
        let base64String = imageData.base64EncodedString()
        
        // Display an alert with a text field to get the image name from the user
        let alertController = UIAlertController(title: NSLocalizedString("enterImageName", comment: ""), message: "", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("imageName", comment: "")
            textField.addTarget(self, action: #selector(self.imageNameTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        let submitAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: .default) { _ in
            let textField = alertController.textFields![0] as UITextField
            guard let imageName = textField.text else {
                return
            }
            let trimmedImageName = imageName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedImageName.isEmpty else {
                return
            }
            NetworkManager.shared.addImage(productID: self.productID ?? 0, name: trimmedImageName, imageData: base64String) { success, message, imageID in
                if success {
                    print("Image uploaded successfully. Message: \(message ?? "") Image ID: \(imageID ?? 0)")
                    
                    // Present an alert box saying the image is uploaded, dismiss it automatically
                    let successAlert = UIAlertController(title: NSLocalizedString("success", comment: ""), message: NSLocalizedString("imageUploaded", comment: ""), preferredStyle: .alert)
                    self.present(successAlert, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        successAlert.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("Failed to add image. Message: \(message ?? "")")
                    let errorAlert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
                    errorAlert.addAction(okAction)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
        submitAction.isEnabled = false

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)

        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }


    @objc func imageNameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let alertController = presentedViewController as? UIAlertController {
                alertController.actions.forEach { action in
                    if action.title == NSLocalizedString("submit", comment: "") {
                        action.isEnabled = false
                    }
                }
            }
        } else {
            if let alertController = presentedViewController as? UIAlertController {
                alertController.actions.forEach { action in
                    if action.title == NSLocalizedString("submit", comment: "") {
                        action.isEnabled = true
                    }
                }
            }
        }
    }
}

extension AddImageViewController: AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("Error converting AVCapturePhoto to data representation: \(error?.localizedDescription ?? "")")
            return
        }
        
        let cropViewController = CropViewController(image: image)
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.cropView.cropBoxResizeEnabled = false
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            let cropViewController = CropViewController(image: image)
            cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.resetAspectRatioEnabled = false
            cropViewController.cropView.cropBoxResizeEnabled = false
            cropViewController.delegate = self
            present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension AddImageViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error converting UIImage to data representation")
            return
        }
        cropViewController.dismiss(animated: true, completion: nil)
        uploadImage(imageData)
        self.dismiss(animated: true)
    }
}
