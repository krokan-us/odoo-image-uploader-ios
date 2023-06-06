import UIKit
import AVFoundation

class AddImageViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var photoRollButton: UIButton!
    @IBOutlet weak var captureImageButton: UIButton!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var isFlashOn = false
    
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
        guard let captureSession = captureSession else {
            print("Capture session is not configured.")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = false
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        } else {
            print("Unable to add photo output to the capture session.")
        }
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
        
        let imageName = UUID().uuidString
        
        NetworkManager.shared.addImage(productID: productID ?? 0, name: imageName, imageData: base64String) { success, message, imageID in
            if success {
                print("Image uploaded successfully. Message: \(message ?? "") Image ID: \(imageID ?? 0)")
                // Handle the successful upload
            } else {
                print("Failed to add image. Message: \(message ?? "")")
                // Handle the failure
            }
        }
    }
}

extension AddImageViewController: AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error converting AVCapturePhoto to data representation: \(error?.localizedDescription ?? "")")
            return
        }
        
        uploadImage(imageData)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            // Convert the selected image to data representation
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Error converting UIImage to data representation")
                return
            }
            
            uploadImage(imageData)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}