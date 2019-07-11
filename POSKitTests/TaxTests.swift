//
//  TaxTests.swift
//  POSKitTests
//
//  Created by Blair Mitchelmore on 2019-07-07.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import XCTest
@testable import POSKit

class TaxTests: XCTestCase {
    let flatTax = Tax(label: "Flat Tax", amount: 0.05)
    let categoryTax = Tax(label: "Food Tax", amount: 0.05, kind: .targeted("Food"))
    let disabledTax = Tax(label: "Legacy Tax", amount: 0.05, isEnabled: false)
    let taxableItem = Item(name: "Fanboat", category: "Boat", price: 140)
    let taxableFoodItem = Item(name: "Burger", category: "Food", price: 5)
    let taxExemptItem = Item(name: "Tylenol", category: "Drug", price: 2, isTaxExempt: true)

    func testUniversalByDefault() {
        let universalByDefault = Tax(label: "Tax", amount: 0.1)
        if case .universal = universalByDefault.kind {
            // Test passed
        } else {
            XCTFail("Default value for kind should be .universal")
        }
    }
    
    func testEnabledByDefault() {
        let enabledByDefault = Tax(label: "Tax", amount: 0.1)
        XCTAssertTrue(enabledByDefault.isEnabled, "Default value for isEnabled should be true")
    }
    
    func testUniveralTaxCalulation() {
        let value = flatTax.charge(for: taxableItem)
        XCTAssertEqual(value, 7)
    }
    
    func testTaxNonMatchingCategoryCalulation() {
        let value = categoryTax.charge(for: taxableItem)
        XCTAssertEqual(value, 0)
    }
    
    func testTaxMatchingCategoryCalulation() {
        let value = categoryTax.charge(for: taxableFoodItem)
        XCTAssertEqual(value, 0.25)
    }
    
    func testTaxExemptCalulation() {
        let value = flatTax.charge(for: taxExemptItem)
        XCTAssertEqual(value, 0)
    }
    
    func testDisabledTaxCalulation() {
        let value = disabledTax.charge(for: taxableItem)
        XCTAssertEqual(value, 0)
    }
    
    func testTaxCollectionCalulation() {
        let taxes = [flatTax, categoryTax]
        let value = taxes.charges(for: taxableFoodItem)
        XCTAssertEqual(value, 0.5)
    }
}
