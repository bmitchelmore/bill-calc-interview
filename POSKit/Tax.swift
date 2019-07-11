//
//  Tax.swift
//  POSKit
//
//  Created by Blair Mitchelmore on 2019-07-06.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation

public struct Tax: Equatable {
    public let id: UUID
    public let label: String
    public let amount: Decimal
    public let kind: Kind
    public var isEnabled: Bool
    
    public init(label: String, amount: Decimal, kind: Kind = .universal, isEnabled: Bool = true) {
        self.id = UUID()
        self.label = label
        self.amount = amount
        self.kind = kind
        self.isEnabled =  isEnabled
    }
}

extension Tax {
    public enum Kind: Equatable {
        case universal
        case targeted(Category)
    }
}

extension Collection where Element == Tax {
    func charges(for item: Item) -> Decimal {
        return reduce(0) { $0 + $1.charge(for: item) }
    }
}

extension Tax {
    func charge(for item: Item) -> Decimal {
        guard applies(to: item) else { return 0 }
        return item.price * amount
    }
    func applies(to item: Item) -> Bool {
        guard isEnabled else {
            return false
        }
        guard !item.isTaxExempt else {
            return false
        }
        switch kind {
        case .universal:
            return true
        case .targeted(let category):
            return category == item.category
        }
    }
}
