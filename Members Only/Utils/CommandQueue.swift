//
//  CommandQueue.swift
//  Members Only
//
//  Created by JeramyMorrill on 2/8/18.
//  Copyright © 2018 JeramyMorrill. All rights reserved.
//

import Foundation

// Command array, executed sequencially
class CommandQueue<Element> {
    var executeHandler: ((_ command: Element) -> Void)?
    
    fileprivate var queueLock = NSLock()
    
    fileprivate var queue = [Element]()
    
    func first() -> Element? {
        queueLock.lock(); defer { queueLock.unlock() }
        return queue.first
    }
    
    func next() {
        guard !queue.isEmpty else { return }
        
        queueLock.lock()
        // Delete finished command and trigger next execution if needed
        queue.removeFirst()
        let nextElement = queue.first
        queueLock.unlock()
        
        if let nextElement = nextElement {
            executeHandler?(nextElement)
        }
    }
    
    func append(_ element: Element) {
        queueLock.lock()
        let shouldExecute = queue.isEmpty
        queue.append(element)
        queueLock.unlock()
        
        if shouldExecute {
            executeHandler?(element)
        }
    }
    
    func removeAll() {
        //DLog("queue removeAll")
        queue.removeAll()
    }
    
}
