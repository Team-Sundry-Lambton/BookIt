//
//  OnboardingViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-05.
//

import UIKit

class OnboardingViewController: UIViewController {

    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func skip(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(newViewController, animated: true, completion: nil)

    }
    
    
    @IBAction func next(_ sender: UIButton) {
        

    }
    
}



