//
//  MediaManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-04.
//

import Foundation
import UIKit

class MediaManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    static let shared = MediaManager()
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Profile Picture", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    
    var pickMediaCallback : ((MediaReturnObject?) -> ())?;
    
    //MARK: Image Selection
    override init(){
        super.init()
        
        var alertStyle = UIAlertController.Style.actionSheet
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }

        alert = UIAlertController(title: "Choose Profile Picture", message: nil, preferredStyle: alertStyle)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }

        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }
    
    func pickMediaFile(title : String ,_ viewController: UIViewController, _ callback: @escaping ((MediaReturnObject?) -> ())) {
        pickMediaCallback = callback;
        self.viewController = viewController;

        alert.title = title
        alert.popoverPresentationController?.sourceView = self.viewController?.view

        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController?.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // For Swift 4.2+
    func imagePickerController1(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
       let imagePath = generateFilePath()
        let object  = MediaReturnObject( image: image, fileName: imagePath)
        pickMediaCallback?(object)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagePath = generateFilePath()
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let object  = MediaReturnObject( image: image, fileName: imagePath)
        pickMediaCallback?(object)
        picker.dismiss(animated: true, completion: nil)
        
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
    func generateFilePath() -> String{
        let id = UUID().uuidString
        return id + ".png"
    }
}

struct MediaReturnObject{
    var image : UIImage?
    var fileName : String
}
