//
//  OnboardingViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-05.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var imgPaging: UIImageView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var currentIndex = 0
    var pageImage = ["onboarding_bg_1.png",
                     "onboarding_bg_2.png",
                     "onboarding_bg_3.png"]
    var pagePaging = ["onboarding_paging_1.png",
                      "onboarding_paging_2.png",
                      "onboarding_paging_3.png"]
    var bgButtonNext = ["onboarding_next.png",
                        "onboarding_next.png",
                        "onboarding_finish.png"]
    var pageTitle = ["Step 1: \nExplore our services",
                     "Step 2: \nBook with few taps",
                     "Step 3: \nService delivered"]
    var pageDescriptionText = ["Explore our wide varieties of services provided with carefully selected and approved list of vendors.", "Provide the time and date along with your location for the service to be provided and hit the confirm button.", "Our experts will arrive at your provided location and deliver the service to you."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPageContent(at: currentIndex)
    }

    
    @IBAction func skip(_ sender: UIButton) {
        skip()
    }
    
    @IBAction func next(_ sender: UIButton) {
        if(currentIndex == 2){
            skip()
        } else {
            currentIndex += 1
            setPageContent(at: currentIndex)
        }
    }
    
    
    func skip(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
        if let navigator = navigationController {
            navigator.pushViewController(vc, animated: true)
        }
    }
    
    func setPageContent(at index: Int){
        titleLabel.text = pageTitle[index]
        descriptionLabel.text = pageDescriptionText[index]
        imgBg.image = UIImage(named: pageImage[index])
        imgPaging.image = UIImage(named: pagePaging[index])
        nextButton.setImage(UIImage(named: bgButtonNext[index]), for: .normal)
    }
}



