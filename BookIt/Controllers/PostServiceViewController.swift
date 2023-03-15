//
//  PostServiceViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-08.
//

import UIKit
import CoreData

class PostServiceViewController: UIViewController {

    var loginUser : LoginUser?
    
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    @IBOutlet weak var nextButtonUploadPhoto: UIButton!
    @IBOutlet weak var nextButtonDetails: UIButton!
    @IBOutlet weak var nextButtonPrice: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var mediaFileCollectionView: UICollectionView!
    @IBOutlet weak var uploadPhotoView: UIView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var confirmView: UIView!
    
    @IBOutlet weak var uploadPhotoImageView: UIImageView!
    @IBOutlet weak var detailsImageView: UIImageView!
    @IBOutlet weak var priceImageView: UIImageView!
    @IBOutlet weak var confirmImageView: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleWordCountLbl: UILabel!
    @IBOutlet weak var deleteImageLbl: UILabel!
    
    @IBOutlet weak var categoryTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var cancelPolicyTextField: UITextField!
    @IBOutlet weak var equipmentCheckboxButton: UIButton!
    @IBOutlet weak var equipmentCheckboxImageView: UIImageView!
    @IBOutlet weak var descriptionWordCountLbl: UILabel!
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceTypeTextField: UITextField!
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var pricetLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    
    var priceTypes:[String] = ["Per-hour","Per-day", "As per service"]
    var isEquipmentNeed = false
    let placeHolder = "Type Here...."
    
    var selectedCategory: Category?
    var categoryList = [Category]()
    var mediaList = [MediaFile]()
    var selectedLocation: Address?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let categoryPicker = UIPickerView()
    let priceTypePicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        self.title = "Post Service"
        
        uiViewsDesign()
        registerNib()
        uploadPhotoView.isHidden = false
        detailsView.isHidden = true
        priceView.isHidden = true
        confirmView.isHidden = true
        
        pageTitleLbl.text = "Upload Photo"
        uploadPhotoImageView.image = #imageLiteral(resourceName: "FilledLine")
        
        descriptionTextView.delegate = self
        descriptionTextView.text = placeHolder
        descriptionTextView.textColor = UIColor.systemGray3
        
        loadCategories()
        
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        categoryPicker.delegate = self
        priceTypePicker.delegate = self
        categoryTypeTextField.inputView = categoryPicker
        priceTypeTextField.inputView = priceTypePicker
        // Do any additional setup after loading the view.
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func uiViewsDesign() {
        nextButtonUploadPhoto.layer.borderColor = UIColor.switchBackgroundColor.cgColor
        nextButtonUploadPhoto.layer.masksToBounds = true
        nextButtonUploadPhoto.layer.borderWidth = 1
        nextButtonUploadPhoto.layer.cornerRadius = 23.0
        
        nextButtonDetails.layer.borderColor = UIColor.switchBackgroundColor.cgColor
        nextButtonDetails.layer.masksToBounds = true
        nextButtonDetails.layer.borderWidth = 1
        nextButtonDetails.layer.cornerRadius = 23.0
        
        nextButtonPrice.layer.borderColor = UIColor.switchBackgroundColor.cgColor
        nextButtonPrice.layer.masksToBounds = true
        nextButtonPrice.layer.borderWidth = 1
        nextButtonPrice.layer.cornerRadius = 23.0
        
        priceTypeTextField.rightViewMode = UITextField.ViewMode.always
        priceTypeTextField.rightView = UIImageView(image:UIImage(named: "DownArrow"))
        
        categoryTypeTextField.rightViewMode = UITextField.ViewMode.always
        categoryTypeTextField.rightView = UIImageView(image:UIImage(named: "DownArrow"))
        
        locationTextField.rightViewMode = UITextField.ViewMode.always
        locationTextField.rightView = UIImageView(image:UIImage(named: "SelectLocationIcon"))
        
    }
    
    private func registerNib() {
        let nib = UINib(nibName: MediaFileCell.nibName, bundle: nil)
        mediaFileCollectionView?.register(nib, forCellWithReuseIdentifier: MediaFileCell.reuseIdentifier)
        if let flowLayout = self.mediaFileCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    @IBAction func nextButtonUploadPhotoAction(_ sender: Any) {
        if titleTextField.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please fill title of service", okActionTitle: "OK", view: self)
            return
        }else if mediaList.count == 0 {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please upload images of service", okActionTitle: "OK", view: self)
            return
        }
        else{
            uploadPhotoView.isHidden = true
            detailsView.isHidden = false
            priceView.isHidden = true
            confirmView.isHidden = true
            
            pageTitleLbl.text = "Details"
            uploadPhotoImageView.image = #imageLiteral(resourceName: "FilledLine")
            detailsImageView.image = #imageLiteral(resourceName: "FilledLine")
        }
    }
    
