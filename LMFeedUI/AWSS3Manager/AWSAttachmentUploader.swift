//
//  AWSAttachmentUploader.swift
//  LMFeed
//
//  Created by Pushpendra Singh on 22/02/23.
//

import Foundation
import AVFoundation
import AWSCognito
import AWSS3

enum UploaderType{
    case image
    case video
    case audio
    case file
}


class AWSUploadManager {
    
    static let sharedInstance = AWSUploadManager()
    //"files/post/<user_unique_id>/<filename>-<current_time_inmillis>"
    
    func awsUploader(uploaderType: UploaderType, filePath: String = "", image: UIImage = UIImage(), path: String = "", content: String = "", thumbNailUrl:String? = nil,index: Int?, progress: progressBlock?, completion: completionBlock?) {
        
        if uploaderType == .video {
            awsUploadVideo(filePath: filePath, videoPath: path, thumbNail: thumbNailUrl ?? "", progress: {( uploadProgress) in
                
                guard let progress = progress else { return }
                    progress(uploadProgress)
                
            }) { (uploadedFileUrl, thumbNailUrl, error, index) in
                
                if let finalPath = uploadedFileUrl as? String {
                    guard let completionBlock = completion else { return }
                    completionBlock(finalPath, thumbNailUrl, nil, nil)
                } else {
                    //print("\(String(describing: error?.localizedDescription))")
                }
                
            }
            
        } else if uploaderType == .audio {
            awsUploadAudio(filePath: filePath, audioPath: path, progress: {( uploadProgress) in
                
                guard let progress = progress else { return }
                progress(uploadProgress)
            }) { (uploadedFileUrl, thumbNailUrl, error,index)  in
                
                if let finalPath = uploadedFileUrl as? String {
                    guard let completionBlock = completion else { return }
                    completionBlock(finalPath, nil, nil ,nil)
                } else {
                    //print("\(String(describing: error?.localizedDescription))")
                }
                
            }
            
        }else if uploaderType == .file {
            
            awsUploadFile(filePath: filePath, fileUrlString: path, content: content ,progress: {( uploadProgress) in
                
                guard let progress = progress else { return }
                
                progress(uploadProgress)
                
            }) { (uploadedFileUrl, thumbNailUrl, error,index) in
                
                if let finalPath = uploadedFileUrl as? String {
                    guard let completionBlock = completion else { return }
                    completionBlock(finalPath, nil, nil,nil)
                } else {
                    //print("\(String(describing: error?.localizedDescription))")
                }
                
            }
            
        }else if uploaderType == .image {
            awsUploadImage(filePath: filePath, image: image, index: index, progress: {( uploadProgress) in
                
                guard let progress = progress else { return }
                    progress(uploadProgress)
                
            }) { (uploadedFileUrl,thumbNailUrl, error,index) in
                
                if let finalPath = uploadedFileUrl as? String {
                    guard let completionBlock = completion else { return }
                    completionBlock(finalPath, nil , nil, index)
                } else {
                    //print("\(String(describing: error?.localizedDescription))")
                }
                
            }
        }
        
    }
    
    func fireBaseUploader(uploaderType:UploaderType, progress: progressBlock?, completion: completionBlock?) {
        if uploaderType == .video {
            
        }else if uploaderType == .audio {
            
        }else if uploaderType == .file {
            
        }else if uploaderType == .image {
            
        }
    }
    
    func awsUploadGifImage(filePath: String, fileURL: URL, index: Int?, progress: progressBlock?, completion: completionBlock?) {
        AWSS3Manager.shared.uploadOtherFile(filePath: filePath, fileUrl: fileURL, conentType: "gif", progress: {(progressValue) in
            
            guard let uploadProgress = progress else { return }
            DispatchQueue.main.async {
                uploadProgress(progressValue)
            }
            
        }) { (uploadedFileUrl, thumbNailUrl, error,index ) in
            
            if let finalPath = uploadedFileUrl as? String {
                guard let completionBlock = completion else { return }
                completionBlock(finalPath, nil, nil, index)
            } else {
                //print("\(String(describing: error?.localizedDescription))")
            }
        }
    }
}

