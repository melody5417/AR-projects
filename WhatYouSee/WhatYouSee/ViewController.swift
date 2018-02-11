//
//  ViewController.swift
//  WhatYouSee
//
//  Created by yiqiwang(王一棋) on 2018/2/6.
//  Copyright © 2018年 melody5417. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func enterAR(_ sender: Any) {
        let vc = SceneViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

