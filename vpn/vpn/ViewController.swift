//
//  ViewController.swift
//  vpn
//
//  Created by duanhai on 2019/8/29.
//  Copyright © 2019 duanhai. All rights reserved.
//

import UIKit
import NetworkExtension
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func turnOn(_ sender: Any) {
    
        if VpnManager.shared.vpnStatus == .off {
            VpnManager.shared.connect()
        }else if VpnManager.shared.vpnStatus == .connecting || VpnManager.shared.vpnStatus == .on {
            VpnManager.shared.disconnect()
        }
    }
}

