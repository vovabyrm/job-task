//
//  PostsTableViewController.swift
//  testTask
//
//  Created by Vladimir Burmistrov on 18.07.17.
//  Copyright © 2017 Vladimir Burmistrov. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostsTableViewController: UITableViewController {
    
    let cellReuseID = "cellid"
    var postsArray : [PHPost] = []
    var cache = ImageLoadingWithCache()
    var passPost : PHPost?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //self.refreshControl.
        refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        testAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - API
    
    func refresh() {
        testAPI()
        self.refreshControl?.endRefreshing()
    }
    
    func testAPI() { //TODO Create class for API
        let url = URL(string: "https://api.producthunt.com/v1/categories/tech/posts")
        
        //let parameterString = parameters.stringFromHttpParameters()
        //let requestURL = URL(string:"\(url)?\(parameterString)")!
        
        var array : [PHPost] = []
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer 591f99547f569b05ba7d8777e2e0824eea16c440292cce1f8dfb3952cc9937ff",
                         forHTTPHeaderField: "Authorization")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil {
                let json = JSON(data!)
                //print(json["posts"].arrayValue)
                for post in json["posts"].arrayValue {
                    array.append(PHPost(response: post))
                }
            }
            print(error ?? "no error")
            DispatchQueue.main.async {
                //self.inserNewRows()
                self.postsArray = array
                self.tableView.reloadData()
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
        
        // Configure the cell...
        //let string = String(describing: postsArray[indexPath.row].thumbnailURL!)
        
        //TODO add cashing, gif support would be fine too
        URLSession.shared.dataTask(with: cell.post!.thumbnailURL!) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                if self.tableView.cellForRow(at: indexPath) != nil {
                    cell.thumbnailView.image = image
                }
                //self.avatarsCahse[(cell.data?.peerID) ?? "nil"] = image
            }
            }.resume()
        
        //cache.getImage(url: string, imageView: cell.thumbnailView, defaultImage: "blank")
        
        
        return cell
    }
    
    func inserNewRows() {
        var paths : [IndexPath] = []
        for i in 0..<postsArray.count {
            paths.append(IndexPath(row: i, section: 0))
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: paths, with: .none)
        self.tableView.endUpdates()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.passPost = postsArray[indexPath.row]
        performSegue(withIdentifier: "showPost", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! PostPageViewController
        vc.post = self.passPost
    }
    
}

class PHPostCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var upvotesLabel: UILabel!
    
    var post : PHPost? {
        didSet {
            self.titleLabel.text = (post?.name) ?? "nil"
            self.descriptionLabel.text = (post?.description) ?? "nil"
            self.upvotesLabel.text = "▲\(post!.votesCount)"
            
            self.thumbnailView.image = UIImage(named: "blank.png")

        }
    }
}

class ImageLoadingWithCache {
    
    var imageCache = [String:UIImage]()
    
    func getImage(url: String, imageView: UIImageView, defaultImage: String) {
        if let img = imageCache[url] {
            imageView.image = img
        } else {
            let request: URLRequest = URLRequest(url: URL(string: url)!)
            let mainQueue = OperationQueue.main
            
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    self.imageCache[url] = image
                    
                    DispatchQueue.main.async(execute: {
                        imageView.image = image
                    })
                }
                else {
                    imageView.image = UIImage(named: defaultImage)
                }
            })
        }
    }
}
