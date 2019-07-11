//
//  DiscountTests.swift
//  POSKitTests
//
//  Created by Blair Mitchelmore on 2019-07-07.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import XCTest
@testable import POSKit

class DiscountTests: XCTestCase {
    let absoluteDiscount = Discount(label: "$5 Off", amount: .absolute(5), isEnabled: true)
    let percentageDiscount = Discount(label: "5% Off", amount: .percentage(0.05), isEnabled: true)
    let disabledDiscount = Discount(label: "$5 Off", amount: .absolute(10))
    let total: Decimal = 50

    func testDisabledByDefault() {
        XCTAssertFalse(disabledDiscount.isEnabled, "Default value for isEnabled should be false")
    }
    
    func testAbsoluteDiscount() {
        let total: Decimal = 50
        let savings = absoluteDiscount.amountSaved(for: total)
        XCTAssertEqual(savings, 5)
    }
    
    func testPercentageDiscount() {
        let total: Decimal = 50
        let savings = percentageDiscount.amountSaved(for: total)
        XCTAssertEqual(savings, 2.5)
    }
    
    func testDisabledDiscount() {
        let total: Decimal = 50
        let savings = disabledDiscount.amountSaved(for: total)
        XCTAssertEqual(savings, 0)
    }
    
    func testDiscountCollectionFirstOrder() {
        let total: Decimal = 50
        let savings = [absoluteDiscount, percentageDiscount].amountSaved(for: total)
        XCTAssertEqual(savings, 7.25)
    }
    
    func testDiscountCollectionSecondOrder() {
        let total: Decimal = 50
        let savings = [percentageDiscount, absoluteDiscount].amountSaved(for: total)
        XCTAssertEqual(savings, 7.5)
    }
}
