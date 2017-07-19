//
//  CategoriesTableViewController.swift
//  testTask
//
//  Created by Vladimir Burmistrov on 19.07.17.
//  Copyright © 2017 Vladimir Burmistrov. All rights reserved.
//

import UIKit

protocol CategoriesTableViewControllerDelegate {
    func categoryChanged(category: PHCategory)
}

class CategoriesTableViewController: UITableViewController {
    
    var categories = [PHCategory]()
    var passCategory = "tech"
    var delegate : CategoriesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)

        cell.textLabel?.text = categories[indexPath.row].name

        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        delegate?.categoryChanged(category: categories[indexPath.row])
        dismiss(animated: true) {
            
        }
    }

}
