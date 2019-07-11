//
//  BillTests.swift
//  POSKitTests
//
//  Created by Blair Mitchelmore on 2019-07-06.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import XCTest
@testable import POSKit

class BillTests: XCTestCase {
    func testEmptyBill() {
        let bill = Bill()
        
        XCTAssertEqual(bill.totals.total, 0)
        XCTAssertEqual(bill.totals.discounts, 0)
        XCTAssertEqual(bill.totals.tax, 0)
        XCTAssertEqual(bill.totals.subtotal, 0)
    }
    
    func testEmptyBillWithTaxes() {
        let tax = Tax(label: "Life Tax", amount: 0.1)
        let bill = Bill(taxes: [tax])
        
        XCTAssertEqual(bill.totals.total, 0)
        XCTAssertEqual(bill.totals.discounts, 0)
        XCTAssertEqual(bill.totals.tax, 0)
        XCTAssertEqual(bill.totals.subtotal, 0)
    }
    
    func testEmptyBillWithDiscounts() {
        let discount = Discount(label: "Life Tax", amount: .absolute(100))
        let bill = Bill(discounts: [discount])
        
        XCTAssertEqual(bill.totals.total, 0)
        XCTAssertEqual(bill.totals.discounts, 0)
        XCTAssertEqual(bill.totals.tax, 0)
        XCTAssertEqual(bill.totals.subtotal, 0)
    }
    
    func testThatItemOrderDoesntMatter() {
        let category = "Body Parts"
        let arm = Item(name: "Left Arm", category: category, price: 4)
        let leg = Item(name: "Right Arm", category: category, price: 7)
        let armAndLeg = Bill(items: [arm, leg])
        let legAndArm = Bill(items: [leg, arm])
        
        XCTAssertEqual(armAndLeg.totals.total, 11)
        XCTAssertEqual(armAndLeg.totals.discounts, 0)
        XCTAssertEqual(armAndLeg.totals.tax, 0)
        XCTAssertEqual(armAndLeg.totals.subtotal, 11)
        XCTAssertEqual(armAndLeg.totals, legAndArm.totals)
    }
    
    func testThatSingleTaxAppliesUniversally() {
        let category = "Body Parts"
        let tax = Tax(label: "Life Tax", amount: 0.1)
        let arm = Item(name: "Left Arm", category: category, price: 40)
        let leg = Item(name: "Right Arm", category: category, price: 70)
        let armAndLeg = Bill(items: [arm, leg], taxes: [tax])
        
        XCTAssertEqual(armAndLeg.totals.subtotal, 110)
        XCTAssertEqual(armAndLeg.totals.discounts, 0)
        XCTAssertEqual(armAndLeg.totals.tax, 11)
        XCTAssertEqual(armAndLeg.totals.total, 121)
    }
    
    func testDisablingTax() {
        let category = "Body Parts"
        let lifeTax = Tax(label: "Life Tax", amount: 0.1)
        let libertyTax = Tax(label: "Liberty Tax", amount: 0.5, isEnabled: false)
        let arm = Item(name: "Left Arm", category: category, price: 40)
        let leg = Item(name: "Right Arm", category: category, price: 70, isTaxExempt: true)
        let armAndLeg = Bill(items: [arm, leg], taxes: [lifeTax, libertyTax])
        
        XCTAssertEqual(armAndLeg.totals.subtotal, 110)
        XCTAssertEqual(armAndLeg.totals.discounts, 0)
        XCTAssertEqual(armAndLeg.totals.tax, 4)
        XCTAssertEqual(armAndLeg.totals.total, 114)
    }
    
    func testDisablingDiscount() {
        let category = "Body Parts"
        let goodDiscount = Discount(label: "$5 Off", amount: .absolute(5), isEnabled: true)
        let greatDiscount = Discount(label: "$20 Off", amount: .absolute(20))
        let arm = Item(name: "Left Arm", category: category, price: 40)
        let leg = Item(name: "Right Arm", category: category, price: 70, isTaxExempt: true)
        let armAndLeg = Bill(items: [arm, leg], discounts: [goodDiscount, greatDiscount])
        
        XCTAssertEqual(armAndLeg.totals.subtotal, 110)
        XCTAssertEqual(armAndLeg.totals.discounts, -5)
        XCTAssertEqual(armAndLeg.totals.tax, 0)
        XCTAssertEqual(armAndLeg.totals.total, 105)
    }
    
