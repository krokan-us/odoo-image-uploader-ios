import UIKit
import AVFoundation

class BarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var barcodeReaderView: UIView!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var isBarcodeDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarcodeReader()
        addTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isBarcodeDetected = false
        startBarcodeReader()
        barcodeReaderView.layer.borderWidth = 3
        barcodeReaderView.layer.borderColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
        barcodeReaderView.layer.zPosition = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBarcodeReader()
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
