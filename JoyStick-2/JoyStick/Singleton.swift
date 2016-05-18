//
//  Singleton.swift
//  Clocko
//
//  Created by Luiz Veloso on 4/23/16.
//  Copyright © 2016 Luiz Veloso. All rights reserved.
//


import UIKit
import EventKit

class Singleton {
    
    static let sharedInstance = Singleton()
    
    var connectionType = String()
    var username = String()
    
}
