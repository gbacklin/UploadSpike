//
//  ViewController.swift
//  UploadSpike
//
//  Created by Backlin,Gene on 11/1/18.
//  Copyright © 2018 My Company. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     https://fluffy.es/upload-image-to-server/#swiftcode
     */
    func upload(tmpImage: UIImage?) {
        // the image in UIImage type
        guard let image = tmpImage else { return  }
        
        let filename = "avatar.png"
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let fieldName = "reqtype"
        let fieldValue = "fileupload"
        
        let fieldName2 = "userhash"
        let fieldValue2 = "caa3dce4fcb36cfdf9258ad9c"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add the reqtype field and its value to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        
        // Add the userhash field and its value to the raw http reqyest data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue2)".data(using: .utf8)!)
        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
            }
        }).resume()
    }

    func postRequest(){
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://httpbin.org/anything")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        // your post request data
        let postDict : [String: Any] = ["name": "axel", "favorite_animal": "fox"]
        
        guard let postData = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
            return
        }
        
        urlRequest.httpBody = postData
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // ...
        }
        
        task.resume()
    }

}

