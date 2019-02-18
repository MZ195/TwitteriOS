//
//  ViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/9/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase
import TOCropViewController

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    var imagePicker: UIImagePickerController!
    var userUID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func upLoadImage(_ sender: Any) {
        uploadButton.isHidden = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var img = info[UIImagePickerController.InfoKey.originalImage]
        let cropViewController = TOCropViewController(image: img as! UIImage)
        cropViewController.delegate = self
        imagePicker.dismiss(animated: true, completion: nil)
        
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        let compressedImage = resizeImage(image: image, newWidth: 250)!
        userImage.image = compressedImage
        
        // getting the storage reference from firebase
        let storageRef = Storage.storage().reference(forURL: "gs://twitterapp-52392.appspot.com/")
        var data = NSData()
        data = compressedImage.pngData() as! NSData
        
        // to make the name uinique we add the date
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = "MM_DD_yy_h_mm_a"
        
        let imageName = "\(userUID)_\(dataFormat.string(from: NSDate() as Date))"
        let imagePath = "prof_imgs/\(imageName).png"
        let childUserImages = storageRef.child(imagePath)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        // uploading
        childUserImages.putData(data as Data, metadata: metaData)
        
        cropViewController.dismiss(animated: true, completion: nil)
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
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}

