//
//  PostPageViewController.swift
//  testTask
//
//  Created by Vladimir Burmistrov on 19.07.17.
//  Copyright © 2017 Vladimir Burmistrov. All rights reserved.
//

import UIKit

class PostPageViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var sreenshotImageView: UIImageView!
    @IBOutlet var upvotesLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var upvotesView: UIView!
    
    var post : PHPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getAction(_ sender: Any) {
        UIApplication.shared.open(post!.openURL!, options: [:], completionHandler: nil)
    }
    
    func setupView() {
        buttonView.layer.cornerRadius = 5
        upvotesView.layer.cornerRadius = 5
        titleLabel.text = post?.name
        descriptionLabel.text = post?.description
        upvotesLabel.text = "▲ \(post!.votesCount)"
        
        self.sreenshotImageView.image = UIImage(named: "blankScreenshot")
        
        URLSession.shared.dataTask(with: post!.screenshotURL!) { (data, response, error) in
            var image = UIImage()
            
            if error == nil && data != nil {
                image = UIImage(data: data!)!
            } else {
                print(error?.localizedDescription ?? "Error")
            }
            DispatchQueue.main.async() { () -> Void in
                self.sreenshotImageView.image = image
            }
            }.resume()
    }

}
