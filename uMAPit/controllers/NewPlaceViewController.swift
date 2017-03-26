//
//  NewPlaceViewController.swift
//  uMAPit
//
//  Created by Hassan Abid on 26/03/2017.
//  Copyright © 2017 uMAPit. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import ImagePicker

class NewPlaceViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate {
    
    
    
    @IBOutlet weak var addPhotosButton: UIButton!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var placeNameTextField: UITextField!
    
    var location: Location?

    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var tagTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var mapitButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        configureViews()
    
    }
    
    
    // MARK: - IBActions
    
    @IBAction func didPressMapIt(_ sender: Any) {
        
        
    }
    
    @IBAction func didPressAddPhotos(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 4
        present(imagePickerController, animated: true, completion: nil)

    }
    
    
    // MARK : - Helpers
    
    func configureViews() {
    
        Configuration.doneButtonTitle = "DONE"
        Configuration.noImagesTitle = "Sorry! There are no images here!"
        
        mapitButton.backgroundColor = UIColor(red: 77/255, green: 195/255, blue: 58/255, alpha: 1.0)
        
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderWidth = 1.0;
        descriptionTextView.layer.cornerRadius = 5.0;
        
        placeNameTextField.returnKeyType = .next
        placeNameTextField.clearButtonMode = .never
        
        tagTextField.returnKeyType = .next
        tagTextField.clearButtonMode = .never
        

        descriptionTextView.returnKeyType = .default
        
        placeNameTextField.delegate = self
        tagTextField.delegate = self
        
        descriptionTextView.delegate = self
        
        
    }
    
    
    // MARK: - TextField Delegate 
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        KeyboardAvoiding.avoidingView = nil
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if( textField == placeNameTextField ) {
            
            textField.resignFirstResponder()
            tagTextField.becomeFirstResponder()
        } else if (textField == tagTextField) {
            
            
            textField.resignFirstResponder()
            self.descriptionTextView.becomeFirstResponder()
        } else {
            
            self.descriptionTextView.resignFirstResponder()
        }
        return true
        
    }
    
    
    // MARK- TextView Delegate 
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        KeyboardAvoiding.avoidingView = self.view
        return true
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    // MARK: - ImagePicker Delegate 
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        switch(images.count) {
            case 1 :
                imageView1.image = images[0]
                break
            case 2 :
                imageView1.image = images[0]
                imageView2.image = images[1]
                break
            case 3 :
                imageView1.image = images[0]
                imageView2.image = images[1]
                imageView3.image = images[2]
                break
            case 4 :
                imageView1.image = images[0]
                imageView2.image = images[1]
                imageView3.image = images[2]
                imageView4.image = images[3]
                break
            default: break
        
        }

    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        
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
