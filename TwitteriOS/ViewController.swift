//
//  ViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/9/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    var imagePicker: UIImagePickerController!
    var userUID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func upLoadImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            img = resizeImage(image: img, newWidth: 250)!
            userImage.image = img
            
            let storageRef = Storage.storage().reference(forURL: "gs://twitterapp-52392.appspot.com/")
            var data = NSData()
            data = img.pngData() as! NSData
            
            let dataFormat = DateFormatter()
            dataFormat.dateFormat = "MM_DD_yy_h_mm_a"
            
            let imageName = "\(userUID)_\(dataFormat.string(from: NSDate() as Date))"
            let imagePath = "prof_imgs/\(imageName).png"
            let childUserImages = storageRef.child(imagePath)
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            
            // uploading
            childUserImages.putData(data as Data, metadata: metaData)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        let email = self.email.text
        let password = self.password.text
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
                print(error)
            } else {
                self.userUID = user!.user.uid
            }
        }
    }
    
    @IBAction func register(_ sender: Any) {
        let email = self.email.text
        let password = self.password.text
        
        Auth.auth().createUser(withEmail: email!, password: password!){
            // this method returns a user or error
            (user, error) in
            if let error = error {
                print(error)
            } else {
                self.userUID = user!.user.uid
            }
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let newHeight = newWidth
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

