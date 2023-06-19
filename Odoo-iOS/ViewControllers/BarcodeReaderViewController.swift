import UIKit
import AVFoundation

class BarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var isBarcodeDetected = false
    var isFlashOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarcodeReader()
        addTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageTitle.text = NSLocalizedString("scanTheBarcodeFirst", comment: "")
        isFlashOn = false
        flashButton.setTitle("", for: .normal)
        flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        isBarcodeDetected = false
        startBarcodeReader()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFlashOn {
            toggleFlashlight()
        }
        stopBarcodeReader()
    }

    @IBAction func flashButtonTapped(_ sender: Any) {
        toggleFlashlight()
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

    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = cameraView.bounds
    }
    
    private func setupBarcodeReader() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Unable to access the camera.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code39, .code128]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = cameraView.bounds
            videoPreviewLayer?.contentsGravity = .resizeAspectFill
            cameraView.layer.addSublayer(videoPreviewLayer!)
        } catch {
            print("Error setting up barcode reader: \(error)")
        }
    }
    
    private func startBarcodeReader() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopBarcodeReader() {
        captureSession?.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isBarcodeDetected,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcodeValue = metadataObject.stringValue
        else {
            return
        }
        
        isBarcodeDetected = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let displayImagesVC = storyboard.instantiateViewController(withIdentifier: "displayImages") as? DisplayImagesViewController {
            displayImagesVC.productBarcode = barcodeValue
            displayImagesVC.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self.present(displayImagesVC, animated: false)
            }
        }
    }
    
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
