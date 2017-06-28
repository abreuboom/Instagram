//
//  ProfileViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/28/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var postView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var navLabel: UINavigationItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    
    var posts: [PFObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        postView.insertSubview(refreshControl, at: 0)
        
        postView.delegate = self
        postView.dataSource = self
        
        fillUserData()
        
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        // Do any additional setup after loading the view.
    }
    
    func fillUserData() {
        let user = PFUser.current()
        // User found! update username label with username
        navLabel.title = user?.username
        nameLabel.text = user?.object(forKey: "Name") as? String
        aboutLabel.text = user?.object(forKey: "About") as? String
        
        if let photo = user?.object(forKey: "ProfilePhoto")as? PFFile {
            photo.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    self.profilePhotoView.image = image
                }
            })
        }
        print(posts.count)
        postCount.text = String(posts.count)
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        getData()
        refreshControl.endRefreshing()
        postView.reloadData()
    }
    
    func alert() {
        let alertController = UIAlertController(title: "Cannot Get Messages", message: "The internet connection appears to be offline", preferredStyle: .alert)
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        
        present(alertController, animated: true)
    }
    
    func getData () {
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.limit = 20
        query.whereKey("author", equalTo: PFUser.current() as Any)
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground() {(allPosts: [PFObject]?, error: Error?) -> Void in
            if let error = error {
                self.alert()
                print(error.localizedDescription)
            } else {
                self.posts = allPosts!
            }
        }
        self.postView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postView.dequeueReusableCell(withReuseIdentifier: "UserPostCell", for: indexPath) as! UserPostCell
        let post = posts[indexPath.row]
        
        postCount.text = String(posts.count)
        
        if let photo = post["media"] as? PFFile {
            photo.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    cell.photoView.image = image
                }
            })
        }
        
        return cell
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
