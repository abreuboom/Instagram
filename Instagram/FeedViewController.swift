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
    
    var posts: [PFObject] = []
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var queryLimit = 20
    
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
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: postView.contentSize.height, width: postView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        postView.addSubview(loadingMoreView!)
        
        var insets = postView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        postView.contentInset = insets
        
        
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getData), userInfo: nil, repeats: true)
        postView.reloadData()
        
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
        refreshControl.endRefreshing()
        getData()
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
        query.limit = queryLimit
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground() {(allPosts: [PFObject]?, error: Error?) -> Void in
            if let error = error {
                self.alert()
                print(error.localizedDescription)
            } else {
                self.posts = allPosts!
            }
        }
        postView.reloadData()
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
        
        if let text = post["caption"] as? String {
            if let user = post["author"] as? PFUser {
                let normalText = NSMutableAttributedString(string: " " + text)
                let bold = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14)]
                let username = user.username
                print(username!)
                let totalString = NSMutableAttributedString(string: username!, attributes: bold)
                totalString.append(normalText)
                
                cell.caption.attributedText = normalText
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
        
        if let time = post.createdAt {
            cell.time.text = prettyDate(date: time.description)
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ postView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        headerView.backgroundColor = .white
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
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
