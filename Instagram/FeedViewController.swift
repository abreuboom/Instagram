//
//  FeedViewController.swift
//  Instagram
//
//  Created by John Abreu on 6/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var postView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var posts: [PFObject] = []
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    let refreshControl = UIRefreshControl()
    
    var queryLimit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let attributes = [NSFontAttributeName : UIFont(name: "Sugarstyle Millenial", size: 30)!, NSForegroundColorAttributeName : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        // Initialize a UIRefreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        postView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: postView.contentSize.height, width: postView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        postView.addSubview(loadingMoreView!)
        
        getData()
        
        
        var insets = postView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        postView.contentInset = insets
        
        postView.delegate = self
        postView.dataSource = self
        
        self.postView.separatorStyle = .none
        
        // Do any additional setup after loading the view.
    }
    
    func loadMoreData() {
        queryLimit += 20
        getData()
        isMoreDataLoading = false
        self.loadingMoreView!.stopAnimating()
        
        postView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = postView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - postView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && postView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: postView.contentSize.height, width: postView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.limit = queryLimit
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground() {(allPosts: [PFObject]?, error: Error?) -> Void in
            if let error = error {
                self.alert()
                print(error.localizedDescription)
            } else {
                self.posts = allPosts!
                self.postView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        postView.reloadData()
    }
    
    func alert() {
        let alertController = UIAlertController(title: "Cannot Get Posts", message: "The internet connection appears to be offline", preferredStyle: .alert)
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        
        present(alertController, animated: true)
    }
    
    func getData() {
        activityIndicator.startAnimating()
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.limit = queryLimit
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground() {(allPosts: [PFObject]?, error: Error?) -> Void in
            if let error = error {
                self.alert()
                print(error.localizedDescription)
            } else {
                self.posts = allPosts!
                self.postView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
        postView.reloadData()
    }
    
    func getDataAfterNewPost() {
        activityIndicator.startAnimating()
        getData()
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
    
    func numberOfSections(in postView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ postView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ postView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.section]
        
        cell.layer.cornerRadius = 25
        cell.layer.masksToBounds = true
        
        if let text = post["caption"] as? String {
            if let user = post["author"] as? PFUser {
                let normalText = NSMutableAttributedString(string: " " + text)
                let bold = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)]
                let username = user.username
                let totalString = NSMutableAttributedString(string: username!, attributes: bold)
                totalString.append(normalText)
                
                cell.caption.attributedText = totalString
            }
            else {
                cell.caption.text = text
            }
        }
        
        if let photo = post["media"] as? PFFile {
            photo.getDataInBackground(block: {
                (imageData: Data?, error: Error?) -> Void in
                if (error == nil) {
                    let image = UIImage(data:imageData!)
                    cell.photoView.image = image
                }
            })
        }
        
        if let likes = post["likeList"] as? [String] {
            let likeCount = likes.count
            let user = PFUser.current()
            let id = user?.objectId!
            if likeCount == 1 {
                cell.likes.text = "\(likeCount) like"
                print(likes)
                print("TableView function: \(likes.contains(id!))")
                if likes.contains(id!) == true {
                    cell.likeButton.imageView?.image = #imageLiteral(resourceName: "heart-filled")
                }
            }
            else if likeCount > 1 {
                cell.likes.text = "\(likeCount) likes"
                if likes.contains(id!) == true {
                    cell.likeButton.imageView?.image = #imageLiteral(resourceName: "heart")
                }
            }
            else {
                cell.likes.text = "0 likes"
                cell.likeButton.imageView?.image = #imageLiteral(resourceName: "heart")
            }
            
            
        }
        
        if let time = post.createdAt {
            cell.time.text = prettyDate(date: time.description)
        }
        
        cell.likeButton.tag = indexPath.section
        
        
        cell.selectionStyle = .none
        
        
        return cell
        
    }
    
    func tableView(_ postView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        headerView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        let proPic = UIImageView(frame: CGRect(x: 8, y: 10, width: 30, height: 30))
        let username = UILabel(frame: CGRect(x: proPic.frame.maxX + 16, y: 0, width: self.view.frame.width - 50, height: headerView.frame.height))
        
        proPic.layer.cornerRadius = proPic.frame.width / 2
        proPic.layer.masksToBounds = true
        
        username.font = UIFont.boldSystemFont(ofSize: 14)
        
        let post = posts[section]
        
        if let user = post["author"] as? PFUser {
            username.text = user.username
            
            if let photo = user.object(forKey: "ProfilePhoto") as? PFFile {
                photo.getDataInBackground(block: {
                    (imageData: Data?, error: Error?) -> Void in
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        proPic.image = image
                    }
                })
            }
            else {
                proPic.image = #imageLiteral(resourceName: "temp-profile")
            }
        }
        
        
        headerView.addSubview(proPic)
        headerView.addSubview(username)
        
        return headerView
    }
    
    func tableView(_ postView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @IBAction func likePost(_ sender: UIButton) {
        let post = posts[sender.tag]
        let query = PFQuery(className:"Post")
        query.getObjectInBackground(withId: post.objectId!) {
            (post: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription)
                print("nope")
            } else {
                
                if let likeList = post?["likeList"] as? [String]{
                    let user = PFUser.current()
                    let id = user?.objectId
                    print("LikePost function: \(likeList.contains(id!))")
                    if likeList.contains(id!) {
                        post?.remove(id!, forKey: "likeList")
                        
                        sender.imageView?.image = #imageLiteral(resourceName: "heart")
                        print("unliked post")
                    }
                    else {
                        post?.addUniqueObject(id!, forKey:"likeList")
                        sender.imageView?.image = #imageLiteral(resourceName: "heart-filled")
                        print("liked post")
                    }
                    post?.setValue(likeList.count, forKeyPath: "likesCount")
                    post?.saveInBackground()
                    self.getData()
                    self.postView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath =  postView.indexPath(for: cell) {
            let post = posts[indexPath.section]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.post = post
        }
    }
    
}
