//
//  GameScene.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import PlaygroundSupport
import SpriteKit
import AVFoundation
import CoreMotion

public class GameScene: SKScene {
    
    // Global
    public var orientation: UIInterfaceOrientation!
    // Sun
    var sunEmitter:SKEmitterNode?
    // Coal Plant
    var coalPowerStation:SKSpriteNode?
    var coalPowerStationFumes:SKEmitterNode?
    // Camera (used for brightness detection)
    var session: AVCaptureSession?
    var captureInput: AVCaptureInput!
    var videoOutput: AVCaptureVideoDataOutput!
    var brightness: Float = 0.0 {
        didSet {
            brightnessCount += 1
            totalBrightness += brightness
        }
    }
    var totalBrightness: Float = 0.0
    var brightnessCount: Int = 0
    var calculateBrightnessTimer: Timer?
    var calibratedBrightness: Float?
    // River
    var motion:CMMotionManager?
    var seaBins:[SKSpriteNode] = []
    var rubbishRemaining = 0
    var score = 0 {
        didSet {
            showMessage(message: "Score: \(score)")
        }
    }
    var fish:[SKLabelNode] = []
    var rubbish:[SKSpriteNode] = []
    // View
    var backdrop: SKSpriteNode?
    var sunPosition: CGPoint!
    var fumesEmitter: SKEmitterNode?
    var cloudsEmitter: SKEmitterNode?
    var messageLabel: SKLabelNode?
    var soundEffect: AVAudioPlayer?
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        sunPosition = CGPoint(x: size.width/3*2+50, y: size.height-50)
    }
    
    public override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        motion?.stopAccelerometerUpdates()
    }
    
    // MARK: - Scene Setup
    
    public func setupDirtyCity() {
        
        addHillsDirtyBackground()
        addFumes()
        addDirtySky(animate: false)
    }
    
    public func setupCleanCity() {
        
        addHillsCleanBackground()
        addClouds()
        addCleanSky(animate: false)
    }
    
    public func setupTreeHill() {
        
        addHillsTreesBackground()
        
        scene?.backgroundColor = UIColor.init(red: 157.0/255.0, green: 197.0/255.0, blue: 60.0/255.0, alpha: 1)
    }
    
    public func setupCoalHill() {
        
        addHillsCoalPowerBackground()
        addFumes()
        addDirtySky(animate: true)
    }
    
    public func setupSolarPowerHill() {
        
        addHillsSolarPowerBackground()
        addClouds()
        addCleanSky(animate: true)
        
        setupCamera()
        startCamera()
        
        PlaygroundPage.current.wantsFullScreenLiveView = true
    }
    
    public func setupRiver() {
        
        addRiverBackground()
        
        guard let url = Bundle.main.url(forResource: "Zip", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.soundEffect = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
        } catch {
            print(error)
        }
    }
    
    private func addHillsDirtyBackground() {
        
        if backdrop != nil {
            backdrop?.removeFromParent()
        }
        
        backdrop = SKSpriteNode(imageNamed: "Hills+City-Dirty")
        backdrop!.position = CGPoint(x: size.width / 2, y: backdrop!.size.height/2)
        backdrop!.zPosition = Layers.background
        backdrop!.lightingBitMask = 0b0001
        addChild(backdrop!)
    }
    
    private func addHillsCleanBackground() {
        
        if backdrop != nil {
            backdrop?.removeFromParent()
        }
        
        backdrop = SKSpriteNode(imageNamed: "Hills+City-Clean")
        backdrop!.position = CGPoint(x: size.width / 2, y: backdrop!.size.height/2)
        backdrop!.zPosition = Layers.background
        backdrop!.lightingBitMask = 0b0001
        addChild(backdrop!)
    }
    
    private func addHillsTreesBackground() {
        
        if backdrop != nil {
            backdrop?.removeFromParent()
        }
        
        backdrop = SKSpriteNode(imageNamed: "Hill1")
        backdrop!.position = CGPoint(x: size.width / 2, y: backdrop!.size.height/2)
        backdrop!.zPosition = Layers.background
        backdrop!.lightingBitMask = 0b0001
        addChild(backdrop!)
    }
    
    private func addHillsCoalPowerBackground() {
        
        if backdrop != nil {
            backdrop?.removeFromParent()
        }
        
        backdrop = SKSpriteNode(imageNamed: "Hill2+Coal")
        backdrop!.position = CGPoint(x: size.width / 2, y: backdrop!.size.height/2)
        backdrop!.zPosition = Layers.background
        backdrop!.lightingBitMask = 0b0001
        addChild(backdrop!)
    }
    
    private func addHillsSolarPowerBackground() {
        
        if backdrop != nil {
            backdrop?.removeFromParent()
        }
        
        backdrop = SKSpriteNode(imageNamed: "Hill2+Solar")
        backdrop!.position = CGPoint(x: size.width / 2, y: backdrop!.size.height/2)
        backdrop!.zPosition = Layers.background
        backdrop!.lightingBitMask = 0b0001
        addChild(backdrop!)
    }
    
    private func addRiverBackground() {
        
        let rippleEmitter = SKEmitterNode(fileNamed: "WaterRipples")!
        rippleEmitter.zPosition = Layers.emitter
        rippleEmitter.position = CGPoint(x: 0, y: size.height / 2)
        rippleEmitter.advanceSimulationTime(30)
        addChild(rippleEmitter)
        
        scene?.backgroundColor = UIColor.init(red: 0/255.0, green: 141.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    private func addFumes() {
        
        if let cloudsEmitter = cloudsEmitter {
            cloudsEmitter.particleBirthRate = 0
            cloudsEmitter.particleLifetime = 1
        }
        
        if fumesEmitter == nil {
            fumesEmitter = SKEmitterNode(fileNamed: "Fumes")!
            fumesEmitter!.zPosition = Layers.emitter
            fumesEmitter!.position = CGPoint(x: size.width / 2, y: size.height/2)
            fumesEmitter!.advanceSimulationTime(30)
            addChild(fumesEmitter!)
        } else {
            fumesEmitter!.particleBirthRate = 15
            fumesEmitter!.particleLifetime = 20
        }
    }
    
    private func addClouds() {
        
        if let fumesEmitter = fumesEmitter {
            fumesEmitter.particleBirthRate = 0
            fumesEmitter.particleLifetime = 1
        }
        
        if cloudsEmitter == nil {
            cloudsEmitter = SKEmitterNode(fileNamed: "Clouds")!
            cloudsEmitter!.zPosition = Layers.emitter
            cloudsEmitter!.position = CGPoint(x: 0, y: size.height/2)
            cloudsEmitter!.advanceSimulationTime(30)
            addChild(cloudsEmitter!)
        } else {
            cloudsEmitter!.particleBirthRate = 1
            cloudsEmitter!.particleLifetime = 100
        }
    }
    
    private func addDirtySky(animate: Bool) {
        
        UIView.animate(withDuration: animate ? 1 : 0) {
            self.scene?.backgroundColor = UIColor.init(red: 229.0/255.0, green: 217.0/255.0, blue: 198.0/255.0, alpha: 1)
        }
    }
    
    private func addCleanSky(animate: Bool) {
        
        UIView.animate(withDuration: animate ? 1 : 0) {
            self.scene?.backgroundColor = UIColor.init(red: 148.0/255.0, green: 223.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
    }
    
    private func showMessage(message: String) {
        
        if messageLabel != nil {
            messageLabel!.removeFromParent()
        }
        
        messageLabel = SKLabelNode(text: message)
        messageLabel!.zPosition = Layers.sprite
        messageLabel!.fontSize = 40
        messageLabel!.position = CGPoint(x: frame.size.width/2, y: 100)
        addChild(messageLabel!)
    }
    
    // MARK: - River
   
    public func startRiverGame() {
        
        PlaygroundPage.current.wantsFullScreenLiveView = true
        
        for f in self.fish {
            f.removeFromParent()
        }
        for r in self.rubbish {
            r.removeFromParent()
        }
        rubbishRemaining = 0
        
        score = 0
        
        self.addSeaBins()
        self.addRubbish()
        self.setupRiverPhysics()
        self.setupAccelerometer()
    }
    
    private func addSeaBins() {
        
        if seaBins.count > 0 {
            return
        }
        
        let positions = [CGPoint(x: self.size.width/3, y: self.size.height/3*2),
                         CGPoint(x: self.size.width/3*2, y: self.size.height/3)]
        let size = CGSize(width: 100, height: 100)
        
        for position in positions {
            let seaBin = SKSpriteNode(imageNamed: "SeaBin")
            seaBin.position = position
            seaBin.size = size
            seaBin.zPosition = Layers.sprite
            seaBin.zRotation = CGFloat.pi / CGFloat(arc4random() % 4 + 1)
            seaBin.run(.repeatForever(.rotate(byAngle: CGFloat(Double.pi), duration: 6)))
            
            seaBin.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
            seaBin.physicsBody?.allowsRotation = false
            seaBin.physicsBody?.categoryBitMask = CategoryBitMask.SeaBin
            seaBin.physicsBody?.contactTestBitMask = CategoryBitMask.Rubbish
            seaBin.physicsBody?.friction = 0.2
            seaBin.physicsBody?.linearDamping = 0.2
            seaBin.physicsBody?.restitution = 0.2
            seaBin.physicsBody?.affectedByGravity = false
            seaBin.physicsBody?.isDynamic = true
            seaBin.physicsBody?.mass = CGFloat(Int.max)
            
            addChild(seaBin)
            
            seaBins.append(seaBin)
        }
    }
    
    private func addRubbish() {
        
        let size = CGSize(width: 50, height: 50)
        rubbishRemaining = 20
        
        for _ in 0..<rubbishRemaining {
            let randX = CGFloat(arc4random() % 100) / 100 * self.size.width
            let randY = CGFloat(arc4random() % 100) / 100 * self.size.height
            
            let rubbishPiece = SKSpriteNode(imageNamed: "Rubbish")
            rubbishPiece.position = CGPoint(x: randX, y: randY)
            rubbishPiece.size = size
            rubbishPiece.zPosition = Layers.sprite
            rubbishPiece.zRotation = CGFloat.pi / CGFloat(arc4random() % 4 + 1)
            
            rubbishPiece.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
            rubbishPiece.physicsBody?.allowsRotation = true
            rubbishPiece.physicsBody?.categoryBitMask = CategoryBitMask.Rubbish
            rubbishPiece.physicsBody?.contactTestBitMask = CategoryBitMask.SeaBin
            rubbishPiece.physicsBody?.friction = 0.5
            rubbishPiece.physicsBody?.linearDamping = 0.5
            rubbishPiece.physicsBody?.restitution = 0.2
            rubbishPiece.physicsBody?.velocity = CGVector(dx: CGFloat(arc4random() % 100), dy: CGFloat(arc4random() % 100))
            
            addChild(rubbishPiece)
            self.rubbish.append(rubbishPiece)
        }
    }
    
    private func addFish() {
        
        var fish:SKLabelNode
        let fishType = arc4random() % 7
        switch fishType {
        case 0:
            fish = SKLabelNode(text: "🐟")
        case 1:
            fish = SKLabelNode(text: "🐠")
        case 2:
            fish = SKLabelNode(text: "🐡")
        case 3:
            fish = SKLabelNode(text: "🐳")
        case 4:
            fish = SKLabelNode(text: "🐬")
        case 5:
            fish = SKLabelNode(text: "🐙")
        case 6:
            fish = SKLabelNode(text: "🦞")
        case 7:
            fish = SKLabelNode(text: "🐢")
        default:
            return
        }
        
        fish.zPosition = Layers.sprite
        fish.fontSize = 50
        fish.position = CGPoint(x: frame.size.width-50, y: frame.size.height * (CGFloat(arc4random() % 100) / 100))
        
        fish.physicsBody = SKPhysicsBody(circleOfRadius: fish.frame.size.width/2)
        fish.physicsBody?.allowsRotation = true
        fish.physicsBody?.categoryBitMask = CategoryBitMask.Fish
        fish.physicsBody?.contactTestBitMask = CategoryBitMask.Rubbish
        fish.physicsBody?.friction = 0.2
        fish.physicsBody?.linearDamping = 0
        fish.physicsBody?.restitution = 0
        fish.physicsBody?.affectedByGravity = true
        fish.physicsBody?.velocity = CGVector(dx: CGFloat(arc4random() % 100), dy: CGFloat(arc4random() % 10))
        
        addChild(fish)
        self.fish.append(fish)
    }
    
    private func suckRubbish(_ rubbish: SKSpriteNode, intoBin bin: SKSpriteNode) {
        
        rubbish.physicsBody = nil
        
        let moveAction = SKAction.move(to: bin.position, duration: 0.5)
        let sizeAction = SKAction.scaleX(to: 0, y: 0, duration: 0.5)
        
        rubbish.run(moveAction)
        rubbish.run(sizeAction) {
            rubbish.removeFromParent()
            
            self.score += 1
            self.rubbishRemaining -= 1
            if self.rubbishRemaining == 0 {
                // TODO: game won! show end game message
                self.showMessage(message: "That's all the rubbish, nice work!")
            }
            
            // Randomly have fish swim past
            if arc4random() % 2 == 0 {
                self.addFish()
            }
        }
        
        if let soundEffect = soundEffect {
            soundEffect.play()
        }
    }
    
    private func removeFish(_ fish: SKLabelNode) {
        
        fish.physicsBody = nil
        
        let sizeAction = SKAction.scaleX(to: 0, y: 0, duration: 0.5)
        
        fish.run(sizeAction) {
            fish.removeFromParent()
            self.score -= 1
        }
    }
    
    private func setupRiverPhysics() {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        if physicsBody == nil {
            // Create an invisible barrier around the scene to keep the ball inside
            let sceneBound = SKPhysicsBody(edgeLoopFrom: frame)
            sceneBound.friction = 0
            sceneBound.restitution = 0
            sceneBound.linearDamping = 0.4
            physicsBody = sceneBound
        }
    }
    
    private func setupAccelerometer() {
        
        if motion == nil {
            motion = CMMotionManager()
        }
        
        if motion!.isAccelerometerActive == false {
            motion!.accelerometerUpdateInterval = 1.0/60.0
            motion!.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                if let error = error {
                    print("Error encountered getting accelerometer data \(error)")
                } else if let data = data {
                    DispatchQueue.main.async {
                        if (self.orientation == .landscapeRight) {
                            self.physicsWorld.gravity = CGVector(dx: -data.acceleration.y*10, dy: data.acceleration.x*10)
                        } else if (self.orientation == .landscapeLeft) {
                            self.physicsWorld.gravity = CGVector(dx: data.acceleration.y*10, dy: -data.acceleration.x*10)
                        }  else if (self.orientation == .portrait) {
                            self.physicsWorld.gravity = CGVector(dx: data.acceleration.x*10, dy: data.acceleration.y*10)
                        } else if (self.orientation == .portraitUpsideDown) {
                            self.physicsWorld.gravity = CGVector(dx: -data.acceleration.x*10, dy: -data.acceleration.y*10)
                        }
                    }
                }
            }
        }
            
    }
    
    // MARK: - Trees
    
    public func addTree(location: CGPoint) {
        
        PlaygroundPage.current.wantsFullScreenLiveView = true
        
        let width:CGFloat = 150.0
        let height:CGFloat = 112.5
        
        let rand = arc4random() % 3+1
        
        // Randomly choose a tree style
        let tree = SKSpriteNode(imageNamed: "Tree\(rand)")
        tree.position = location
        tree.size = CGSize(width: 1, height: 1)
        tree.zPosition = Layers.sprite
        tree.lightingBitMask = 0b0001
        addChild(tree)
        
        let grow = SKAction.scale(to: CGSize(width: width, height: height), duration: 0.3)
        tree.run(grow)
        
        let rise = SKAction.moveBy(x: 0, y: height/2, duration: 0.3)
        tree.run(rise)
        
        showMessage(message: "Those are some nice looking trees!")
    }
    
    // MARK: - Power
    
    private func addSun() {

        if sunEmitter != nil {
            return
        }
        
        sunEmitter = SKEmitterNode(fileNamed: "Sun")!
        sunEmitter!.zPosition = Layers.sunEmitter
        sunEmitter!.position = sunPosition
        addChild(sunEmitter!)
        
        showMessage(message: "You got the sun running, nice work!")
    }
    
    private func setupCamera() {
        
        // Search for the front camera
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        guard let frontCamera = discoverySession.devices.first else {
            // Handle missing front camera?
            return
        }
        
        // Create somewhere for the camera input be handled
        do {
            captureInput = try AVCaptureDeviceInput(device: frontCamera)
        } catch {
            // Handle error?
            return
        }
        
        // Open the camera session and add the camera input
        session = AVCaptureSession()
        guard let session = session else {
            // handle session not allowed
            return
        }
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        if session.canAddInput(captureInput) {
            session.addInput(captureInput)
        } else {
            // Handle error?
        }
        
        // Create somewhere to handle the video feed (this will be used to confirm the brightness)
        videoOutput = AVCaptureVideoDataOutput()
//        let videoQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        // Give the output back to the session handler
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        session.commitConfiguration()
    }
    
    private func startCamera() {
        guard let session = session else {
            // handle session not allowed
            return
        }
        session.startRunning()
        
        calculateBrightnessTimer = Timer(fire: Date(), interval: 1.5, repeats: true, block: { (timer) in
            let averageBrightness = self.totalBrightness / Float(self.brightnessCount)
            
            if self.calibratedBrightness == nil && averageBrightness > 0.0 {
                self.calibratedBrightness = averageBrightness
            } else if let calibratedBrightness = self.calibratedBrightness, averageBrightness > calibratedBrightness*1.2 {
                self.stopCamera()
                self.addSun()
            }
        })
        RunLoop.current.add(self.calculateBrightnessTimer!, forMode: .default)
    }
    
    private func stopCamera() {
        guard let session = session else {
            return
        }
        session.stopRunning()
        calculateBrightnessTimer?.invalidate()
    }
}

extension GameScene: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Read the captured output from the camera to detect a brightness level of the room.
    // I couldn't find a proper API for the ambient light sensor which should have been a better option...
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let metadataDict:CFDictionary = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)!
        let metadata = NSDictionary(dictionary: metadataDict)
        guard let exifMetadata = metadata[kCGImagePropertyExifDictionary] as? NSDictionary else {return}
        guard let brightnessNum = exifMetadata[kCGImagePropertyExifBrightnessValue] as? NSNumber else {return}
        
        brightness = brightnessNum.floatValue
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    // Handle various sprites hitting each other
    public func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == CategoryBitMask.Rubbish && contact.bodyB.categoryBitMask == CategoryBitMask.SeaBin {
            self.suckRubbish(contact.bodyA.node as! SKSpriteNode, intoBin: contact.bodyB.node as! SKSpriteNode)
        } else if contact.bodyA.categoryBitMask == CategoryBitMask.SeaBin && contact.bodyB.categoryBitMask == CategoryBitMask.Rubbish {
            self.suckRubbish(contact.bodyB.node as! SKSpriteNode, intoBin: contact.bodyA.node as! SKSpriteNode)
        } else if contact.bodyA.categoryBitMask == CategoryBitMask.Fish && contact.bodyB.categoryBitMask == CategoryBitMask.Rubbish {
            self.removeFish(contact.bodyA.node as! SKLabelNode)
        } else if contact.bodyA.categoryBitMask == CategoryBitMask.Rubbish && contact.bodyB.categoryBitMask == CategoryBitMask.Fish {
            self.removeFish(contact.bodyB.node as! SKLabelNode)
        }
    }
}
