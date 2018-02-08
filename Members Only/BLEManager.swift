//
//  BLEManager.swift
//  Members Only
//
//  Created by JeramyMorrill on 2/7/18.
//  Copyright © 2018 JeramyMorrill. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject {
    // --------------------------------------------------------------------
    static let sharedInstance = BLEManager()
    var connectedPeripheral: CBPeripheral?
    // --------------------------------------------------------------------
    fileprivate let BEAN_NAME = "Adafruit Bluefruit LE"
    fileprivate let BEAN_SCRATCH_UUID = CBUUID(
        string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    ) //UART UUID
    fileprivate let BEAN_SERVICE_UUID = CBUUID(
        string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    ) //UART UUID
    // --------------------------------------------------------------------
    fileprivate var centralManagerPowerOnSemaphore = DispatchSemaphore(value: 1)
    // --------------------------------------------------------------------
    var manager: CBCentralManager?
    var peripheral:CBPeripheral!
    // --------------------------------------------------------------------
    enum NotificationUserInfoKey: String { case uuid = "uuid" }
    // --------------------------------------------------------------------
    
    override init(){
        super.init()
        centralManagerPowerOnSemaphore.wait()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background), options: [:])
    }
    
}

extension BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    // --------------------------------------------------------------------
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if device?.contains(BEAN_NAME) == true {
            self.manager?.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self as CBPeripheralDelegate
            
            manager?.connect(peripheral, options: nil)
            
            NotificationCenter.default.post(
                name: .willConnectToPeripheral,
                object: nil,
                userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier]
            )
        }
    }
    // --------------------------------------------------------------------
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn || central.state == .poweredOff || central.state == .unsupported || central.state == .unauthorized {
            centralManagerPowerOnSemaphore.signal()
        }
        
        NotificationCenter.default.post(name: .didUpdateBleState, object: nil)
        if central.state == CBManagerState.poweredOn {
            centralManagerPowerOnSemaphore.wait()
            centralManagerPowerOnSemaphore.signal()
            NotificationCenter.default.post(name: .didStartScanning, object: nil)
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    // --------------------------------------------------------------------
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        self.connectedPeripheral = peripheral
        NotificationCenter.default.post(
            name: .didConnectToPeripheral,
            object: nil,
            userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier]
        )

    }
    // --------------------------------------------------------------------
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectedPeripheral = nil
        central.scanForPeripherals(withServices: nil, options: nil)
        NotificationCenter.default.post(
            name: .didDisconnectFromPeripheral,
            object: nil,
            userInfo: [NotificationUserInfoKey.uuid.rawValue: peripheral.identifier]
        )
    }
    // --------------------------------------------------------------------
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            if service.uuid == BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil,for: thisService)
            }
        }
    }
    // --------------------------------------------------------------------
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics!{
            let thisCharacteristic = characteristic as CBCharacteristic
            if thisCharacteristic.uuid == BEAN_SCRATCH_UUID {
                self.peripheral.setNotifyValue(true, for: thisCharacteristic)
            }
        }
    }
    // --------------------------------------------------------------------
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == BEAN_SCRATCH_UUID {
            print(characteristic.value!)
        }
    }
}

extension Notification.Name {
    private static let kPrefix              = Bundle.main.bundleIdentifier!
    static let didUpdateBleState            = Notification.Name(kPrefix+".didUpdateBleState")
    static let didStartScanning             = Notification.Name(kPrefix+".didStartScanning")
    static let didStopScanning              = Notification.Name(kPrefix+".didStopScanning")
    static let didDiscoverPeripheral        = Notification.Name(kPrefix+".didDiscoverPeripheral")
    static let didUnDiscoverPeripheral      = Notification.Name(kPrefix+".didUnDiscoverPeripheral")
    static let willConnectToPeripheral      = Notification.Name(kPrefix+".willConnectToPeripheral")
    static let didConnectToPeripheral       = Notification.Name(kPrefix+".didConnectToPeripheral")
    static let willDisconnectFromPeripheral = Notification.Name(kPrefix+".willDisconnectFromPeripheral")
    static let didDisconnectFromPeripheral  = Notification.Name(kPrefix+".didDisconnectFromPeripheral")
}
