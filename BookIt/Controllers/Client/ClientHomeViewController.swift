//
//  ClientHomeViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit
import SnapKit
import CoreLocation

class ClientHomeViewController: BaseViewController {
    
    @IBOutlet weak var bannerTableView: UITableView!
    @IBOutlet weak var searchService: UISearchBar!
    @IBOutlet weak var categoryCollectioView: UICollectionView!
    @IBOutlet weak var newVendersCollectionView: UICollectionView!
    @IBOutlet weak var serviceListTableView: UITableView!
    @IBOutlet weak var addressLbl: UILabel!    
    @IBOutlet weak var serviceListHeightConstrain: NSLayoutConstraint!
    let fullSizeWidth = UIScreen.main.bounds.width
    var bannerViews: [UIImageView] = []
    var mySections: [TableSections] = [.banner, .others]
    var timer = Timer()
    var xOffset: CGFloat = 0
    var currentPage = 0 {
        didSet{
            xOffset = fullSizeWidth * CGFloat(self.currentPage)
            bannerTableView.reloadData()
        }
    }
    
    private var locationManager:CLLocationManager?
    var categoryList = [Category]()
    var vendorList = [Vendor]()
    var serviceList = [Service]()
    var currentAddress : PlaceObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setTimer()
        tabBarAppearance()
        getUserLocation()
        loadData()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bannerTableView.reloadData()
    }
    
    func tabBarAppearance(){
//        navigationController?.navigationBar.tintColor = UIColor.black
//        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
//            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
//            navigationController?.navigationBar.titleTextAttributes = textAttributes
//        }
//        self.title = "Home"
//        if (UserDefaultsManager.shared.getUserLogin()){
//            self.tabBarController?.navigationItem.hidesBackButton = true
//        }
//        let standardAppearance = UINavigationBarAppearance()
//
//        // Title font color
//        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//
//        // prevent Nav Bar color change on scroll view push behind NavBar
//        standardAppearance.configureWithOpaqueBackground()
//        standardAppearance.backgroundColor = UIColor.white
//
//        self.navigationController?.navigationBar.standardAppearance = standardAppearance
//        self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        let tabbarAppearance = UITabBarAppearance()
        tabbarAppearance.configureWithOpaqueBackground()
        tabbarAppearance.backgroundColor = UIColor.white
       
        self.tabBarController?.tabBar.scrollEdgeAppearance = tabbarAppearance
        self.tabBarController?.tabBar.standardAppearance = tabbarAppearance
    }
    
    func initUI(){
    
        categoryCollectioView.dataSource = self
        categoryCollectioView.delegate = self
        categoryCollectioView.register(UINib(nibName: "CategoryListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryListCollectionViewCell")

        newVendersCollectionView.dataSource = self
        newVendersCollectionView.delegate = self
        newVendersCollectionView.register(UINib(nibName: "NewVendorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewVendorCollectionViewCell")
        
        serviceListTableView.delegate = self
        serviceListTableView.dataSource = self
        serviceListTableView.register(UINib(nibName: "ServiceDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceDetailTableViewCell")

        bannerTableView.register(BannerTableViewCell.self, forCellReuseIdentifier: BannerTableViewCell.identifier)
        bannerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        bannerTableView.delegate = self
        bannerTableView.dataSource = self
        setLayouts()
    }
    
    func loadData(){
        categoryList = CoreDataManager.shared.loadCategories()
        categoryCollectioView.reloadData()
        
        vendorList =  CoreDataManager.shared.loadNewVendors()
        newVendersCollectionView.reloadData()
        
        serviceList = CoreDataManager.shared.loadServices()
        serviceListHeightConstrain.constant = CGFloat((serviceList.count) * 125)
        serviceListTableView.reloadData()
    }
    
    @IBAction func allCategoryList() {
        self.tabBarController?.selectedIndex = 1;
    }
 
    @IBAction func locationChanged() {
        presentModal()
    }
    
    private func presentModal() {
        
        if let viewController = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "ConfirmLocationViewController") as? ConfirmLocationViewController {
                viewController.modalPresentationStyle = .pageSheet
                viewController.currentAddress = currentAddress
                viewController.delegate = self
                if let sheet = viewController.sheetPresentationController {
                    sheet.prefersGrabberVisible = true
                    sheet.detents = [.medium()]
                }
                present(viewController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Banner Functions
    func setLayouts() {
//        tableView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ClientHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == bannerTableView {
            return mySections.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == bannerTableView {
            switch mySections[section] {
            case .banner:
                return 1
            case .others:
                return 0
            }
        }else
        {
            return serviceList.count > 5 ? 5 : serviceList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bannerTableView {
            switch mySections[indexPath.section] {
            case .banner:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: BannerTableViewCell.identifier, for: indexPath) as? BannerTableViewCell else { return UITableViewCell() }
                cell.configureCell(serviceId: nil)
                self.bannerViews = cell.bannerViews
                
                cell.myScrollView.delegate = self
                cell.pageControl.currentPage = self.currentPage
                cell.pageControl.addTarget(self, action: #selector(pageControlDidTap), for: .touchUpInside)
                UIView.animate(withDuration: 1) {
                    cell.myScrollView.contentOffset.x = self.xOffset
                }
                return cell
                
            case .others:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceDetailTableViewCell", for: indexPath) as? ServiceDetailTableViewCell
            if serviceList.count > 0 {
                let service = serviceList[indexPath.row]
                cell?.configureCell(service: service)
            }
            return cell ?? UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == bannerTableView {
            switch mySections[indexPath.section] {
            case .banner:
                return 240
            case .others:
                return tableView.estimatedRowHeight
            }
        }else{
            return 125
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == serviceListTableView {
            //Redirect to service detail page
            if let viewController = UIStoryboard(name: "ServiceDetail", bundle: nil).instantiateViewController(withIdentifier: "ClientServiceDetailViewController") as? ClientServiceDetailViewController {
                if let navigator = navigationController {
                    let selectedService = serviceList[indexPath.item]
                    viewController.selectedService = selectedService
                    navigator.pushViewController(viewController, animated: true)
                    
                }
            }
        }
    }
}

extension ClientHomeViewController: UIScrollViewDelegate {
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


extension ClientHomeViewController:  CLLocationManagerDelegate{

    func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            getAddressFromLatLon(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            addressLbl.text = "Lat : \(location.coordinate.latitude) \nLng : \(location.coordinate.longitude)"
        }
    }
    
    func getAddressFromLatLon(latitude: Double, longitude : Double) {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = latitude
            center.longitude = longitude

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }

                        self.currentAddress = PlaceObject(title: addressString , subtitle: "", coordinate: CLLocationCoordinate2DMake(latitude , longitude ))
                        self.addressLbl.text = addressString;
                        print(addressString)
                        self.saveAddress()
                  }
            })

        }
    
    func saveAddress(){
        if (UserDefaultsManager.shared.getUserLogin()){
            let user =  UserDefaultsManager.shared.getUserData()
            if let client = CoreDataManager.shared.getClient(email: user.email) {
                if (CoreDataManager.shared.checkClientLocationInDB(email: client.email ?? "")){
//                    CoreDataManager.shared.deleteClientLocation(email: client.email ?? "")
                    setLocationObject(isUpdate: true,client: client)
                    
                }else{
                    
                    setLocationObject(isUpdate: false,client: client)
                }
            }
        }
    }
    
    //MARK: - Core data interaction methods
    func setLocationObject(isUpdate : Bool, client : Client) {
        DispatchQueue.global(qos: .background).async {
        var selectedLocation: Address?
           selectedLocation = CoreDataManager.shared.getUserLocationData(email: client.email ?? "")
            if selectedLocation == nil {
                selectedLocation = Address(context: self.context)
                selectedLocation?.addressId = CoreDataManager.shared.getAddressID()
            }
        selectedLocation?.addressLatitude = self.currentAddress?.coordinate.latitude ?? 0
            selectedLocation?.addressLongitude = self.currentAddress?.coordinate.longitude ?? 0
            selectedLocation?.address = self.currentAddress?.title
            selectedLocation?.clientAddress = client
            self.saveLocation()
            if let location = selectedLocation {
                if isUpdate {
                    InitialDataDownloadManager.shared.updateAddressData(addressObject: location){[weak self] status in
                        DispatchQueue.main.async {
                            guard let strongSelf = self else {
                                return
                            }
                            if let status = status{
                                if status == false {
                                }
                            }
                        }
                    }
                }else{
                    InitialDataDownloadManager.shared.addAddressData(address: location){ [weak self] status in
                        DispatchQueue.main.async {
                            guard let strongSelf = self else {
                                return
                            }
                            if let status = status{
                                if status == false {
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func saveLocation() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
}

//MARK: CollectionView Delegates
extension ClientHomeViewController :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.categoryCollectioView){
            return 4
        }
        else{
            return vendorList.count > 10 ? 10 : vendorList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.categoryCollectioView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryListCollectionViewCell", for: indexPath) as? CategoryListCollectionViewCell
            if categoryList.count > 0 {
                let category = categoryList[indexPath.row]
                cell?.configureCell(category: category)
            }
            return cell ?? UICollectionViewCell()
        }
        
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewVendorCollectionViewCell", for: indexPath) as? NewVendorCollectionViewCell
            if vendorList.count > 0 {
                let vendor = vendorList[indexPath.row]
                cell?.configureCell(vendor: vendor)
            }
            return cell ?? UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == categoryCollectioView){
            return CGSize.init(width: 82, height: 82)
        }
        else{
            return CGSize.init(width: 80, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == self.categoryCollectioView){
            if let viewController = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "CategoryServiceListTableViewController") as? CategoryServiceListTableViewController {
                if let navigator = navigationController {
                    let selectedCategory = categoryList[indexPath.item]
                    viewController.selectedCategory = selectedCategory
                    navigator.pushViewController(viewController, animated: true)
                    
                }
            }
        }else{
            if let viewController = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "CategoryServiceListTableViewController") as? CategoryServiceListTableViewController {
                if let navigator = navigationController {
                    let selectedVendor = vendorList[indexPath.item]
                    viewController.selectedVendor = selectedVendor
                    navigator.pushViewController(viewController, animated: true)
                    
                }
            }
        }
    }    
}

extension ClientHomeViewController : UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let viewController = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "ServiceSearchTableViewController") as? ServiceSearchTableViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}

//MARK: Secntion Enum

extension ClientHomeViewController {
    enum TableSections {
        case banner, others
    }
}


// MARK: - MapViewDelegate
extension ClientHomeViewController: MapViewDelegate {
    func openSelectedLocation() {
        openMapView()
    }
    
    private func openMapView() {
        let mapViewController:MapViewController = UIStoryboard(name: "MapView", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController ?? MapViewController()
        if let navigator = navigationController {
            mapViewController.delegate = self
            mapViewController.selectLocation = true
            navigator.pushViewController(mapViewController, animated: true)
        }
    }
    
    func setServiceLocation(place : PlaceObject){        
        self.currentAddress = place
        self.addressLbl.text = place.title;
        presentModal()
    }
}
