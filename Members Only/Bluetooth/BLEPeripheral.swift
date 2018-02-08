//
//  BLEPeripheral.swift
//  Members Only
//
//  Created by JeramyMorrill on 2/8/18.
//  Copyright © 2018 JeramyMorrill. All rights reserved.
//  Based on Antonio García's peripheral class:
//  https://github.com/adafruit/Bluefruit_LE_Connect_v2/blob/master/Bluefruit/Common/AdafruitKit/Ble/BleCentralMode/BlePeripheral.swift

import Foundation
import CoreBluetooth

class BLEPeripheral: NSObject {
    
    fileprivate var commandQueue = CommandQueue<BLECommand>()
    
    var peripheral: CBPeripheral
    var rssi: Int?
    var identifier: UUID { return peripheral.identifier }
    var name: String? { return peripheral.name }
    var state: CBPeripheralState { return peripheral.state}
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any]?, rssi: Int?){
        self.peripheral = peripheral
        self.rssi = rssi
        super.init()
        self.peripheral.delegate = self
        
    }
    
    func discover(serviceUuids: [CBUUID]?, completion: ((Error?) -> Void)?) {
        let command = BLECommand(type: .discoverService, parameters: serviceUuids, completion: completion)
        commandQueue.append(command)
    }
}

extension BLEPeripheral: CBPeripheralDelegate {
    
}
// MARK: - BLE Command
fileprivate class BLECommand: Equatable {
    enum CommandType {
        case discoverService
        case discoverCharacteristic
        case discoverDescriptor
        case setNotify
        case readCharacteristic
        case writeCharacteristic
        case writeCharacteristicAndWaitNofity
        case readDescriptor
    }
    enum CommandError: Error { case invalidService }
    var type: CommandType
    var parameters: [Any]?
    var completion: ((Error?) -> Void)?
    var isCancelled = false
    init(type: CommandType, parameters: [Any]?, timeout: Double? = nil, completion: ((Error?) -> Void)?) {
        self.type = type
        self.parameters = parameters
        self.completion = completion
    }
    func endExecution(withError error: Error?) { completion?(error) }
    static func == (left: BLECommand, right: BLECommand) -> Bool { return left.type == right.type }
}

// MARK: - Custom Notifications
extension Notification.Name {
    private static let kPrefix              = Bundle.main.bundleIdentifier!
    static let peripheralDidUpdateName      = Notification.Name(kPrefix+".peripheralDidUpdateName")
    static let peripheralDidModifyServices  = Notification.Name(kPrefix+".peripheralDidModifyServices")
    static let peripheralDidUpdateRssi      = Notification.Name(kPrefix+".peripheralDidUpdateRssi")
}
