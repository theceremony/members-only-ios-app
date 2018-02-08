//
//  ViewController.swift
//  Members Only
//
//  Created by JeramyMorrill on 2/7/18.
//  Copyright © 2018 JeramyMorrill. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController{
    
    var manager:BLEManager!
    // Observers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?
    private weak var didConnectToPeripheralObserver: NSObjectProtocol?
    // --------------------------------------------------------------------
    private var peripheralConnected:Bool = false;
    // --------------------------------------------------------------------
    @IBOutlet weak var connectedTextField: UITextField!
    @IBAction func fadeInTouched(_ sender: Any) {
        print("FADE IN BITCH");
    }
    @IBAction func fadeOutTouched(_ sender: Any) {
        print("FADE OUT BITCH");
    }
    @IBAction func togglePowerTouched(_ sender: Any) {
        print("TOGGLE POWER BITCH");
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = BLEManager.sharedInstance
        
        didDisconnectFromPeripheralObserver = NotificationCenter.default.addObserver(
            forName: .didDisconnectFromPeripheral,
            object: nil,
            queue: .main,
            using: didDisconnectFromPeripheral
        )
        
        didConnectToPeripheralObserver = NotificationCenter.default.addObserver(
            forName: .didConnectToPeripheral,
            object: nil,
            queue: .main,
            using: didConnectToPeripheral
        )
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    fileprivate func didConnectToPeripheral(notification: Notification){
        peripheralConnected = true;
        connectedTextField.textColor = UIColor.blue;
        connectedTextField.text = "IS CONNECTED: TRUE"
        
    }
    fileprivate func didDisconnectFromPeripheral(notification: Notification){
        peripheralConnected = true;
        connectedTextField.textColor = UIColor.red;
        connectedTextField.text = "IS CONNECTED: FALSE"
    }
}

