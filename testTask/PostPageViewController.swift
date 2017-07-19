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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getAction(_ sender: Any) {
        self.view.layoutIfNeeded()
    }
    
    func setupView() {
        self.titleLabel.text = post?.name
        self.descriptionLabel.text = post?.description
        self.upvotesLabel.text = "▲ \(post!.votesCount)"
        
        URLSession.shared.dataTask(with: post!.screenshotURL!) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.sreenshotImageView.image = image
                self.view.layoutIfNeeded()
            }
            }.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
