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
    
    var imageList = [MediaObject]()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addBorder()
        interfaceSegmented.delegate = self
        loadServiceDetail()
        
        tvReviews.delegate = self
        tvReviews.dataSource = self
        tvReviews.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        
        bannerTableView.register(BannerTableViewCell.self, forCellReuseIdentifier: BannerTableViewCell.identifier)
        bannerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        bannerTableView.delegate = self
        bannerTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
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
        getMedias()
    
    }
    
    func loadMap(){
        let latitude: CLLocationDegrees = selectedService?.address?.addressLatitude ?? 43.691221
        let longitude: CLLocationDegrees = selectedService?.address?.addressLongitude ?? -79.3383039
        displayLocation(latitude: latitude, longitude: longitude, title: selectedService?.serviceTitle ?? "N/A", subtitle: selectedService?.address?.address ?? "Not found address")
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Vendor")
        if let user =  selectedService?.parent_Vendor {
            if let email = user.email {
                fetchRequest.predicate = NSPredicate(format: "email = %@", email)
                do {
                    let users = try context.fetch(fetchRequest)
                    if let user = users.first as? Vendor{
                        if let imageData = user.picture {
                            self.ivAvatar.image = UIImage(data: imageData)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
    func getMedias(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "MediaFile")
        if let title =  selectedService?.serviceTitle {
            fetchRequest.predicate = NSPredicate(format: "parent_Service = %@", title)
            do {
                
            } catch {
                print(error)
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
            return 10
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bannerTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BannerTableViewCell.identifier, for: indexPath) as? BannerTableViewCell else { return UITableViewCell() }
            
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
