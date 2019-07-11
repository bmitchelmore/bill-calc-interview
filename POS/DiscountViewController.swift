//
//  DiscountViewController.swift
//  POS
//
//  Created by Tayson Nguyen on 2019-04-29.
//  Copyright © 2019 TouchBistro. All rights reserved.
//

import Foundation
import UIKit
import POSKit

class DiscountViewController: UITableViewController {
    let cellIdentifier = "Cell"
    
    let viewModel = DiscountViewModel(menu: AppMenu)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Discounts"
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
    }
}

extension DiscountViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = viewModel.labelForDiscount(at: indexPath)
        cell.accessoryType = viewModel.accessoryType(at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toggleDiscount(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

class DiscountViewModel {
    private var menu: Menu
    private var notifier: Notifier!
    
    init(menu: Menu, notificationCenter: NotificationCenter = .default) {
        self.menu = menu
        self.notifier = Notifier(name: Menu.MenuChanged, object: menu, center: notificationCenter) { [weak self] _ in
            self?.modelUpdated()
        }
    }
    
    var modelUpdated: () -> Void = { }
    
    func title(for section: Int) -> String {
        return "Discounts"
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return menu.discounts.count
    }
    
    private func discount(at indexPath: IndexPath) -> Discount {
        return menu.discounts[indexPath.row]
    }
    
    func labelForDiscount(at indexPath: IndexPath) -> String {
        return discount(at: indexPath).label
    }
    
    func accessoryType(at indexPath: IndexPath) -> UITableViewCell.AccessoryType {
        if discount(at: indexPath).isEnabled {
            return .checkmark
        } else {
            return .none
        }
    }
    
    func toggleDiscount(at indexPath: IndexPath) {
        menu.toggleDiscountState(discount(at: indexPath))
    }
}

extension DiscountViewModel {
    static let DiscountStatusChanged = Notification.Name("DiscountStatusChanged")
}
