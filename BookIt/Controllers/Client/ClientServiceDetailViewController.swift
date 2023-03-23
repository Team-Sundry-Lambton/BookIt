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
    

    // create location manager
    var locationMnager = CLLocationManager()
    var openMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addBorder()
        interfaceSegmented.delegate = self
        loadServiceDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.isZoomEnabled = false
        locationMnager.delegate = self
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()
        mapView.delegate = self
        loadMap()
    }
    
    
    func loadServiceDetail(){
        lblTitle.text = selectedService?.serviceTitle
        
        if let price = selectedService?.price, let priceType = selectedService?.priceType {
            lblPrice.setTitle("$ \(price)/ \(priceType)", for: .normal)
        } else {
            lblPrice.setTitle("N/A", for: .normal)
        }
        
        if let user =  selectedService?.parent_Vendor {
            if let firstName = user.firstName, let lastName = user.lastName {
                lblVendorName.text = firstName + " " + lastName
            }else{
                lblVendorName.text = " "
            }
        } else {
            lblVendorName.text = " "
        }
        
        tvDescription.text = selectedService?.serviceDescription
        getVendor()
    
    }
    
    func loadMap(){
        let latitude: CLLocationDegrees = (selectedService?.address!.addressLatitude ?? 43.691221)!
        let longitude: CLLocationDegrees = (selectedService?.address!.addressLongitude ?? -79.3383039)!
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
    
    func addBorder() {
        ivAvatar.layer.borderColor = UIColor.white.cgColor
        ivAvatar.layer.masksToBounds = true
        ivAvatar.contentMode = .scaleToFill
        ivAvatar.layer.borderWidth = 5
        ivAvatar.layer.cornerRadius = ivAvatar.frame.height / 2
    }

}

extension ClientServiceDetailViewController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
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



