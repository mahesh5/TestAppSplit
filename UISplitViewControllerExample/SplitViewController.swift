//
//  SplitViewController.swift
//  UISplitViewControllerExample
//
//  Created by Admin on 26/02/16.
//  Copyright © 2016 tvsi. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the preferred display mode SplitViewController.
        
        splitViewController?.preferredDisplayMode = .PrimaryOverlay
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
