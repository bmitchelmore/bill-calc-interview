//
//  Notifier.swift
//  POS
//
//  Created by Blair Mitchelmore on 2019-07-08.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

class Notifier {
    private let observer: NSObjectProtocol
    private let center: NotificationCenter
    
    deinit {
        center.removeObserver(observer)
    }
    
    init(name: Notification.Name, object: Any? = nil, queue: OperationQueue = .main, center: NotificationCenter = .default, block: @escaping (Notification) -> Void) {
        let observer = center.addObserver(forName: name, object: object, queue: queue, using: block)
        self.center = center
        self.observer = observer
    }
}
