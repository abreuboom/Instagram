//
//  DetailViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/29/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var post: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        profilePhoto.layer.masksToBounds = true
        
        loadData()
        
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        if post != nil {
            if let user = post?["author"] as? PFUser {
                username.text = user.username
                
                if let photo = user.object(forKey: "ProfilePhoto") as? PFFile {
                    photo.getDataInBackground(block: {
                        (imageData: Data?, error: Error?) -> Void in
                        if (error == nil) {
                            let image = UIImage(data:imageData!)
                            self.profilePhoto.image = image
                        }
                    })
                }
                else {
                    self.profilePhoto.image = #imageLiteral(resourceName: "temp-profile")
                }
            }
            if let photo = post?["media"] as? PFFile {
                photo.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        self.photoView.image = image
                    }
                })
            }
            if let likes = post?["likeList"] as? [String] {
                let likeCount = likes.count
                let user = PFUser.current()
                let id = user?.objectId!
                if likeCount == 1 {
                    likeLabel.text = "\(likeCount) like"
                    print(likes)
                    print("TableView function: \(likes.contains(id!))")
                    if likes.contains(id!) == true {
                        likeButton.imageView?.image = #imageLiteral(resourceName: "heart-filled")
                    }
                }
                else if likeCount > 1 {
                    likeLabel.text = "\(likeCount) likes"
                    if likes.contains(id!) == true {
                        likeButton.imageView?.image = #imageLiteral(resourceName: "heart")
                    }
                }
                else {
                    likeLabel.text = "0 likes"
                    likeButton.imageView?.image = #imageLiteral(resourceName: "heart")
                }
                
                
            }
            if let caption = post?["caption"] {
                captionLabel.text = caption as? String
            }
            if let time = post?.createdAt {
                timeLabel.text = prettyDate(date: time.description)
            }
        }
    }
    
    func prettyDate(date: String) -> String{
        let format = DateFormatter()
        let prettyformat = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZ"
        let finalDate = format.date(from: date)
        prettyformat.dateFormat = "HH:mm:ss, MMM dd, yyyy"
        let text = prettyformat.string(from: finalDate!)
        return text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
