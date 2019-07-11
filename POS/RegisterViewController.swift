//
//  RegisterViewController.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-23.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import UIKit
import POSKit

class RegisterViewController: UIViewController {
    let cellIdentifier = "Cell"
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountsLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    let viewModel = RegisterViewModel(menu: AppMenu)
    
    var billUpdatedNotifier: Notifier!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.modelUpdated = { [weak self] () in
            self?.updateTotals()
        }
        
        menuTableView.dataSource = self
        orderTableView.dataSource = self
        menuTableView.delegate = self
        orderTableView.delegate = self
    }
    
    func updateTotals() {
        subtotalLabel.text = viewModel.subtotalString()
        taxLabel.text = viewModel.taxString()
        discountsLabel.text = viewModel.discountsString()
        totalLabel.text = viewModel.totalString()
    }
    
    @IBAction func showTaxes() {
        let vc = UINavigationController(rootViewController: TaxViewController(style: .grouped))
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func showDiscounts() {
        let vc = UINavigationController(rootViewController: DiscountViewController(style: .grouped))
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == menuTableView {
            return viewModel.menuCategoryTitle(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.orderTitle(in: section)
        }
        
        fatalError()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuCategories()
        } else if tableView == orderTableView {
            return 1
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return viewModel.numberOfMenuItems(in: section)
            
        } else if tableView == orderTableView {
            return viewModel.numberOfOrderItems(in: section)
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if tableView == menuTableView {
            cell.textLabel?.text = viewModel.menuItemName(at: indexPath)
            cell.detailTextLabel?.text = viewModel.menuItemPrice(at: indexPath)
            
        } else if tableView == orderTableView {
            cell.textLabel?.text = viewModel.labelForOrderItem(at: indexPath)
            cell.detailTextLabel?.text = viewModel.orderItemPrice(at: indexPath)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            let indexPaths = [viewModel.addItemToOrder(at: indexPath)]
            orderTableView.insertRows(at: indexPaths, with: .automatic)
            updateTotals()

        } else if tableView == orderTableView {
            viewModel.toggleTaxForOrderItem(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateTotals()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == menuTableView {
            return .none
        } else if tableView == orderTableView {
            return .delete
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == orderTableView && editingStyle == .delete {
            viewModel.removeItemFromOrder(at: indexPath)
            orderTableView.deleteRows(at: [indexPath], with: .automatic)
            updateTotals()
        }
    }
}

class RegisterViewModel {
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private var menu: Menu
    private var notifier: Notifier!
    
    init(menu: Menu, notificationCenter: NotificationCenter = .default) {
        self.menu = menu
        self.notifier = Notifier(name: Menu.MenuChanged, object: menu, center: notificationCenter) { [weak self] _ in
            self?.modelUpdated()
        }
    }
    
    var orderItems: [Item] = []
    
    var bill: Bill {
        return Bill(items: orderItems, taxes: menu.taxes, discounts: menu.discounts)
    }
    
    var modelUpdated: () -> Void = { }
    
    func subtotalString() -> String? {
        return formatter.string(from: NSDecimalNumber(decimal: bill.totals.subtotal))
    }
    
    func taxString() -> String? {
        return formatter.string(from: NSDecimalNumber(decimal: bill.totals.tax))
    }
    
    func discountsString() -> String? {
        return formatter.string(from: NSDecimalNumber(decimal: bill.totals.discounts))
    }
    
    func totalString() -> String? {
        return formatter.string(from: NSDecimalNumber(decimal: bill.totals.total))
    }
    
    private func category(in section: Int) -> Menu.Category {
        return menu.categories[section]
    }
    
    func menuCategoryTitle(in section: Int) -> String? {
        return category(in: section).label
    }
    
    func orderTitle(in section: Int) -> String? {
        return "Bill"
    }
    
    func numberOfMenuCategories() -> Int {
        return menu.categories.count
    }
    
    func numberOfMenuItems(in section: Int) -> Int {
        return menu.categories[section].items.count
    }
    
    func numberOfOrderItems(in section: Int) -> Int {
        return orderItems.count
    }
    
    func menuItemName(at indexPath: IndexPath) -> String? {
        return menu.categories[indexPath.section].items[indexPath.row].name
    }
    
    func menuItemPrice(at indexPath: IndexPath) -> String? {
        let price = menu.categories[indexPath.section].items[indexPath.row].price
        return formatter.string(from: NSDecimalNumber(decimal: price))
    }
    
    func labelForOrderItem(at indexPath: IndexPath) -> String? {
        let item = orderItems[indexPath.row]
       
        if item.isTaxExempt {
            return "\(item.name) (No Tax)"
        } else {
            return item.name
        }
    }
    
    func orderItemPrice(at indexPath: IndexPath) -> String? {
        let price = orderItems[indexPath.row].price
        return formatter.string(from: NSDecimalNumber(decimal: price))
    }
    
    func addItemToOrder(at indexPath: IndexPath) -> IndexPath {
        let item = menu.categories[indexPath.section].items[indexPath.row]
        orderItems.append(item)
        return IndexPath(row: orderItems.count - 1, section: 0)
    }
    
    func removeItemFromOrder(at indexPath: IndexPath) {
        orderItems.remove(at: indexPath.row)
    }
    
    func toggleTaxForOrderItem(at indexPath: IndexPath) {
        orderItems[indexPath.row].isTaxExempt = !orderItems[indexPath.row].isTaxExempt
    }
}

