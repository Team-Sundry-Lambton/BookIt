//
//  ClientHomeViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit
import SnapKit
import CoreLocation
import CoreData

class ClientHomeViewController: UIViewController {
    var loginUser : LoginUser?
    
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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        setTimer()
        tabBarAppearance()
        getUserLocation()
        
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
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
        
        categoryCollectioView.register(CategoryListCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryListCollectionViewCell")
        categoryCollectioView.dataSource = self
        categoryCollectioView.delegate = self
        
        newVendersCollectionView.register(NewVendorCollectionViewCell.self, forCellWithReuseIdentifier: "NewVendorCollectionViewCell")
        newVendersCollectionView.dataSource = self
        newVendersCollectionView.delegate = self
        
        serviceListTableView.register(ServiceDetailTableViewCell.self, forCellReuseIdentifier: "ServiceDetailTableViewCell")
        serviceListTableView.delegate = self
        serviceListTableView.dataSource = self
        
        bannerTableView.register(BannerTableViewCell.self, forCellReuseIdentifier: BannerTableViewCell.identifier)
        bannerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        bannerTableView.delegate = self
        bannerTableView.dataSource = self
        setLayouts()
    }
    
    func loadData(){
        loadCategories()
        categoryCollectioView.reloadData()
        
        loadNewVendors()
        newVendersCollectionView.reloadData()
        
        loadServices()
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
            return serviceList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bannerTableView {
            switch mySections[indexPath.section] {
            case .banner:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: BannerTableViewCell.identifier, for: indexPath) as? BannerTableViewCell else { return UITableViewCell() }
                
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
//            let lat: Double = Double("\(pdblLatitude)")!
//            //21.228124
//            let lon: Double = Double("\(pdblLongitude)")!
//            //72.833770
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
                  }
            })

        }
    
}

//MARK: CollectionView Delegates
extension ClientHomeViewController :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.categoryCollectioView){
            return 4
        }
        else{
            return vendorList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.categoryCollectioView){
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryListCollectionViewCell", for: indexPath) as? CategoryListCollectionViewCell ?? CategoryListCollectionViewCell()
            if categoryList.count > 0 {
                let category = categoryList[indexPath.row]
                cell.configureCell(category: category)
            }
            return cell
        }
        
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewVendorCollectionViewCell", for: indexPath) as? NewVendorCollectionViewCell ?? NewVendorCollectionViewCell()
            if vendorList.count > 0 {
                let vendor = vendorList[indexPath.row]
                cell.configureCell(vendor: vendor)
            }
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == categoryCollectioView){
            return CGSize.init(width: 82, height: 82)
        }
        else{
            return CGSize.init(width: 74, height: 74)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == self.categoryCollectioView){
            //Redirect to Service List Page
        }else{
            //Redirect to Vendor Service List Page
        }
    }    
}

//MARK: - Core data interaction methods
extension ClientHomeViewController {

    /// load Category from core data
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchLimit = 5
        do {
            categoryList = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
    }
    
    func loadNewVendors(){
        let request: NSFetchRequest<Vendor> = Vendor.fetchRequest()      
//        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: false)]
//        request.fetchLimit = 5
//        request.returnsObjectsAsFaults = false
        do {
            let allElementsCount = try context.count(for: request)
               request.fetchLimit = 5
               request.fetchOffset = allElementsCount - 5
               request.returnsObjectsAsFaults = false
            vendorList = try context.fetch(request)
        } catch {
            print("Error loading Vendor \(error.localizedDescription)")
        }
    }
    
    func loadServices(){
        let request: NSFetchRequest<Service> = Service.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "serviceTitle", ascending: true)]
        request.fetchLimit = 5
        do {
            serviceList = try context.fetch(request)
        } catch {
            print("Error loading Service \(error.localizedDescription)")
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
