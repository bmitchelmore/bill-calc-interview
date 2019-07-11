//
//  TaxViewModelTests.swift
//  POSTests
//
//  Created by Blair Mitchelmore on 2019-07-10.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import XCTest
import POSKit
@testable import POS

class TaxViewModelTests: XCTestCase {
    private func buildMenu() -> Menu {
        var category = Menu.Category(label: "Test")
        let item1 = Item(name: "Item1", category: category.label, price: 1.5)
        let item2 = Item(name: "Item2", category: category.label, price: 2.5)
        category.items = [item1, item2]
        
        let categories = [category]

        let tax1 = Tax(label: "Tax1", amount: 0.25)
        let tax2 = Tax(label: "Tax2", amount: 0.25, isEnabled: false)
        let taxes = [tax1, tax2]
        
        let discount = Discount(label: "Discount1", amount: .percentage(0.5))
        let discounts = [discount]
        
        return Menu(categories: categories, taxes: taxes, discounts: discounts)
    }
    
    func testViewModelCallsUpdateBlock() {
        let notificationCenter = MockNotificationCenter()
        
        let menu = buildMenu()
        menu.notificationCenter = notificationCenter
        
        notificationCenter.expectAddObserver(name: Menu.MenuChanged)
        notificationCenter.expectPostNotification(name: Menu.MenuChanged)
        
        var modelUpdatedCalled = false
        let viewModel = TaxViewModel(menu: menu, notificationCenter: notificationCenter)
        viewModel.modelUpdated = {
            modelUpdatedCalled = true
        }

        viewModel.toggleTax(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(modelUpdatedCalled)
    }
    
    func testViewModelDoesntBreakWithNoExplicitUpdateBlock() {
        let notificationCenter = MockNotificationCenter()
        
        let menu = buildMenu()
        menu.notificationCenter = notificationCenter
        
        notificationCenter.expectAddObserver(name: Menu.MenuChanged)
        notificationCenter.expectPostNotification(name: Menu.MenuChanged)
        
        let viewModel = TaxViewModel(menu: menu, notificationCenter: notificationCenter)
        
        viewModel.toggleTax(at: IndexPath(row: 0, section: 0))
    }
    
    func testViewModelTitle() {
        let menu = buildMenu()
        let viewModel = TaxViewModel(menu: menu)
        
        XCTAssertEqual(viewModel.title(for: 0), "Taxes")
    }
    
    func testViewModelSectionCount() {
        let menu = buildMenu()
        let viewModel = TaxViewModel(menu: menu)
        
        XCTAssertEqual(viewModel.numberOfSections(), 1)
    }
    
    func testViewModelRowCount() {
        let menu = buildMenu()
        let viewModel = TaxViewModel(menu: menu)
        
        XCTAssertEqual(viewModel.numberOfRows(in: 0), 2)
    }
    
    func testViewModelLabel() {
        let menu = buildMenu()
        let viewModel = TaxViewModel(menu: menu)
        
        XCTAssertEqual(viewModel.labelForTax(at: IndexPath(row: 0, section: 0)), "Tax1")
    }
    
    func testViewModelAccessoryTypeForEnabledTax() {
        let menu = buildMenu()
        let viewModel = TaxViewModel(menu: menu)
        
        XCTAssertEqual(viewModel.accessoryType(at: IndexPath(row: 0, section: 0)), .checkmark)
    }
    
    func testViewModelAccessoryTypeForDisabledTax() {
        let menu = buildMenu()
        let viewModel = TaxViewModel(menu: menu)
        
        XCTAssertEqual(viewModel.accessoryType(at: IndexPath(row: 1, section: 0)), .none)
    }
}