    @IBAction func nextButtonDetailsAction(_ sender: Any) {
        if categoryTypeTextField.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please select the category type for service", okActionTitle: "OK", view: self)
            return
        }else if locationTextField.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please fill the area of service", okActionTitle: "OK", view: self)
            return
        }else if descriptionTextView.text == placeHolder {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please enter the description for service", okActionTitle: "OK", view: self)
            return
        }else if cancelPolicyTextField.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please cancellation policy for service", okActionTitle: "OK", view: self)
            return
        }
        else{
            uploadPhotoView.isHidden = true
            detailsView.isHidden = true
            priceView.isHidden = false
            confirmView.isHidden = true
            
            pageTitleLbl.text = "Price"
            uploadPhotoImageView.image = #imageLiteral(resourceName: "FilledLine")
            detailsImageView.image = #imageLiteral(resourceName: "FilledLine")
            priceImageView.image = #imageLiteral(resourceName: "FilledLine")
        }
    }
    
    @IBAction func nextButtonPriceAction(_ sender: Any) {
        if priceTextField.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please enter price of service", okActionTitle: "OK", view: self)
            return
        }else if priceTypeTextField.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please enter pricing type of service", okActionTitle: "OK", view: self)
            return
        }
        else{
            uploadPhotoView.isHidden = true
            detailsView.isHidden = true
            priceView.isHidden = true
            confirmView.isHidden = false
            
            pageTitleLbl.text = "Confirmation"
            uploadPhotoImageView.image = #imageLiteral(resourceName: "FilledLine")
            detailsImageView.image = #imageLiteral(resourceName: "FilledLine")
            priceImageView.image = #imageLiteral(resourceName: "FilledLine")
            confirmImageView.image = #imageLiteral(resourceName: "FilledLine")
            
            titleLbl.text = titleTextField.text
            descriptionLbl.text = descriptionTextView.text
            if let price = priceTextField.text, let type = priceTypeTextField.text {
                pricetLbl.text = "$ " + price + " / " + type
            }
            locationLbl.text = locationTextField.text
            let user =  UserDefaultsManager.shared.getUserData()
            if user.firstName != "" {
                nameLbl.isHidden = false
                nameLbl.text = user.firstName + " " + user.lastName
            }else{
                nameLbl.isHidden = true
            }
            
            if let imageData = mediaList[0].image {
                self.serviceImage.image = UIImage(data: imageData)
            }
        }
    }
    
    @IBAction func confirmBttonAction(_ sender: Any) {
        if (UserDefaultsManager.shared.getUserLogin()){
            saveService()
            
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first to post a service. Please go to profile tab for register", okActionTitle: "OK", view: self)
        }
    }
    
    @IBAction func equipmentBttonAction(_ sender: Any) {
        if(isEquipmentNeed){
            equipmentCheckboxImageView.image = #imageLiteral(resourceName: "CheckBox")
            isEquipmentNeed = false
        }else{
            equipmentCheckboxImageView.image = #imageLiteral(resourceName: "CheckBoxFill")
            isEquipmentNeed = true
        }
    }
    
    @IBAction func editLocation() {
        openMapView()
    }
    
    //MARK: - Media Logic
    private func addMediaFile() {
        MediaManager.shared.pickMediaFile(title: "Choose Service Picture",self) { [weak self] mediaObject in
            guard let strongSelf = self else {
                return
            }
            
            if let object = mediaObject {
                let mediaFile = MediaFile(context: strongSelf.context)
                mediaFile.path = object.fileName
                mediaFile.image = object.image?.pngData()
                strongSelf.mediaList.append(mediaFile)
                strongSelf.saveSingleCoreData()
                strongSelf.mediaFileCollectionView.reloadData()
            }
        }
    }
    
    private func deleteMediaFileConfirmation(mediaFile: MediaFile, indexPath: IndexPath) {
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Warning", message: "Are you sure you want to delete this file", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let deleteAction = UIAlertAction(title: "Delete", style: .default){
                UIAlertAction in
                self.mediaList.remove(at: indexPath.row - 1)
                self.deleteMediaFile(mediaFile: mediaFile)
            }
            controller.addAction(deleteAction)
            controller.addAction(cancelAction)
            return controller
        }()
        self.present(alertController, animated: true)
    }
    
    //MARK: - Core data interaction methods

    /// load Category from core data
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryList = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
    }
    
    func saveService(){
        let service = Service(context: context)
        service.parent_Category = selectedCategory
        service.serviceTitle = titleTextField.text
        if placeHolder != descriptionTextView.text {
            service.serviceDescription = descriptionTextView.text
        }
        
        service.cancelPolicy = cancelPolicyTextField.text
        
        selectedLocation?.parentService = service
        

        service.price = priceTextField.text
        service.priceType = priceTypeTextField.text
        service.equipment = isEquipmentNeed
        service.serviceStatus = "new"
        
        for  media in self.mediaList {
            let mediaFile = MediaFile(context: context)
            mediaFile.parent_Service = service
            mediaFile.image = media.image
            mediaFile.path = media.path
        }
        saveAllContextCoreData()
    }
    
    private func deleteMediaFile(mediaFile: MediaFile) {

        context.delete(mediaFile)
        mediaFileCollectionView.reloadData()
    }
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
            clearFieldAndNavigateBack()
            showAlert()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    private func saveSingleCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    private func clearFieldAndNavigateBack(){
        titleTextField.text = ""
        descriptionTextView.text = ""
        mediaList.removeAll()
        mediaFileCollectionView.reloadData()
    }
    
    private func showAlert(){
        
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Success", message: "Successfully Saved..", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default){
                UIAlertAction in
                if let navigator = self.navigationController {
                    navigator.popViewController(animated: true)
                }else{
                    self.dismiss(animated: true)
                }
            }
            controller.addAction(okAction)
            return controller
        }()
        self.present(alertController, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension PostServiceViewController
: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaFileCell.reuseIdentifier,
                                                         for: indexPath) as? MediaFileCell {
            
            let file = indexPath.row == 0 ? nil : mediaList[indexPath.row - 1];
            
            cell.configureCell(file: file,indexPath:indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.row == 0 {
            addMediaFile()
        }else{
            let file = mediaList[indexPath.row - 1]
            deleteMediaFileConfirmation(mediaFile: file, indexPath: indexPath)
        }
    }
}

