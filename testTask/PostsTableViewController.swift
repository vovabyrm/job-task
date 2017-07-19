//
//  PostsTableViewController.swift
//  testTask
//
//  Created by Vladimir Burmistrov on 18.07.17.
//  Copyright © 2017 Vladimir Burmistrov. All rights reserved.
//

import UIKit
import SwiftyJSON

private let developerToken = "591f99547f569b05ba7d8777e2e0824eea16c440292cce1f8dfb3952cc9937ff"

class PostsTableViewController: UITableViewController, CategoriesTableViewControllerDelegate {
    
    let cellReuseID = "cellid"
    var postsArray = [PHPost]()
    var imageCache = [URL:UIImage]()
    var passPost : PHPost?
    var categories = [PHCategory]()
    var category = PHCategory(name: "Tech", slug: "tech")
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refresh control setup
        refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        //navBar button setup
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle(category.name, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        button.addTarget(self, action: #selector(self.clickOnButton), for: .touchUpInside)
        self.navigationItem.titleView = button
        
        //activity indicator setup
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        getCatigories()
        getPostForCategory(category.slug)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        imageCache.removeAll()
    }
    
    func refresh() {
        getPostForCategory(category.slug)
    }
    
    func clickOnButton(button: UIButton) {
        if categories.count > 0 {
            performSegue(withIdentifier: "showCatigories", sender: self)
        }
    }
    
    func categoryChanged(category: PHCategory) {
        (self.navigationItem.titleView as! UIButton).setTitle(category.name, for: .normal)
        self.category = category
        activityIndicator.startAnimating()
        self.refresh()
    }
    
    // MARK: - API
    
    func getPostForCategory(_ cat: String) {
        let url = URL(string: "https://api.producthunt.com/v1/categories/\(cat)/posts")
        
        var array : [PHPost] = []
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil {
                let json = JSON(data!)
                //print(json["posts"].arrayValue)
                for post in json["posts"].arrayValue {
                    array.append(PHPost(response: post))
                }
            } else {
                print(error ?? "no data")
            }
            DispatchQueue.main.async {
                self.postsArray = array
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl?.endRefreshing()
            }
        }
        task.resume()
    }
    
    func getCatigories() {
        self.categories.removeAll()
        let url = URL(string: "https://api.producthunt.com/v1/categories")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil {
                let json = JSON(data!)
                //print(json["posts"].arrayValue)
                for post in json["categories"].arrayValue {
                    self.categories.append(PHCategory(response: post))
                }
            } else {
                print(error ?? "no data")
            }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! PHPostCell
        cell.post = postsArray[indexPath.row]
        
        if let img = imageCache[cell.post!.thumbnailURL!] {
            
            cell.thumbnailView.image = img
            
        } else {
            
                URLSession.shared.dataTask(with: cell.post!.thumbnailURL!) { (data, response, error) in
                var image = UIImage()
                
                if error == nil && data != nil {
                    image = UIImage(data: data!)!
                } else {
                    print(error?.localizedDescription ?? "Error")
                }
                
                DispatchQueue.main.async() { () -> Void in
                    if self.tableView.cellForRow(at: indexPath) != nil {
                        self.imageCache[cell.post!.thumbnailURL!] = image
                        //image = UIImage.animatedImage(data: data!)! //gifs really memory unafficiant
                        cell.thumbnailView.image = image
                    }
                }
                }.resume()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.passPost = postsArray[indexPath.row]
        performSegue(withIdentifier: "showPost", sender: self)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCatigories" {
            let vc = segue.destination as! CategoriesTableViewController
            vc.categories = self.categories
            vc.delegate = self
        } else {
            let vc = segue.destination as! PostPageViewController
            vc.post = self.passPost
        }
    }
    
}

    // MARK: - CellClass

class PHPostCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var upvotesLabel: UILabel!
    
    var post : PHPost? {
        didSet {
            self.titleLabel.text = post!.name
            self.descriptionLabel.text = post!.description
            self.upvotesLabel.text = "▲\(post!.votesCount)"
            
            self.thumbnailView.image = UIImage(named: "blank.png")

        }
    }
}

