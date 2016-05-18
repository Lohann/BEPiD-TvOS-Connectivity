//
//  GameScene.swift
//  JoyStick
//
//  Created by Luiz Veloso on 5/12/16.
//  Copyright (c) 2016 Luiz Veloso. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let circle = SKSpriteNode(imageNamed: "circle.png")
    let base = SKSpriteNode(imageNamed: "base.png")
    
    let connectionType = Singleton.sharedInstance.connectionType
    let username = Singleton.sharedInstance.username
    
    
    override func didMoveToView(view: SKView) {
        
        // Tenta conectar com o servidor (TCP, Bluetooth) e inicia o envio de dados (Bluetooth).
        startAdvertisingToServer()
        
        
        // Centraliza a origin da tela
        self.anchorPoint = CGPointMake(0.5 , 0.5) // anchorPoint define a origem da scene
       
        
        // Seta a base
        self.addChild(base)
        base.position = CGPointMake(0,0)
        base.xScale = 0.5
        base.yScale = 0.5
        //base.alpha = 0.4

        
        // Seta o Joystick
        self.addChild(circle)
        circle.position = base.position
        circle.xScale = 0.4
        circle.yScale = 0.4
        circle.zPosition = base.zPosition + 1
        //circle.alpha = 0.4
        
        
        // Seta o background
        self.backgroundColor = SKColor.blackColor()
        
     }
   
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
//        for touch in touches {
//            let location = touch.locationInNode(self)
//         }
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            //TODO: TALVEZ SÓ PRECISE DISSO...
            let v        = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
          
            
            let angle    = atan2(v.dy, v.dx)
            
        //    var degree = angle * CGFloat (180 / M_PI)
            
            let length: CGFloat = base.frame.size.height / 2
            let xDist: CGFloat = sin(angle - 1.57079633) * length
            let yDist: CGFloat = cos(angle - 1.57079633) * length
            
            
            // rever se isso é relevante.
            if (CGRectContainsPoint(base.frame, location)) {
                circle.position = location
            } else {
                circle.position = CGPointMake(base.position.x - xDist, base.position.y + yDist)
                
            }
            
            print (circle.position.x)
            print (circle.position.y)

        
            self.passDataToServer()
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let stickActive = true
       
        //Passa os dados quando o joystick voltar a posição inicial.
        if (stickActive == true) {
            let move:SKAction = SKAction.moveTo(base.position, duration: 0.2)
            move.timingMode = .EaseOut
            circle.runAction(move, completion: { Void in
                self.passDataToServer()
            })
            
        }
    }
    
    /**
     Identifica o tipo de conexão e passa os dados corretos.
     */
    func passDataToServer() {
        
        let x = self.circle.position.x
        let y = self.circle.position.y
        
        if self.connectionType == "TCP" {
            
            BonjourTCPClient.sharedInstance.send("\(self.username)|\(x)|\(y)")
            
        } else if self.connectionType == "CoreBluetooth" {
            
            BluetoothClient.sharedInstance.dataString = "\(self.username)|\(x)|\(y)"
            
        }
    }
    
    /**
        Cria a primeira conexão com o bluetooth ou conecta o tcp.
     */
    func startAdvertisingToServer() {
        
        if self.connectionType == "TCP" {
            
            BonjourTCPClient.sharedInstance.servicesCallback = { (services) in
                guard let service = services.first else {
                    return NSLog("No services...")
                }
                BonjourTCPClient.sharedInstance.connectTo(service, callback: {
                    NSLog("Connected")
                })
            }
            
        } else if self.connectionType == "CoreBluetooth" {
            
            BluetoothClient.sharedInstance.dataString = "\(self.username)|\(0.0)|\(0.0)"
            BluetoothClient.sharedInstance.startAdvertising()
            
        }
        
        
    }

    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