extension PostServiceViewController : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray3 {
            textView.text = nil
            if self.traitCollection.userInterfaceStyle == .dark {
                textView.textColor = UIColor.white
            } else {
                textView.textColor = UIColor.black
            }
           
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.systemGray3
        }
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        if textView == descriptionTextView {
            let strings : String! = textView.text
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            
            descriptionWordCountLbl.text = String(words.count) + "/500"
            
        }
    }
    
}

extension PostServiceViewController : UITextFieldDelegate{
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == titleTextField {
            let strings : String! = textField.text
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            
            titleWordCountLbl.text = String(words.count) + "/100"
            
        }
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == locationTextField{
//            openMapView()
//        }
//        return true
//     }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == categoryTypeTextField{
//            categoryPicker.isHidden = true
//        }else if textField == priceTypeTextField{
//            priceTypePicker.isHidden = true
//        }
//    }
}

// MARK: UIPickerView Delegation
extension PostServiceViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == priceTypePicker{
            return priceTypes.count
        }else{
            return categoryList.count
        }
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == priceTypePicker{
            return priceTypes[row]
        }else{
            return categoryList[row].name
        }
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == priceTypePicker{
            priceTypeTextField.text = priceTypes[row]
   
        }else if pickerView == categoryPicker{
            if !categoryList.isEmpty{
                categoryTypeTextField.text = categoryList[row].name
            }
        }
        self.view.endEditing(true)
    }
}

// MARK: - MapViewDelegate
extension PostServiceViewController: MapViewDelegate {
    
    private func openMapView() {
        let mapViewController:MapViewController = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        if let navigator = navigationController {
            mapViewController.delegate = self
            mapViewController.selectLocation = true
            navigator.pushViewController(mapViewController, animated: true)
        }
    }
    
    func setServiceLocation(place : PlaceObject){
        selectedLocation = Address(context: context)
        selectedLocation?.latitude = place.coordinate.latitude
        selectedLocation?.longitude = place.coordinate.longitude
        selectedLocation?.address = place.title
        locationTextField.text = place.title
    }
}