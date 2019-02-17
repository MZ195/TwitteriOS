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
            let storageRef = Storage.storage().reference(forURL: "gs://twitterapp-52392.appspot.com/")
            var data = NSData()
            //data = UIImage.jpegData(img) as NSData
            
            userImage.image = img
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
                print("Welcome")
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
                print()
            }
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

