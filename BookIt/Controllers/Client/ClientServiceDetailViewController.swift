//
//  ClientServiceDetailViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-22.
//

import UIKit
import SnapKit
import CoreLocation
import CoreData
import MapKit
import JGProgressHUD

class ClientServiceDetailViewController: UIViewController, CLLocationManagerDelegate{
  
    weak var delegate: ClientServiceDetailViewController!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedService: Service?
    @IBOutlet weak var interfaceSegmented: CustomSegmentedControl!{
        didSet{
            interfaceSegmented.setButtonTitles(buttonTitles: ["Descriptions","Reviews", "Location"])
            interfaceSegmented.selectorViewColor = #colorLiteral(red: 0.2415007949, green: 0.3881379962, blue: 0.6172356606, alpha: 1)
            interfaceSegmented.selectorTextColor = #colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1)
            interfaceSegmented.textColor = #colorLiteral(red: 0.6947146058, green: 0.7548407912, blue: 0.8478365541, alpha: 1)
            interfaceSegmented.baseLineColor = #colorLiteral(red: 0.9490194917, green: 0.9490197301, blue: 0.9533253312, alpha: 1)
        }
    }
    @IBOutlet weak var bannerTableView: UITableView!
    @IBOutlet weak var lblVendorName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UIButton!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewReviews: UIView!
    @IBOutlet weak var tvReviews: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblVendorRating: UILabel!
    @IBOutlet weak var lblServiceRating: UILabel!
    @IBOutlet weak var bookNowBtn: UIButton!
    @IBOutlet weak var viewVendorDetails: UIView!
    @IBOutlet weak var vendorDetailHeightConstrain: NSLayoutConstraint!
    let fullSizeWidth = UIScreen.main.bounds.width
    var bannerViews: [UIImageView] = []
    var timer = Timer()
    var xOffset: CGFloat = 0
    var currentPage = 0 {
        didSet{
            xOffset = fullSizeWidth * CGFloat(self.currentPage)
            bannerTableView.reloadData()
        }
    }

    // create location manager
    var locationMnager = CLLocationManager()
    var openMap = false
    var vendorReviewList = [VendorReview]()
    var vendor : Vendor?
    var isVendor = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setTimer()
        addBorder()
        interfaceSegmented.delegate = self
        loadServiceDetail()
        
        if isVendor {
            bookNowBtn.setTitle("Edit", for: .normal)
            viewVendorDetails.isHidden = true
            vendorDetailHeightConstrain.constant = 0
        }else{
            bookNowBtn.setTitle("Book Now", for: .normal)
            viewVendorDetails.isHidden = false
            vendorDetailHeightConstrain.constant = 85
        }
        
