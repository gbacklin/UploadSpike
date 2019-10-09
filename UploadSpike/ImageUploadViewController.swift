//
//  ImageUploadViewController.swift
//  UploadSpike
//
//  Created by Backlin,Gene on 11/1/18.
//  Copyright © 2018 My Company. All rights reserved.
//

import UIKit

class ImageUploadViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var imageUploadProgressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var uploadButton: UIBarButtonItem!
    @IBOutlet weak var statusTextView: UITextView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - @IBAction methods
    
    @IBAction func uploadButtonTapped(sender: AnyObject) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }

    @IBAction func downloadButtonTapped(sender: AnyObject) {
        downloadImage(url: "http://www.ehmz.org/rest/uploads/image.jpeg")
    }
    
    // MARK: - Download methods
    
    func downloadImage(url: String) {
        let downloadTaskURL = URL(string: url)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        self.statusTextView.text = ""
        
        let task = session.downloadTask(with: downloadTaskURL!)
        task.resume()
    }

    // MARK: - Upload methods
    
    func uploadImage(url: String) {
        let imageData = myImageView.image!.jpegData(compressionQuality: 1)

        if(imageData == nil ) { return }
        
        self.uploadButton.isEnabled = false
        self.statusTextView.text = ""
        
        let uploadScriptUrl = URL(string: url)
        let request = NSMutableURLRequest(url: uploadScriptUrl!)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.setValue("multipart/form-data;", forHTTPHeaderField: "Content-Type")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        request.httpBodyStream = InputStream(data: imageData!)

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
//        let task = session.uploadTask(with: request as URLRequest, from: imageData!)
        
        let task = session.uploadTask(with: request as URLRequest, from: imageData!) { [weak self] (data, response, error) in
            print("response: \(String(describing: response))")
            
            if let returnData = String(data: data!, encoding: .utf8) {
                print("returnData: \(returnData)")
            }

            self!.statusTextView.text = response!.description
            self!.uploadButton.isEnabled = true
        }
        task.resume()
    }
    
    func uploadImage(name: String, ok: String, url: String) {
        let url = NSURL(string:url)
        let request = NSMutableURLRequest(url: url! as URL)
        let boundary = "Boundary-\(UUID().uuidString)"
        let mimetype = "image/jpeg"
        let image_data = myImageView.image!.jpegData(compressionQuality: 1)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(name)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)

        request.httpBody = body as Data
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)

        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString!)
        }
        task.resume()
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ImageUploadViewController: UIImagePickerControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        myImageView.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        
        myImageView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
        
        uploadImage(url: "http://www.ehmz.org/rest/upload.php?name=images.jpeg")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - URLSessionDataDelegate

extension ImageUploadViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceiveResponse")
        print(response);
        self.statusTextView.text = response.description
        self.uploadButton.isEnabled = true
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceiveData")
    }
}

// MARK: - URLSessionTaskDelegate

extension ImageUploadViewController: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("didCompleteWithError")

            let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel) {[weak self] (action) in
                print("Cancel tapped")
                self!.uploadButton.isEnabled = true
            }
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Upload methods
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("didSendBodyData")
        let progress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        imageUploadProgressView.progress = progress
        let progressPercent = Int(progress*100)
        progressLabel.text = "\(progressPercent)%"
        print(progress)
    }
}

// MARK: - URLSessionDownloadDelegate

extension ImageUploadViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("didWriteData")
        
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            imageUploadProgressView.progress = progress
            let progressPercent = Int(progress*100)
            progressLabel.text = "\(progressPercent)%"
            print(progress)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Download finished: \(location)")
        let data = try! Data(contentsOf: location)
        myImageView.image = UIImage(data: data)
    }
}

/*
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectPicture(_ sender: AnyObject) {
        
        let ImagePicker = UIImagePickerController()
        ImagePicker.delegate = self
        ImagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(ImagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        image.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upload_request(_ sender: AnyObject) {
        UploadRequest()
    }
    
    func UploadRequest()
    {
        let url = URL(string: "http://127.0.0.1/imgJSON/img.php")
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (image.image == nil)
        {
            return
        }
        
        let image_data = UIImagePNGRepresentation(image.image!)
        
        if(image_data == nil)
        {
            return
        }
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        let session = URLSession.shared
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print(dataString)
        }
        task.resume()
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }

func uploadImages(request: NSURLRequest, images: [UIImage]) {
    
    let uuid = NSUUID().UUIDString
    let boundary = String(count: 24, repeatedValue: "-" as Character) + uuid
    
    // Open the file
    let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
    
    let fileURL = directoryURL.URLByAppendingPathComponent(uuid)
    let filePath = fileURL.path!
    
    NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
    
    let file = NSFileHandle(forWritingAtPath: filePath)!
    
    
    // Write each image to a MIME part.
    let newline = "\r\n"
    
    for (i, image) in images.enumerate() {
        
        let partName = "image-\(i)"
        let partFilename = "\(partName).png"
        let partMimeType = "image/png"
        let partData = UIImagePNGRepresentation(image)
        
        // Write boundary header
        var header = ""
        header += "--\(boundary)" + newline
        header += "Content-Disposition: form-data; name=\"\(partName)\"; filename=\"\(partFilename)\"" + newline
        header += "Content-Type: \(partMimeType)" + newline
        header += newline
        
        let headerData = header.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        print("")
        print("Writing header #\(i)")
        print(header)
        
        print("Writing data")
        print("\(partData!.length) Bytes")
        
        // Write data
        file.writeData(headerData!)
        file.writeData(partData!)
    }
    
    // Write boundary footer
    var footer = ""
    footer += newline
    footer += "--\(boundary)--" + newline
    footer += newline
    
    print("")
    print("Writing footer")
    print(footer)
    
    let footerData = footer.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    file.writeData(footerData!)
    
    file.closeFile()
    
    // Add the content type for the request to multipart.
    let outputRequest = request.copy() as! NSMutableURLRequest
    
    let contentType = "multipart/form-data; boundary=\(boundary)"
    outputRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    
    // Start uploading files.
    upload(outputRequest, fileURL: fileURL)
}
 */
/*
func upload(request: NSURLRequest, data: NSData)
{
    // Create a unique identifier for the session.
    let sessionIdentifier = NSUUID().UUIDString
    
    let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
    let fileURL = directoryURL.URLByAppendingPathComponent(sessionIdentifier)
    
    // Write data to cache file.
    data.writeToURL(fileURL, atomically: true);
    
    let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionIdentifier)
    
    let session: NSURLSession = NSURLSession(
        configuration:configuration,
        delegate: self,
        delegateQueue: NSOperationQueue.mainQueue()
    )
    
    // Store the session, so that we don't recreate it if app resumes from suspend.
    sessions[sessionIdentifier] = session
    
    let task = session.uploadTaskWithRequest(request, fromFile: fileURL)
    
    task.resume()
}

// Called when the app becomes active, if an upload completed while the app was in the background.
func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: CompletionHandler) {
    
    let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
    
    if sessions[identifier] == nil {
        
        let session = NSURLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        sessions[identifier] = session
    }
    
    completionHandlers[identifier] = completionHandler
}

func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    
    // Handle background session completion handlers.
    if let identifier = session.configuration.identifier {
        
        if let completionHandler = completionHandlers[identifier] {
            completionHandler()
            completionHandlers.removeValueForKey(identifier)
        }
        
        // Remove session
        sessions.removeValueForKey(identifier)
    }
    
    // Upload completed.
}
}
*/

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
