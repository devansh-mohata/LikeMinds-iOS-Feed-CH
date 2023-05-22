//
//  AWSS3Manager.swift
//  LMFeed
//
//  Created by Pushpendra Singh on 22/02/23.
//

import Foundation
import LMFeed
import AWSS3 //1

typealias progressBlock = (_ progress: Double) -> Void //2
//typealias completionBlock = (_ response: Any?, _ thumbNail: String?, _ error: Error?) -> Void //3
typealias completionBlock = (_ response: Any?, _ thumbNail: String?, _ error: Error?, _ index: Int?) -> Void //3

@objc public  class AWSS3Manager: NSObject {
    
    public static let shared = AWSS3Manager() // 4
    let bucketName = ServiceAPI.bucketURL//5 arn:aws:s3:::
    let accessKey = ServiceAPI.accessKey
    let secretKey = ServiceAPI.secretAccessKey
    
    
    @objc public func initializeS3() {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.APSouth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
    }
    
    // Upload image using UIImage object
    func uploadImage(filePath: String = "", image: UIImage,imageData:Data,index:Int?, progress: progressBlock?, completion: completionBlock?) {
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, nil, error, nil)
            return
        }
        
        let tmpPath = NSTemporaryDirectory() as String
        var fileName: String = ProcessInfo.processInfo.globallyUniqueString + (".jpeg")
        let localFilePath = tmpPath + "/" + fileName
        let fileUrl = URL(fileURLWithPath: localFilePath)
        fileName = filePath + fileName
        
        do {
            try imageData.write(to: fileUrl)
            self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: "image", thumbNail: nil, index: index, progress: progress, completion: completion)
        } catch {
            let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, nil, error, nil)
        }
    }
    
    // Upload video from local path url
    func uploadVideo(filePath: String = "", videoUrl: URL, thumbNail: String, progress: progressBlock?, completion: completionBlock?) {
        var fileName = self.getUniqueFileName(fileUrl: videoUrl)
        fileName = filePath + fileName
        
        self.uploadfile(fileUrl: videoUrl, fileName: fileName, contenType: "video", thumbNail: thumbNail, index: nil, progress: progress, completion: completion)
    }
    
    // Upload auido from local path url
    func uploadAudio(filePath: String = "", audioUrl: URL, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.getUniqueFileName(fileUrl: audioUrl)
        self.uploadfile(fileUrl: audioUrl, fileName: fileName, contenType: "audio", thumbNail: nil, index: nil, progress: progress, completion: completion)
    }
    
    // Upload files like Text, Zip, etc from local path url
    func uploadOtherFile(filePath: String = "",fileUrl: URL, conentType: String, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.getUniqueFileName(fileUrl: fileUrl)
        self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: conentType, thumbNail: nil, index: nil, progress: progress, completion: completion)
    }
    
    // Get unique file name
    func getUniqueFileName(fileUrl: URL) -> String {
        let strExt: String = "." + (URL(fileURLWithPath: fileUrl.absoluteString).pathExtension)
        return (ProcessInfo.processInfo.globallyUniqueString + (strExt))
    }
    
    //MARK:- AWS file upload
    // fileUrl :  file local path url
    // fileName : name of file, like "myimage.jpeg" "video.mov"
    // contenType: file MIME type
    // progress: file upload progress, value from 0 to 1, 1 for 100% complete
    // completion: completion block when uplaoding is finish, you will get S3 url of upload file here
    private func uploadfile(fileUrl: URL, fileName: String, contenType: String, thumbNail:String?, index: Int?, progress: progressBlock?, completion: completionBlock?) {
        // Upload progress block
        //        let expression = AWSS3TransferUtilityUploadExpression()
        //        expression.progressBlock = {(task, awsProgress) in
        //            guard let uploadProgress = progress else { return }
        //            DispatchQueue.main.async {
        //                uploadProgress(awsProgress.fractionCompleted)
        //            }
        //        }
        //        // Completion block
        //        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        //        completionHandler = { (task, error) -> Void in
        //            DispatchQueue.main.async(execute: {
        //                if error == nil {
        //                    let url = AWSS3.default().configuration.endpoint.url
        //                    let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(fileName)
        //                    //print("Uploaded to:\(String(describing: publicURL))")
        //                    if let completionBlock = completion {
        //                        completionBlock(publicURL?.absoluteString, nil)
        //                    }
        //                } else {
        //                    if let completionBlock = completion {
        //                        completionBlock(nil, error)
        //                    }
        //                }
        //            })
        //        }
        //        // Start uploading using AWSS3TransferUtility
        //        let awsTransferUtility = AWSS3TransferUtility.default()
        //        awsTransferUtility.uploadFile(fileUrl, bucket: bucketName, key: fileName, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
        //            if let error = task.error {
        //                //print("error is: \(error.localizedDescription)")
        //            }
        //            if let _ = task.result {
        //                // your uploadTask
        //            }
        //            return nil
        //        }
        let remoteName = fileName
        let S3BucketName = self.bucketName
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileUrl
        uploadRequest.key = remoteName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = contenType
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith(block: { (task: AWSTask) -> Any? in
            DispatchQueue.main.async(execute: {
                if let error = task.error {
                    print("Upload failed with error: (\(error.localizedDescription))")
                    DispatchQueue.main.async {
                        //print("An error occurred while Uploading your file, try again.")
                    }
                }
                if task.result != nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                    if let completionBlock = completion {
                        if let thumNail = thumbNail {
                            if let index = index {
                                completionBlock(publicURL?.absoluteString, thumNail, nil, index)
                            } else {
                                completionBlock(publicURL?.absoluteString, thumNail, nil, nil)
                            }
                        } else {
                            if let index = index {
                                completionBlock(publicURL?.absoluteString, nil, nil, index)
                            } else {
                                completionBlock(publicURL?.absoluteString, nil, nil, nil)
                            }
                            
                        }
                    }
                }
            })
        })
    }
}
