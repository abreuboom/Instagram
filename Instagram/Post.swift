//
//  Post.swift
//  Instagram
//
//  Created by John Abreu on 6/27/17.
//  Copyright © 2017 John Abreu. All rights reserved.
//

import UIKit
import Parse

class Post: NSObject {
    /**
     * Other methods
     */
    
    /**
     Method to add a user post to Parse (uploading image file)
     
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let post = PFObject(className: "Post")
        
        // Add relevant fields to the object
        post["media"] = getPFFileFromImage(image: image) // PFFile column type
        post["author"] = PFUser.current() // Pointer column type that points to PFUser
        post["caption"] = caption
        post["likesCount"] = 0
        post["commentsCount"] = 0
        post["likeList"] = []
        post["commentList"] = [[]]
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackground { (success, error) in
            if success {
                print("The post was shared!")
            } else if let error = error {
                print("Problem sharing post: \(error.localizedDescription)")
            }
        }
    }
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
}
