//
//  ViewController.swift
//  Example
//
//  Created by Abhishek  Singla on 03/11/22.
//

import UIKit
import StepCounterFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let classObj = HealthStore.shared
        debugPrint(classObj)
    }
}

