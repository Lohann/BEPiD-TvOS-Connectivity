//
//  GameScene.swift
//  BEPiD.io
//
//  Created by Allison Lindner on 12/05/16.
//  Copyright (c) 2016 Allison Lindner. All rights reserved.
//

import SpriteKit

class GameSceneBonjour: SKScene {
	
	var players: [String: Circle]!
	
    override func didMoveToView(view: SKView) {
		
		players = [:]
		
		self.anchorPoint = CGPointMake(0.5, 0.5)
		
		self.backgroundColor = UIColor.blackColor()
		self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
		
		BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data) in
			print("--->")
			
			let splitedData = data.componentsSeparatedByString("|")
			
			if splitedData.count < 3 {
				return
			}
			
			print("\(splitedData[0])|\(splitedData[1])|\(splitedData[2])")
			
			let nick = splitedData[0]
			
			if self.players[nick] == nil {
				self.players[nick] = Circle(color: UIColor(
													red: CGFloat(arc4random() % 255)/255.0,
													green: CGFloat(arc4random() % 255)/255.0,
													blue: CGFloat(arc4random() % 255)/255.0,
													alpha: 1.0
												)
											)
				
				self.addChild(self.players[nick]!)
			}
			
			var dx: CGFloat = self.players[nick]!.velocity.dx
			var dy: CGFloat = self.players[nick]!.velocity.dy
			
			if let _dx = Float(splitedData[1]) {
				dx = CGFloat(_dx)
			}
			
			if let _dy = Float(splitedData[2]) {
				dy = CGFloat(_dy)
			}
			
			self.players[nick]?.velocity.dx = dx * 1.5
			self.players[nick]?.velocity.dy = dy * 1.5
		}
    }
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
		for player in players {
			player.1.update()
		}
    }
}
