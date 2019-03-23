//
//  GameScene.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import SpriteKit
import AVFoundation
import CoreMotion

public class GameScene: SKScene {
    
    public var orientation: UIInterfaceOrientation!
    // Sun
    var isSunOn:Bool = false
    var addingSolarPannels:Bool = false
    var addingTrees:Bool = false 
    var solarPanels:[SKSpriteNode] = []
    // Camera
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
    var prevAveBrightness: Float = 0.0
    var prevAveBrightness2: Float = 0.0
    var calculateBrightnessTimer: Timer?
    // River
    let motion = CMMotionManager()
    var seaBins:[SKSpriteNode] = []
    var rubbish:[SKSpriteNode] = []
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    public override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        motion.stopAccelerometerUpdates()
    }
    
    // MARK: - Interaction Handler
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if addingSolarPannels {
            addSolarPanel(location: touchLocation)
        } else if addingTrees {
            addTree(location: touchLocation)
        }
    }
    
    // MARK: - Scene Setup
    
    public func setupDirtyCity() {
        
        addDirtyBackground()
        addFumes()
    }
    
    func addDirtyBackground() {
        let backdrop = SKSpriteNode(imageNamed: "Hills+City")        
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.zPosition = Layers.background
        addChild(backdrop)
        
        scene?.backgroundColor = UIColor.init(red: 188.0/255.0, green: 201.0/255.0, blue: 224.0/255.0, alpha: 1)
    }
    
    func addCleanBackground() {
        
    }
    
    func addRiverBackground() {
        
        let rippleEmitter = SKEmitterNode(fileNamed: "WaterRipples")!
        rippleEmitter.zPosition = Layers.emitter
        rippleEmitter.position = CGPoint(x: 0, y: view!.frame.size.height / 2)
        rippleEmitter.advanceSimulationTime(30)
        addChild(rippleEmitter)
        
        scene?.backgroundColor = UIColor.init(red: 0/255.0, green: 141.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    func addFumes() {
        let fumesEmitter = SKEmitterNode(fileNamed: "Fumes")!
        fumesEmitter.zPosition = Layers.emitter
        fumesEmitter.position = CGPoint(x: view!.frame.size.width / 2, y: 0)
        fumesEmitter.advanceSimulationTime(30)
        addChild(fumesEmitter)
    }
    
    // MARK: - River
    
    public func setupRiver() {
    
        addRiverBackground()
        addSeaBins()
        addRubbish()
        setupRiverPhysics()
        setupAccelerometer()
    }
   
    func addSeaBins() {
        
        let size = CGSize(width: 100, height: 100)
        let positions = [CGPoint(x: view!.frame.size.width/3, y: view!.frame.size.height/3*2),
                         CGPoint(x: view!.frame.size.width/3*2, y: view!.frame.size.height/3)]
        
        for position in positions {
            let seaBin = SKSpriteNode(imageNamed: "SeaBin3")
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
    
    func addRubbish() {
        
        let size = CGSize(width: 50, height: 50)
        let positions = [CGPoint(x: view!.frame.size.width/4, y: view!.frame.size.height/4),
                         CGPoint(x: view!.frame.size.width/4*2, y: view!.frame.size.height/4*2),
                         CGPoint(x: view!.frame.size.width/4*3, y: view!.frame.size.height/4*3),
                         CGPoint(x: view!.frame.size.width/4, y: view!.frame.size.height/4*2),
                         CGPoint(x: view!.frame.size.width/4*2, y: view!.frame.size.height/4),
                         CGPoint(x: view!.frame.size.width/4*3, y: view!.frame.size.height/4),
                         CGPoint(x: view!.frame.size.width/4, y: view!.frame.size.height/4*3),
                         CGPoint(x: view!.frame.size.width/4*2, y: view!.frame.size.height/4*3),
                         CGPoint(x: view!.frame.size.width/4*3, y: view!.frame.size.height/4*2)]
        
        for position in positions {
            let rubbishPiece = SKSpriteNode(imageNamed: "Rubbish")
            rubbishPiece.position = position
            rubbishPiece.size = size
            rubbishPiece.zPosition = Layers.sprite
            rubbishPiece.zRotation = CGFloat.pi / CGFloat(arc4random() % 4 + 1)
//            rubbishPiece.run(.repeatForever(.rotate(byAngle: CGFloat(Double.pi), duration: 4)))
            
            rubbishPiece.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
            rubbishPiece.physicsBody?.allowsRotation = true
            rubbishPiece.physicsBody?.categoryBitMask = CategoryBitMask.Rubbish
            rubbishPiece.physicsBody?.contactTestBitMask = CategoryBitMask.SeaBin
            rubbishPiece.physicsBody?.friction = 0.2
            rubbishPiece.physicsBody?.linearDamping = 0.2
            rubbishPiece.physicsBody?.restitution = 0.2
            
            addChild(rubbishPiece)
            
            rubbish.append(rubbishPiece)
        }
    }
    
    func suckRubbish(_ rubbish: SKSpriteNode, intoBin bin: SKSpriteNode) {
        
//        rubbish.physicsBody?.affectedByGravity = false
        rubbish.physicsBody = nil
        
        let moveAction = SKAction.move(to: bin.position, duration: 0.5)
        let sizeAction = SKAction.scaleX(to: 0, y: 0, duration: 0.5)
        
        rubbish.run(moveAction)
        rubbish.run(sizeAction) {
            rubbish.removeFromParent()
        }
    }
    
    func setupRiverPhysics() {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // Create an invisible barrier around the scene to keep the ball inside
        let sceneBound = SKPhysicsBody(edgeLoopFrom: frame)
        sceneBound.friction = 0
        sceneBound.restitution = 0.2
        physicsBody = sceneBound
    }
    
    func setupAccelerometer() {
        
        motion.accelerometerUpdateInterval = 1.0/60.0
        let queue = OperationQueue()
        motion.startAccelerometerUpdates(to: queue) { (data, error) in
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
    
    // MARK: - Trees
    
    public func setupTrees() {
        addingTrees = true
        addingSolarPannels = false
    }
    
    func addTree(location: CGPoint) {
        
        let tree = SKSpriteNode(imageNamed: "Tree")
        tree.position = location
        tree.size = CGSize(width: 60, height: 50)
        tree.zPosition = Layers.sprite
        addChild(tree)
    }
    
    // MARK: - Solar Power
    
    public func setupSolarPower() {
        addingSolarPannels = true
        addingTrees = false
        
        setupCamera()
        startCamera()
    }
    
    func addSolarPanel(location: CGPoint) {
        
        let solarPanel = isSunOn ? SKSpriteNode(imageNamed: "SolarPanel-On") : SKSpriteNode(imageNamed: "SolarPanel-Off")
        solarPanel.position = location
        solarPanel.size = CGSize(width: 50, height: 50)
        solarPanel.zPosition = Layers.sprite
        addChild(solarPanel)
        
        solarPanels.append(solarPanel)
    }
    
    func turnOnSolarPanels() {
        
        turnOnSun()
        
        for solarPanel in solarPanels {
            solarPanel.texture = SKTexture(imageNamed: "SolarPanel-On")
        }
    }
    
    func turnOnSun() {

        let sunEmitter = SKEmitterNode(fileNamed: "Sun")!
        sunEmitter.zPosition = Layers.emitter
        sunEmitter.position = CGPoint(x: view!.frame.size.width / 3, y: view!.frame.size.height-100)
//        sunEmitter.advanceSimulationTime(
        addChild(sunEmitter)
    }
    
    func setupCamera() {
        
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
    
    func startCamera() {
        guard let session = session else {
            // handle session not allowed
            return
        }
        session.startRunning()
        
        calculateBrightnessTimer = Timer(fire: Date(), interval: 1.5, repeats: true, block: { (timer) in
            let averageBrightness = self.totalBrightness / Float(self.brightnessCount)
            print(averageBrightness)
            
            if averageBrightness > 0 && averageBrightness > self.prevAveBrightness*1.3 && self.prevAveBrightness != 0 {
                print("triggered! A")
                self.stopCamera()
                self.turnOnSolarPanels()
            }
            else if averageBrightness > 0 && averageBrightness > self.prevAveBrightness2*1.1 && averageBrightness > self.prevAveBrightness*1.1 && self.prevAveBrightness2 != 0 {
                print("triggered! B")
                self.stopCamera()
                self.turnOnSolarPanels()
            }
            
            self.prevAveBrightness2 = self.prevAveBrightness
            self.prevAveBrightness = averageBrightness
            self.totalBrightness = 0
            self.brightnessCount = 0
        })
        RunLoop.current.add(self.calculateBrightnessTimer!, forMode: .default)
    }
    
    func stopCamera() {
        guard let session = session else {
            // handle session not allowed
            return
        }
        session.stopRunning()
        calculateBrightnessTimer?.invalidate()
    }
}

extension GameScene: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let metadataDict:CFDictionary = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)!
        let metadata = NSDictionary(dictionary: metadataDict)
        guard let exifMetadata = metadata[kCGImagePropertyExifDictionary] as? NSDictionary else {return}
        guard let brightnessNum = exifMetadata[kCGImagePropertyExifBrightnessValue] as? NSNumber else {return}
        
        brightness = brightnessNum.floatValue
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == CategoryBitMask.Rubbish && contact.bodyB.categoryBitMask == CategoryBitMask.SeaBin {
            self.suckRubbish(contact.bodyA.node as! SKSpriteNode, intoBin: contact.bodyB.node as! SKSpriteNode)
        } else if contact.bodyA.categoryBitMask == CategoryBitMask.SeaBin && contact.bodyB.categoryBitMask == CategoryBitMask.Rubbish {
            self.suckRubbish(contact.bodyB.node as! SKSpriteNode, intoBin: contact.bodyA.node as! SKSpriteNode)
        }
    }
}
