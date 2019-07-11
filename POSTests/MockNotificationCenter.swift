//
//  MockNotificationCenter.swift
//  POSTests
//
//  Created by Blair Mitchelmore on 2019-07-10.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation
import XCTest

class MockNotificationCenter: NotificationCenter {
    var addObserverCalls: [Notification.Name] = []
    var postNotificationCalls: [Notification.Name] = []
    var verified: Bool = true
    
    func expectAddObserver(name: Notification.Name) {
        addObserverCalls.append(name)
        verified = false
    }
    
    func expectPostNotification(name: Notification.Name) {
        postNotificationCalls.append(name)
        verified = false
    }
    
    func verify() {
        XCTAssertEqual(addObserverCalls.count, 0)
        XCTAssertEqual(postNotificationCalls.count, 0)
    }
    
    deinit {
        if !verified {
            verify()
        }
    }
    
    override func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        if let expectedName = addObserverCalls.first {
            addObserverCalls.removeFirst()
            XCTAssertEqual(name, expectedName)
        } else {
            XCTFail("Unexpected add observer")
        }
        return super.addObserver(forName: name, object: obj, queue: queue, using: block)
    }
    
    override func post(name aName: NSNotification.Name, object anObject: Any?) {
        if let expectedName = postNotificationCalls.first {
            postNotificationCalls.removeFirst()
            XCTAssertEqual(aName, expectedName)
        } else {
            XCTFail("Unexpected post notification")
        }
        super.post(name: aName, object: anObject)
    }
}
