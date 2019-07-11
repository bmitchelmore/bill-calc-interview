//
//  Menu.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation
import POSKit

class Menu {
    var notificationCenter: NotificationCenter = .default

    private(set) var categories: [Category]
    private(set) var taxes: [Tax]
    private(set) var discounts: [Discount]
    
    init(categories: [Category] = [], taxes: [Tax] = [], discounts: [Discount] = []) {
        self.categories = categories
        self.taxes = taxes
        self.discounts = discounts
    }
    
    func toggleDiscountState(_ discount: Discount) {
        guard let index = discounts.firstIndex(of: discount) else {
            return
        }
        discounts[index].isEnabled = !discount.isEnabled
        menuChanged()
    }
    
    func toggleTaxState(_ tax: Tax) {
        guard let index = taxes.firstIndex(of: tax) else {
            return
        }
        taxes[index].isEnabled = !tax.isEnabled
        menuChanged()
    }
    
    func toggleTaxExemptState(_ item: Item) {
        guard let categoryIndex = categories.firstIndex(where: { $0.label == item.category }) else {
            return
        }
        guard let itemIndex = categories[categoryIndex].items.firstIndex(of: item) else {
            return
        }
        categories[categoryIndex].items[itemIndex].isTaxExempt = !item.isTaxExempt
        menuChanged()
    }
    
    private func menuChanged() {
        notificationCenter.post(name: Menu.MenuChanged, object: self)
    }
}

extension Menu {
    static let MenuChanged = Notification.Name("Menu.MenuChanged")
}

extension Menu {
    struct Category {
        let id: Int
        let label: String
        var items: [Item]
        
        init(label: String, items: [Item] = []) {
            self.id = label.hashValue
            self.label = label
            self.items = items
        }
        
        mutating func addItem(with name: String, price: Decimal, isTaxExempt: Bool = false) {
            let item = Item(name: name, category: self.label, price: price, isTaxExempt: isTaxExempt)
            items.append(item)
        }
    }
}

fileprivate func category(_ label: String, update: ((String, Decimal) -> Void) -> Void) -> Menu.Category {
    var category = Menu.Category(label: label)
    update { (name, price) in
        category.addItem(with: name, price: price)
    }
    return category
}

fileprivate func tax(_ label: String, amount: Decimal, category: Menu.Category? = nil, isEnabled: Bool = true) -> Tax {
    if let category = category {
        return Tax(label: label, amount: amount, kind: .targeted(category.label), isEnabled: isEnabled)
    } else {
        return Tax(label: label, amount: amount, kind: .universal, isEnabled: isEnabled)
    }
}

fileprivate func discount(_ label: String, amount: Discount.Amount, isEnabled: Bool = false) -> Discount {
    return Discount(label: label, amount: amount, isEnabled: isEnabled)
}

fileprivate let appetizers = category("Appetizers") { appetizers in
    appetizers("Nachos", 13.99)
    appetizers("Calamari", 11.99)
    appetizers("Caesar Salad", 10.99)
}
fileprivate let mains = category("Mains") { mains in
    mains("Burger", 9.99)
    mains("Hotdog", 3.99)
    mains("Pizza", 12.99)
}
fileprivate let drinks = category("Drinks") { drinks in
    drinks("Water", 0)
    drinks("Pop", 2.00)
    drinks("Orange Juice", 3.00)
}
fileprivate let alcohol = category("Alcohol") { alcohol in
    alcohol("Beer", 5.00)
    alcohol("Cider", 6.00)
    alcohol("Wine", 7.00)
}

fileprivate let tax1 = tax("Tax 1 (5%)", amount: 0.05)
fileprivate let tax2 = tax("Tax 2 (8%)", amount: 0.08)
fileprivate let alcoholTax = tax("Alcohol Tax (10%)", amount: 0.10, category: alcohol)

fileprivate let discount5Dollars = discount("$5.00", amount: .absolute(5))
fileprivate let discount10Percent = discount("10%", amount: .percentage(0.10))
fileprivate let discount20Percent = discount("20%", amount: .percentage(0.20))

fileprivate var taxes = [
    tax1,
    tax2,
    alcoholTax,
]

fileprivate var discounts = [
    discount5Dollars,
    discount10Percent,
    discount20Percent,
]

fileprivate var categories = [
    appetizers,
    mains,
    drinks,
    alcohol
]

let AppMenu = Menu(
    categories: categories,
    taxes: taxes,
    discounts: discounts
)
