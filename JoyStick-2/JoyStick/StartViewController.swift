//
//  StartViewController.swift
//  JoyStick
//
//  Created by Luiz Veloso on 5/13/16.
//  Copyright © 2016 Luiz Veloso. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var txtfName: UITextField!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func btnCoreBluetooth(sender: AnyObject) {
        if txtfName.text?.characters.count != 0 { //Caso a string nao seja não seja vazia,
            Singleton.sharedInstance.connectionType = "CoreBluetooth" // define o connectionType
            Singleton.sharedInstance.username = txtfName.text! // define o username definido na string
            self.performSegueWithIdentifier("goJoystick", sender: self) // e envia para a tela de joystick
        }
    }

    
    @IBAction func btnTCP(sender: AnyObject) {
        if txtfName.text?.characters.count != 0 {
            Singleton.sharedInstance.connectionType = "TCP"
            Singleton.sharedInstance.username = txtfName.text!
            self.performSegueWithIdentifier("goJoystick", sender: self)
        }
    }

}
