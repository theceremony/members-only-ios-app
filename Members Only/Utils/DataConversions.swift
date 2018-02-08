//
//  DataConversions.swift
//  Members Only
//
//  Created by JeramyMorrill on 2/8/18.
//  Copyright © 2018 JeramyMorrill. All rights reserved.
//  Based on Antonio García's Data Conversions code:
//  https://github.com/adafruit/Bluefruit_LE_Connect_v2/blob/6fa803f7412182f9ca958b6d5496dee09c4ddd89/Bluefruit/Common/AdafruitKit/Utils/DataConversions.swift

import Foundation

func hexDescription(data: Data, prefix: String = "", postfix: String = " ") -> String {
    return data.reduce("") {$0 + String(format: "%@%02X%@", prefix, $1, postfix)}
}

func hexDescription(bytes: [UInt8], prefix: String = "", postfix: String = " ") -> String {
    return bytes.reduce("") {$0 + String(format: "%@%02X%@", prefix, $1, postfix)}
}

func decimalDescription(data: Data, prefix: String = "", postfix: String = " ") -> String {
    return data.reduce("") {$0 + String(format: "%@%ld%@", prefix, $1, postfix)}
}
