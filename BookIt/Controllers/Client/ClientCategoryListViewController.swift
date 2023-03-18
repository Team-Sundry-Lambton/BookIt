//
//  ClientCategoryListViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit
import CoreData

class ClientCategoryListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories: [Category] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedObjectContext: NSManagedObjectContext!
    
    let categoriesList = [
            ["name": "Repair", "imageName": "repair"],
            ["name": "Cleaning", "imageName": "cleaning"],
            ["name": "Plumbing", "imageName": "plumbing"],
            ["name": "Logistics", "imageName": "logistics"],
            ["name": "Pest Control", "imageName": "pestControl"],
            ["name": "Electrical", "imageName": "electrical"],
            ["name": "Pet Services", "imageName": "petServices"],
            ["name": "Beauty", "imageName": "beautyAndWellness"],
            ["name": "Interior", "imageName": "interiorDesign"],
            ["name": "Tutoring", "imageName": "tutoring"],
            ["name": "Accounting", "imageName": "accounting"],
            ["name": "Fitness", "imageName": "fitness"]
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch categories from Core Data
        loadCategories()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func loadCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let count = try! context.count(for: fetchRequest)
        
        if count == 0 {
            for categoryData in categoriesList {
                let category = Category(context: context)
                category.name = categoryData["name"]!
                category.image = UIImage(named: categoryData["imageName"]!)?.pngData()
                // If the image is not found, you can use a placeholder image or set the image to nil
            }
            
            // Save the changes to Core Data
            try! context.save()
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            categories = try context.fetch(fetchRequest)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
    }
    
}

extension ClientCategoryListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        let category = categories[indexPath.item]
        cell.categoryLabel.text = category.name
        cell.categoryImageView.image = UIImage(data: category.image!)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight: CGFloat = 100 // Set the desired height for the cell
        
        // Determine the width of the cell based on its position in the collection view
        let row = indexPath.row / 2 // Divide by 2 to group cells into pairs for each row
        let isFirstCell = indexPath.row % 2 == 0 || indexPath.row == 0
        let isOddRow = row % 2 == 0
        let cellWidth = isFirstCell ? (isOddRow ? collectionView.frame.width * 0.55 : collectionView.frame.width * 0.38) : (isOddRow ? collectionView.frame.width * 0.38 : collectionView.frame.width * 0.55)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get a reference to the cell that was tapped
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        // Animate the cell
        UIView.animate(withDuration: 0.2, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }
        })
        
        // Handle the user's tap on the cell here
        if let viewController = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "CategoryServiceListTableViewController") as? CategoryServiceListTableViewController {
            if let navigator = navigationController {
                let categoryName = categories[indexPath.item].name
                viewController.categoryName = categoryName
                navigator.pushViewController(viewController, animated: true)
                
            }
        }
        
    }

}
