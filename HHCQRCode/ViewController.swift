//
//  ViewController.swift
//  HHCQRCode
//
//  Created by 王彦睿 on 2017/1/16.
//  Copyright © 2017年 家健文化传媒. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        let v = QRCodeScanViewController()
        present(v, animated: true)
    }


}