        tvReviews.delegate = self
        tvReviews.dataSource = self
        tvReviews.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        
        bannerTableView.register(BannerTableViewCell.self, forCellReuseIdentifier: BannerTableViewCell.identifier)
        bannerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        bannerTableView.delegate = self
        bannerTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        mapView.isZoomEnabled = false
        locationMnager.delegate = self
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()
        mapView.delegate = self
        loadMap()
        tvReviews.reloadData()
    }
    
    
    func loadServiceDetail(){
        if let title = selectedService?.serviceTitle {
            lblTitle.text = title
        } else {
            lblTitle.text = "N/A"
        }
        
        if let price = selectedService?.price, let priceType = selectedService?.priceType {
            lblPrice.setTitle("$ \(price)/ \(priceType)", for: .normal)
        } else {
            lblPrice.setTitle("N/A", for: .normal)
        }
        
        if let user =  selectedService?.parent_Vendor {
            if let firstName = user.firstName, let lastName = user.lastName {
                lblVendorName.text = firstName + " " + lastName
            }else{
                lblVendorName.text = "N/A"
            }
        } else {
            lblVendorName.text = "N/A"
        }
        
        tvDescription.text = selectedService?.serviceDescription
        getVendor()
        vendorReviewList = CoreDataManager.shared.getVendorReviewList(email: vendor?.email ?? "")
        dipalyServiceReview()
        dipalyVendorReview()
    }
    
    func loadMap(){
        let latitude: CLLocationDegrees = selectedService?.address?.addressLatitude ?? 43.691221
        let longitude: CLLocationDegrees = selectedService?.address?.addressLongitude ?? -79.3383039
        displayLocation(latitude: latitude, longitude: longitude, title: selectedService?.serviceTitle ?? "N/A", subtitle: selectedService?.address?.address ?? "Not found address")
    }
    
    func dipalyServiceReview(){
        let serviceReviewList = CoreDataManager.shared.getServiceReviewList(serviceId: Int(selectedService?.serviceId ?? -1))
        var reviewTotal = 0
        var rate = 0
        for review in serviceReviewList {
            reviewTotal += Int(review.rating)
        }
        if serviceReviewList.count > 0 {
            rate = reviewTotal / serviceReviewList.count
        }
        lblServiceRating.text =  String(rate) + " ( " + String(serviceReviewList.count) + " reviews )"
    }
    
    func dipalyVendorReview(){
        var reviewTotal = 0
        var rate = 0
        for review in vendorReviewList {
            reviewTotal += Int(review.rating)
        }
        if vendorReviewList.count > 0 {
            rate = reviewTotal / vendorReviewList.count
        }
        lblVendorRating.text = String(rate)
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        mapView.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    func getVendor(){
        if let user =  selectedService?.parent_Vendor {
            if let email = user.email {
                vendor = CoreDataManager.shared.getVendor(email: email)
            }
        }
    }
    
    func addBorder() {
        ivAvatar.layer.borderColor = UIColor.white.cgColor
        ivAvatar.layer.masksToBounds = true
        ivAvatar.contentMode = .scaleToFill
        ivAvatar.layer.borderWidth = 5
        ivAvatar.layer.cornerRadius = ivAvatar.frame.height / 2
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(swipeLeft), userInfo: nil, repeats: true)
    }

    @objc func swipeLeft() {
        self.currentPage += 1
        if self.currentPage > bannerViews.count - 1 {
            self.currentPage = 0
        }
    }

    func swipeRight() {
        self.currentPage -= 1
        if currentPage < 0 {
            currentPage = bannerViews.count - 1
        }
    }

    @objc func pageControlDidTap() {
        timer.invalidate()
        swipeLeft()
    }
    
    @IBAction func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bookButtonPressed() {
        if (UserDefaultsManager.shared.getUserLogin()){
            if isVendor {
                if let viewController = UIStoryboard(name: "PostService", bundle: nil).instantiateViewController(withIdentifier: "PostServiceViewController") as? PostServiceViewController {
                    if let navigator = navigationController {
                        viewController.selectedService = selectedService
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }else{
                //Redirect to service booking page
            }
            
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first to book a service. Please go to profile tab for register", okActionTitle: "OK", view: self)
        }
    }
    
/*    func saveBooking(){
       var booking = Booking(context: context)
        booking.date = Date()
        booking.status = "New"
        booking.service = selectedService
        getVendor()
        booking.vendor = vendor
        let user =  UserDefaultsManager.shared.getUserData()
        booking.client = CoreDataManager.shared.getClient(email: user.email)
            let hud = JGProgressHUD()
            hud.textLabel.text = "Booking..."
            hud.show(in: self.view)
            Task {
                await InitialDataDownloadManager.shared.addBookingData(booking:booking){ status in
                    DispatchQueue.main.async {
                        hud.dismiss(animated: true)
                        if let status = status {
                            if status {
                                self.saveAllContextCoreData()
                            }else{
                                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
                            }
                        }
                    }
                }
                
            }
    }
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
            showAlert()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    private func showAlert(){
    
        var message = "Successfully Booked.."
    
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
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
*/
}

extension ClientServiceDetailViewController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        tvReviews.reloadData()
         switch (index)  {
          case 1:
            viewDescription.isHidden = true
            viewReviews.isHidden = false
            viewLocation.isHidden = true
          case 2:
            viewDescription.isHidden = true
            viewReviews.isHidden = true
            viewLocation.isHidden = false
            openMap = true
          default:
            viewDescription.isHidden = false
            viewReviews.isHidden = true
            viewLocation.isHidden = true
        }
        
    }
}


// MARK: - MapViewDelegate

extension ClientServiceDetailViewController: MKMapViewDelegate {
        
        //MARK: - viewFor annotation method
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation {
                return nil
            }
            
            switch annotation.title {
            case "my location":
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "ic_place_2x")
                annotationView.markerTintColor = UIColor.blue
                return annotationView
            default:
                return nil
            }
        }
        
    }



extension ClientServiceDetailViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == bannerTableView {
            return 1
        }else{
            return vendorReviewList.count
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bannerTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BannerTableViewCell.identifier, for: indexPath) as? BannerTableViewCell else { return UITableViewCell() }
            cell.configureCell(serviceId: Int(selectedService?.serviceId ?? -1))
            self.bannerViews = cell.bannerViews
            
            cell.myScrollView.delegate = self
            cell.pageControl.currentPage = self.currentPage
            cell.pageControl.addTarget(self, action: #selector(pageControlDidTap), for: .touchUpInside)
            UIView.animate(withDuration: 1) {
                cell.myScrollView.contentOffset.x = self.xOffset
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as? ReviewTableViewCell
            let vendorReview = vendorReviewList[indexPath.row]
            cell?.configureCell(vendorReview: vendorReview)
            return cell ?? UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == bannerTableView {
            return 240
        }else{
            return 125
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //go to review detail page.
        print("selected" + "\(indexPath.row)")
    }
}

extension ClientServiceDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer.invalidate()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setTimer()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if scrollView == bannerTableView{
            //do nothing
        }else{
            let translatedPoint = scrollView.panGestureRecognizer.translation(in:scrollView)
            print(translatedPoint.x)
            if translatedPoint.x < 0 {
                swipeLeft()
            }else{
                swipeRight()
            }
            print(currentPage)
        }
    }
}
