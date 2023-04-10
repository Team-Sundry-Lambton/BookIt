//
//  ClientCategoryListViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit

class ClientCategoryListViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch categories from Core Data
        categories = CoreDataManager.shared.loadCategories()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")

        // Do any additional setup after loading the view.
    }
}

extension ClientCategoryListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell
        let category = categories[indexPath.item]
        cell?.categoryLabel.text = category.name
        if let imageData = category.picture {
            cell?.categoryImageView.downloaded(from: imageData)
        }
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight: CGFloat = 100 // Set the desired height for the cell
        
        // Determine the width of the cell based on its position in the collection view
        let row = indexPath.row / 2 // Divide by 2 to group cells into pairs for each row
        let isFirstCell = indexPath.row % 2 == 0 || indexPath.row == 0
        let isOddRow = row % 2 == 0
        let cellWidth = isFirstCell ? (isOddRow ? collectionView.frame.width * 0.37 : collectionView.frame.width * 0.55) : (isOddRow ? collectionView.frame.width * 0.55 : collectionView.frame.width * 0.37)
        
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
                let selectedCategory = categories[indexPath.item]
                viewController.selectedCategory = selectedCategory
                navigator.pushViewController(viewController, animated: true)
                
            }
        }
        
    }

}
