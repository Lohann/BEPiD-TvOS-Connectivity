//
//  GameViewController.swift
//  BEPiD.io
//
//  Created by Allison Lindner on 12/05/16.
//  Copyright (c) 2016 Allison Lindner. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let scene = GameSceneBonjour()
        let scene = GameSceneCB()
		// Configure the view.
		let skView = self.view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
//		skView.showsPhysics = true
		
		/* Sprite Kit applies additional optimizations to improve rendering performance */
		skView.ignoresSiblingOrder = true
		
		/* Set the scale mode to scale to fit the window */
		scene.size = CGSizeMake(skView.frame.width, skView.frame.height)
		scene.scaleMode = .AspectFit
		
		skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
