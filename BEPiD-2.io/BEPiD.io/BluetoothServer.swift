//
//  BluetoothServer.swift
//  CoreBluetooth
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothReciever {
	func reciveData(data: String)
}

class BluetoothServer: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{

	var delegate: BluetoothReciever?
	
	var manager: CBCentralManager!
	//var peripheral: CBPeripheral?
    var perifs:[CBPeripheral] = []
    var caractcs:[CBCharacteristic] = []
    //var caract: CBCharacteristic?

	var data  = NSMutableData()

    var timer:NSTimer?
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

	static let sharedInstance = BluetoothServer()
	
	private override init() {
		super.init()


	}
	
    func timerUpdate(){
        if perifs.count > 0 {
            for (idx, car) in caractcs.enumerate(){//per in perifs {
                let per = perifs[idx]
                    per.setNotifyValue(false, forCharacteristic: car)
                    per.setNotifyValue(true, forCharacteristic: car)
            }
        }
    }
	func start() {
		self.manager = CBCentralManager(delegate: self, queue: nil)
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: scan API
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func scanForPheripherals() {
		//NSLog("scanning for peripherals...")

		self.manager.scanForPeripheralsWithServices([Bluetooth.Service], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
	}

	func stopScan() {
		self.manager.stopScan()
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: CBCentralManagerDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func centralManagerDidUpdateState(central: CBCentralManager) {
		guard central.state == .PoweredOn else {
			return NSLog("manager is not powered on")
		}
		self.scanForPheripherals()
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		// Reject any where the value is above reasonable range
//		if RSSI.integerValue > -15 {
//			return
//		}
		// Reject if the signal strength is too low to be close enough (Close is around -22dB)
//		if RSSI.integerValue < -35 {
//			return
//		}

		/*if self.peripheral != peripheral {
			self.peripheral = peripheral
			NSLog("connecting to peripheral...")
			self.manager.connectPeripheral(self.peripheral!, options: nil)
		}*/
        
        if (advertisementData[CBAdvertisementDataServiceUUIDsKey]![0] != nil){
           // print("Perif: \(advertisementData[CBAdvertisementDataServiceUUIDsKey]![0])")
            if advertisementData[CBAdvertisementDataServiceUUIDsKey]![0] as! CBUUID == Bluetooth.Service{
                
                if perifs.filter({$0 == peripheral}).isEmpty {
                //self.peripheral = peripheral
                    perifs.append(peripheral)
              //  NSLog("connecting to peripheral...")
                    self.manager.connectPeripheral(peripheral, options: nil)
                }
            }
        }

	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        guard !perifs.filter({$0 == peripheral}).isEmpty else{
//self.peripheral == peripheral else {
			return NSLog("could not connect to peripheral")
		}

		/*NSLog("connected: \(peripheral.name)")

		self.stopScan()
		self.data.length = 0
		peripheral.delegate = self
		peripheral.discoverServices([Bluetooth.Service])*/
        peripheral.delegate = self
        peripheral.discoverServices([Bluetooth.Service])
        
        //print("Perif state: \(peripheral.state.rawValue)");

	}
	
	func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        guard !perifs.filter({$0 == peripheral}).isEmpty else{
            //self.peripheral == peripheral else {
            return NSLog("could not disconnect")
        }


		NSLog("disconnected: \(peripheral.name)")
		//self.peripheral = nil
        
            let idx = perifs.indexOf({$0 == peripheral})!
        
            perifs.removeAtIndex(idx)
            caractcs.removeAtIndex(idx)
        
		//self.scanForPheripherals()
	}

	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		//NSLog("connection failed: \(error)")
		//self.cleanup()
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: CBPeripheralDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard !perifs.filter({$0 == peripheral}).isEmpty && error == nil else{
            //self.peripheral == peripheral else {
            NSLog("error discovering service: \(error)")
            return NSLog("could not discover service")
        }
		/*guard self.peripheral == peripheral && error == nil else {
			NSLog("error discovering service: \(error)")
			self.cleanup()
			return
		}
         
		for service in peripheral.services ?? [] {
			peripheral.discoverCharacteristics([Bluetooth.Characteristics], forService: service)
		}*/
        for service in peripheral.services ?? [] {
           // print("Discovered service: \(service.UUID)")
            peripheral.discoverCharacteristics([Bluetooth.Characteristics], forService: service)
        }
	}
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard !perifs.filter({$0 == peripheral}).isEmpty else{
            //self.peripheral == peripheral else {
            return NSLog("could not discover charact")
        }

	/*	guard self.peripheral == peripheral && error == nil else {
			//NSLog("error discovering service: \(error)")
			self.cleanup()
			return
		}
 */
		/*for characteristics in service.characteristics ?? [] {
			if characteristics.UUID == Bluetooth.Characteristics {
				self.peripheral!.setNotifyValue(true, forCharacteristic: characteristics)
			}
		}*/
        for characteristics in service.characteristics ?? [] {
            if characteristics.UUID == Bluetooth.Characteristics {
                
                for per in perifs{
                    per.setNotifyValue(true, forCharacteristic: characteristics)
                }
                
                if(caractcs.count <= 0){
                    timer = NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector:   #selector(timerUpdate), userInfo: nil, repeats: true)
                }
                
                if caractcs.filter({$0 == characteristics}).isEmpty {
                    //self.peripheral = peripheral
                    caractcs.append(characteristics)
                    //  NSLog("connecting to peripheral...")
                }

               
            }
        }
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        guard !perifs.filter({$0 == peripheral}).isEmpty && error == nil else{
            //self.peripheral == peripheral else {
            NSLog("num perifs: \(perifs.count)")
            return
        }
		/*guard self.peripheral == peripheral && error == nil else {
			//NSLog("error discovering service: \(error)")
			self.cleanup()
			return
		}*/

		let string = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)

		/*if string == Bluetooth.EOM {
			let string = String(data: self.data, encoding: NSUTF8StringEncoding)

			NSLog("\(string)")
			
			if delegate != nil {
				delegate?.reciveData(string!)
			}

			self.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
			self.manager.cancelPeripheralConnection(peripheral)
		}
		
		self.data.appendData(characteristic.value!)*/
        if string == Bluetooth.EOM {
            let string = String(data: self.data, encoding: NSUTF8StringEncoding)
            
            //NSLog("\(string!)")
            
            if delegate != nil {
                delegate?.reciveData(string!)
            }
            //self.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
            //self.manager.cancelPeripheralConnection(peripheral)
            self.data.length = 0
            return
        }
        
        self.data.appendData(characteristic.value!)

	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if characteristic.UUID != Bluetooth.Characteristics {
			return
		}
		if characteristic.isNotifying {
			//NSLog("notif begin on \(characteristic)")
		}
		else {
			//self.manager.cancelPeripheralConnection(peripheral)
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: cleanup
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	/*func cleanup() {
		if let services = self.peripheral?.services {
			for service in services {
				for characteristic in service.characteristics! {
					if characteristic.UUID == Bluetooth.Characteristics && characteristic.isNotifying {
						self.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
					}
				}
			}
			self.manager.cancelPeripheralConnection(self.peripheral!)
		}
	}*/
	
	
}

