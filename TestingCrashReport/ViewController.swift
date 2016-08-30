//
//  ViewController.swift
//  TestingCrashReport
//
//  Created by Yoman on 8/11/16.
//  Copyright © 2016 yoman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btnTesting(sender: UIButton) {
        
      
        let array = NSArray()
        _ = array.objectAtIndex(99)
        
        
    }
    @IBAction func testingAction(sender: UIButton) {
        
            let a = ["123","123"]
            _ = a[3]
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

