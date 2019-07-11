//
//  Bill.swift
//  POSKit
//
//  Created by Blair Mitchelmore on 2019-07-06.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

public typealias Category = String

public struct Bill {
    public var items: [Item]
    public var taxes: [Tax]
    public var discounts: [Discount]
    
    public init(items: [Item] = [], taxes: [Tax] = [], discounts: [Discount] = []) {
        self.items = items
        self.taxes = taxes
        self.discounts = discounts
    }
}

extension Bill {
    public struct Totals: Equatable {
        public let subtotal: Decimal
        public let discounts: Decimal
        public let tax: Decimal
        public let total: Decimal
    }
}

extension Bill {
    public var totals: Totals {
        let subtotal = self.items.reduce(0) { $0 + $1.price }

        let taxesTotal = self.items.reduce(0) { $0 + taxes.charges(for: $1) }
        
        let discountsTotal = self.discounts.amountSaved(for: subtotal + taxesTotal)
        
        let overallTotal = subtotal + taxesTotal - discountsTotal
        
        return Totals(
            subtotal: subtotal,
            discounts: -discountsTotal,
            tax: taxesTotal,
            total: overallTotal
        )
    }
}
