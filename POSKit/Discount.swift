//
//  Discount.swift
//  POSKit
//
//  Created by Blair Mitchelmore on 2019-07-06.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

public struct Discount: Equatable {
    public let id: UUID
    public let label: String
    public let amount: Amount
    public var isEnabled: Bool
    
    public init(label: String, amount: Amount, isEnabled: Bool = false) {
        self.id = UUID()
        self.label = label
        self.amount = amount
        self.isEnabled = isEnabled
    }
}

extension Discount {
    public enum Amount: Equatable {
        case percentage(Decimal)
        case absolute(Decimal)
    }
}

extension Discount {
    func amountSaved(for total: Decimal) -> Decimal {
        guard isEnabled else { return 0 }
        switch amount {
        case .percentage(let percentage):
            return total * percentage
        case .absolute(let amount):
            return amount
        }
    }
}

extension Collection where Element == Discount {
    func amountSaved(for total: Decimal) -> Decimal {
        var currentTotal = total
        var saved: Decimal = 0
        for discount in self {
            let savings = discount.amountSaved(for: currentTotal)
            currentTotal -= savings
            saved += savings
        }
        return saved
    }
}