extension AWSUploadManager {
    private func awsUploadImage(filePath: String = "", image: UIImage?, index: Int?, progress: progressBlock?, completion: completionBlock?) {
        guard let image = image else { return } //1
        AWSS3Manager.shared.uploadImage(filePath: filePath, image: image, imageData: Data(), index: index, progress: {(progressValue) in
            guard let uploadProgress = progress else { return }
            uploadProgress(progressValue)
            
        }) { (uploadedFileUrl, thumbNailUrl, error,index ) in
            
            if let finalPath = uploadedFileUrl as? String {
                guard let completionBlock = completion else { return }
                completionBlock(finalPath, nil, nil, index)
            } else {
                //print("\(String(describing: error?.localizedDescription))")
            }
            
        }
    }
    
    private func awsUploadVideo(filePath: String = "", videoPath: String, thumbNail: String, progress: progressBlock?, completion: completionBlock?) {
        let videoUrl = URL(fileURLWithPath: videoPath)
        AWSS3Manager.shared.uploadVideo(filePath: filePath, videoUrl: videoUrl, thumbNail: thumbNail, progress: { (progressValue) in
            
            guard let uploadProgress = progress else { return }
            uploadProgress(progressValue)
            
        }) { (uploadedFileUrl, thumbNailUrl, error, index)  in
            
            if let finalPath = uploadedFileUrl as? String {
                guard let completionBlock = completion else { return }
                completionBlock(finalPath, thumbNailUrl, nil,nil)
            } else {
                //print("\(String(describing: error?.localizedDescription))")
            }
            
        }
    }
    
    private func awsUploadAudio(filePath: String = "", audioPath: String, progress: progressBlock?, completion: completionBlock?) {
        let audioUrl = URL(fileURLWithPath: audioPath)
        AWSS3Manager.shared.uploadAudio(filePath: filePath, audioUrl: audioUrl, progress: { (progressValue) in
            
            guard let uploadProgress = progress else { return }
            uploadProgress(progressValue)
            
        }) { (uploadedFileUrl, thumbNailUrl, error, index)  in
            
            if let finalPath = uploadedFileUrl as? String {
                guard let completionBlock = completion else { return }
                completionBlock(finalPath, nil, nil,nil)
            } else {
                //print("\(String(describing: error?.localizedDescription))")
            }
            
        }
        
    }
    
    private func awsUploadFile(filePath: String = "", fileUrlString: String, content: String, progress: progressBlock?, completion: completionBlock?) {
        let fileURL = URL(fileURLWithPath: fileUrlString)
        AWSS3Manager.shared.uploadOtherFile(filePath: filePath, fileUrl: fileURL, conentType: content,  progress: {(progressValue) in
            
            guard let uploadProgress = progress else { return }
            uploadProgress(progressValue)
            
        }) { (uploadedFileUrl, thumbNailUrl, error, index) in
            
            if let finalPath = uploadedFileUrl as? String {
                guard let completionBlock = completion else { return }
                completionBlock(finalPath, nil, nil, nil)
            } else {
                //print("\(String(describing: error?.localizedDescription))")
            }
            
        }
    }
    
    func awsUploadFromFileUrl(filePath: String = "", fileUrlString: String, content: String, progress: progressBlock?, completion: completionBlock?) {
        let fileURL = URL(fileURLWithPath: fileUrlString)
        AWSS3Manager.shared.uploadOtherFile(filePath: filePath, fileUrl: fileURL, conentType: content,  progress: {(progressValue) in
            
            guard let uploadProgress = progress else { return }
            uploadProgress(progressValue)
            
        }) { (uploadedFileUrl, thumbNailUrl, error, index) in
            
            if let finalPath = uploadedFileUrl as? String {
                guard let completionBlock = completion else { return }
                completionBlock(finalPath, nil, nil, nil)
            } else {
                print("\(String(describing: error?.localizedDescription))")
            }
            
        }
    }
}
