//
//  Item.swift
//  POSKit
//
//  Created by Blair Mitchelmore on 2019-07-06.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

public struct Item: Equatable {
    public let id: UUID
    public let name: String
    public let category: String
    public let price: Decimal
    public var isTaxExempt: Bool
    
    public init(name: String, category: String, price: Decimal, isTaxExempt: Bool = false) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.price = price
        self.isTaxExempt = isTaxExempt
    }
}
