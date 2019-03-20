//
//  GameScene.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import SpriteKit

class GameScene: SKScene {
    
//    let gem = SKSpriteNode(imageNamed: "gem")
    
    
    override func didMove(to view: SKView) {
        addBackground()
//        addGem()
        addEmitter()
        
    }
    
    
    func addBackground() {
        let backdrop = SKSpriteNode(imageNamed: "City-PoorAirQuality")
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.zPosition = Layers.background
        addChild(backdrop)
        
//        let screenFilter = SKSpriteNode(color: UIColor.black, size: backdrop.size)
//        screenFilter.position = backdrop.position
//        screenFilter.alpha = 0.8
//        backdrop.zPosition = Layers.filter
//        addChild(screenFilter)
        
        view!.backgroundColor = UIColor.init(red: 48.0/255.0, green: 43.0/255.0, blue: 42.0/255.0, alpha: 1)
    }
    
    
//    func addGem() {
//        addChild(gem)
//        gem.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
//        gem.zPosition = Layers.gem
//        gem.setScale(2.5)
//    }
    
    
    func addEmitter() {
        let emitter = SKEmitterNode(fileNamed: "Fumes")!
        emitter.zPosition = Layers.emitter
        emitter.position = CGPoint(x: view!.frame.size.width / 2, y: 0)
        emitter.advanceSimulationTime(30)
        addChild(emitter)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        
        
//        if gem.contains(touchLocation) {
//            explodeGem()
//        }
    }
    
    
//    func explodeGem() {
//        let emitter = SKEmitterNode(fileNamed: Emitter.gem)!
//        emitter.position = gem.position
//        addChild(emitter)
//        gem.removeFromParent()
//    }
}
