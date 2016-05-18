//
//  Circle.swift
//  BEPiD.io
//
//  Created by Allison Lindner on 12/05/16.
//  Copyright © 2016 Allison Lindner. All rights reserved.
//

import SpriteKit

class Circle: SKSpriteNode {
	
	var velocity: CGVector = CGVectorMake(0.0, 0.0)
	
	init(color: UIColor) {
		super.init(texture: SKTexture(imageNamed: "circle"), color: color, size: CGSizeMake(30.0, 30.0))
		
		self.color = color
		self.colorBlendFactor = 1.0
		
		self.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
		self.physicsBody?.dynamic = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func update() {
		self.physicsBody?.velocity = self.velocity
	}
}