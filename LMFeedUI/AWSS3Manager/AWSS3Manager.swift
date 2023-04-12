//
//  AWSS3Manager.swift
//  LMFeed
//
//  Created by Pushpendra Singh on 22/02/23.
//

import Foundation
import LMFeed
import AWSS3 //1

typealias ProgressBlock = (_ progress: Double) -> Void //2
typealias CompletionBlock = (_ response: Any?, _ thumbNail: String?, _ error: Error?, _ index: Int?) -> Void //3

@objc class AWSS3Manager: NSObject {

    static let shared = AWSS3Manager() // 4
    let bucketName = ServiceAPI.bucketURL//5 arn:aws:s3:::
    let accessKey = ServiceAPI.accessKey
    let secretKey = ServiceAPI.secretAccessKey
    let awsPoolIdCognito = ServiceAPI.awsPoolIdCognito
//    let nameOfUtitlity = "NAMEOFUTILITY"
    @objc var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    @objc var progressBlock: AWSS3TransferUtilityProgressBlock?
    
    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()
    
    @objc func initializeS3() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APSouth1, identityPoolId: awsPoolIdCognito) //AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.APSouth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
//        AWSS3TransferUtility.register(with: configuration!, forKey: nameOfUtitlity)
    }
    
    // Upload image using UIImage object
    func uploadImage(filePath: String = "", imageData:Data?, index:Int?, progress: ProgressBlock?, completion: CompletionBlock?) {
//        image.jpegData(compressionQuality: 1.0)
        guard let imageData =  imageData else {
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
    func uploadVideo(filePath: String = "", videoUrl: URL, thumbNail: String, progress: ProgressBlock?, completion: CompletionBlock?) {
        var fileName = self.getUniqueFileName(fileUrl: videoUrl)
        fileName = filePath + fileName
        
        self.uploadfile(fileUrl: videoUrl, fileName: fileName, contenType: "video", thumbNail: thumbNail, index: nil, progress: progress, completion: completion)
    }
    
    // Upload auido from local path url
    func uploadAudio(filePath: String = "", audioUrl: URL, progress: ProgressBlock?, completion: CompletionBlock?) {
        let fileName = self.getUniqueFileName(fileUrl: audioUrl)
        self.uploadfile(fileUrl: audioUrl, fileName: fileName, contenType: "audio", thumbNail: nil, index: nil, progress: progress, completion: completion)
    }
    
    // Upload files like Text, Zip, etc from local path url
    func uploadOtherFile(filePath: String = "",fileUrl: URL, conentType: String, progress: ProgressBlock?, completion: CompletionBlock?) {
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
    private func uploadfile(fileUrl: URL, fileName: String, contenType: String, thumbNail:String?, index: Int?, progress: ProgressBlock?, completion: CompletionBlock?) {
        // Upload progress block
        let bucketName = self.bucketName
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            print(progress.fractionCompleted)
            //do any changes once the upload is finished here
            if progress.isFinished{
                print("Upload Finished...")
            }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        completionHandler = { (task:AWSS3TransferUtilityUploadTask, error:NSError?) -> Void in
            if(error != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
            }
        } as? AWSS3TransferUtilityUploadCompletionHandlerBlock
        
        AWSS3TransferUtility.default().uploadFile(fileUrl, bucket: bucketName, key: fileName, contentType: contenType, expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            if task.result != nil {
                print("Starting upload...")
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(bucketName).appendingPathComponent(fileName)
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
            
            return nil
        })
        
        /*    let remoteName = fileName
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
        */
    }
}