    func testTaxExemption() {
        let category = "Body Parts"
        let tax = Tax(label: "Life Tax", amount: 0.1)
        let arm = Item(name: "Left Arm", category: category, price: 40)
        let leg = Item(name: "Right Arm", category: category, price: 70, isTaxExempt: true)
        let armAndLeg = Bill(items: [arm, leg], taxes: [tax])
        
        XCTAssertEqual(armAndLeg.totals.subtotal, 110)
        XCTAssertEqual(armAndLeg.totals.discounts, 0)
        XCTAssertEqual(armAndLeg.totals.tax, 4)
        XCTAssertEqual(armAndLeg.totals.total, 114)
    }
    
    func testTaxCategory() {
        let body = "Body Parts"
        let clothes = "Clothing"
        let bodyTax = Tax(label: "Body Tax", amount: 0.4, kind: .targeted(body))
        let lifeTax = Tax(label: "Life Tax", amount: 0.1)
        let arm = Item(name: "Left Arm", category: body, price: 40)
        let leg = Item(name: "Right Arm", category: body, price: 70, isTaxExempt: true)
        let hat = Item(name: "Hat", category: clothes, price: 20)
        
        let bill = Bill(items: [arm, leg, hat], taxes: [lifeTax, bodyTax])
        
        XCTAssertEqual(bill.totals.subtotal, 130)
        XCTAssertEqual(bill.totals.discounts, 0)
        XCTAssertEqual(bill.totals.tax, 22)
        XCTAssertEqual(bill.totals.total, 152)
    }
    
    func testAbsoluteDiscount() {
        let body = "Body Parts"
        let arm = Item(name: "Left Arm", category: body, price: 40)
        let leg = Item(name: "Right Arm", category: body, price: 70)

        let discount = Discount(label: "$10 Off", amount: .absolute(10), isEnabled: true)
        
        let armAndLeg = Bill(items: [arm, leg], discounts: [discount])
        
        XCTAssertEqual(armAndLeg.totals.subtotal, 110)
        XCTAssertEqual(armAndLeg.totals.discounts, -10)
        XCTAssertEqual(armAndLeg.totals.tax, 0)
        XCTAssertEqual(armAndLeg.totals.total, 100)
    }
    
    func testPercentageDiscount() {
        let body = "Body Parts"
        let arm = Item(name: "Left Arm", category: body, price: 40)
        let leg = Item(name: "Right Arm", category: body, price: 70, isTaxExempt: true)
        
        let discount = Discount(label: "10% Off", amount: .percentage(0.1), isEnabled: true)
        
        let armAndLeg = Bill(items: [arm, leg], discounts: [discount])
        
        XCTAssertEqual(armAndLeg.totals.subtotal, 110)
        XCTAssertEqual(armAndLeg.totals.discounts, -11)
        XCTAssertEqual(armAndLeg.totals.tax, 0)
        XCTAssertEqual(armAndLeg.totals.total, 99)
    }
    
    func testDiscountOrderMatters() {
        let body = "Body Parts"
        let arm = Item(name: "Left Arm", category: body, price: 40)
        let leg = Item(name: "Right Arm", category: body, price: 70, isTaxExempt: true)
        
        let absolute = Discount(label: "$10 Off", amount: .absolute(10), isEnabled: true)
        let percentage = Discount(label: "10% Off", amount: .percentage(0.1), isEnabled: true)
        
        let armAndLegAbPer = Bill(items: [arm, leg], discounts: [absolute, percentage])
        let armAndLegPerAb = Bill(items: [arm, leg], discounts: [percentage, absolute])
        
        XCTAssertEqual(armAndLegAbPer.totals.subtotal, 110)
        XCTAssertEqual(armAndLegAbPer.totals.discounts, -20)
        XCTAssertEqual(armAndLegAbPer.totals.tax, 0)
        XCTAssertEqual(armAndLegAbPer.totals.total, 90)
        
        XCTAssertEqual(armAndLegPerAb.totals.subtotal, 110)
        XCTAssertEqual(armAndLegPerAb.totals.discounts, -21)
        XCTAssertEqual(armAndLegPerAb.totals.tax, 0)
        XCTAssertEqual(armAndLegPerAb.totals.total, 89)
    }
}
