//
//  NetworkOperation.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 21/05/23.
//

import Foundation

class NetworkOperation: Operation {
    var isRunning = false
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    override var isConcurrent: Bool {
        get {
            return true
        }
    }
    
    override var isExecuting: Bool {
        get {
            return isRunning
        }
    }
    
    override var isFinished: Bool {
        get {
            return !isRunning
        }
    }
    
    override func start() {
        if self.checkCancel() {
            return
        }
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = true
        self.didChangeValue(forKey: "isExecuting")
        main()
    }
    
    func complete() {
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = false
        self.didChangeValue(forKey: "isFinished")
        self.didChangeValue(forKey: "isExecuting")
    }
    
    // Always resubmit if we get canceled before completion
    func checkCancel() -> Bool {
        if self.isCancelled {
            self.retry()
            self.complete()
        }
        return self.isCancelled
    }
    
    func retry() {
        // Create a new NetworkOp to match and resubmit since we can't reuse existing.
    }
    
    func success() {
        // Success means reset delay
    }
}
