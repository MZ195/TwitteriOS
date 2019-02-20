//
//  ProfileImageViewController.swift
//  TwitteriOS
//
//  Created by Mazen.A on 2/18/19.
//  Copyright © 2019 Mazen.A. All rights reserved.
//

import UIKit
import Firebase
import TOCropViewController

class ProfileImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    var imagePicker: UIImagePickerController!
    var databaseRef = DatabaseReference.init()
    var imagePath:String?
    
    // comming parameters
    var userUID:String?
    var username:String?
    var userEmail:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.databaseRef = Database.database().reference()
    }
    
    @IBAction func upLoadImage(_ sender: Any) {
        uploadButton.setTitle("", for: .normal)
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
        
        let imageName = "\(userUID!)_\(dataFormat.string(from: NSDate() as Date))"
        imagePath = "prof_imgs/\(imageName).png"
        let childUserImages = storageRef.child(imagePath!)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        // uploading
        childUserImages.putData(data as Data, metadata: metaData)
        
        saveUserData(imgPath: imagePath!, username: username!, email: userEmail!)
        cropViewController.dismiss(animated: true) {
            self.performSegue(withIdentifier: "fromProfileToTimeline", sender: self.userUID)
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
    
    func saveUserData(imgPath:String, username:String, email:String){
        let data = [ "UserFullName": username,
                     "Email": email,
                     "UserImagePath": imgPath]
        self.databaseRef.child("Users").child(self.userUID!).setValue(data)
        self.databaseRef.child("Timeline").child(self.userUID!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TimelineViewController
        {
            let vc = segue.destination as? TimelineViewController
            vc!.userUID = self.userUID
        }
    }
}
