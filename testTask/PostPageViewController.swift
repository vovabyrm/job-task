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
    @IBOutlet var getButton: UIButton!
    
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
        self.titleLabel.text = post?.name
        self.descriptionLabel.text = post?.description
        self.upvotesLabel.text = "▲ \(post!.votesCount)"
        
        //TODO Add blank image
        
        URLSession.shared.dataTask(with: post!.screenshotURL!) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.sreenshotImageView.image = image
            }
            }.resume()
    }

}
