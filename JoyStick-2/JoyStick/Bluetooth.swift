//
//  Bluetooth.swift
//  CoreBluetooth
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation
import CoreBluetooth


class Bluetooth
{
	private static let serviceUUID         = "A20A39F4-73F5-4BC4-A12F-17D1AD07A961"
	private static let characteristicsUUID = "18590F7E-DB05-467E-8757-72F6FAEB13D4"
//    private static let serviceUUID         = "E20A39F4-73F5-4BC4-A12F-17D1AD666661"
//    private static let characteristicsUUID = "08590F7E-DB05-467E-8757-72F6F66666D4"

	static let Service				       = CBUUID(string: Bluetooth.serviceUUID)
	static let Characteristics             = CBUUID(string: Bluetooth.characteristicsUUID)
	
	static let EOM                         = "EOM"
	static let EOMData                     = Bluetooth.EOM.dataUsingEncoding(NSUTF8StringEncoding)!
}


//
//let TRANSFER_SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD666661"
//let TRANSFER_CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6F66666D4"
//let NOTIFY_MTU = 20
//
//let transferServiceUUID = CBUUID(string: TRANSFER_SERVICE_UUID)
//let transferCharacteristicUUID = CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)
