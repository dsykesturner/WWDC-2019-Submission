//
//  GameScene.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    // Sun
//    var sunTimer:Timer?
    var addingSolarPannels:Bool = false
    var solarPanel:SKSpriteNode!
    var solarPanelCopies:[SKSpriteNode] = []
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
    
    override func didMove(to view: SKView) {
        addBackground()
        addFumes()
        addSun()
        
        setupSolarPower()
        setupCamera()
        startCamera()
    }
    
    // MARK: - Scene Setup
    
    func addBackground() {
        let backdrop = SKSpriteNode(imageNamed: "Hills+City")        
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backdrop.zPosition = Layers.background
        addChild(backdrop)
        
//        let screenFilter = SKSpriteNode(color: UIColor.black, size: backdrop.size)
//        screenFilter.position = backdrop.position
//        screenFilter.alpha = 0.8
//        backdrop.zPosition = Layers.filter
//        addChild(screenFilter)
        
        scene?.backgroundColor = UIColor.init(red: 188.0/255.0, green: 201.0/255.0, blue: 224.0/255.0, alpha: 1)
    }
    
    func addSun() {
        // Idea: Only show this once the ipad has been exposed to light
        let sunEmitter = SKEmitterNode(fileNamed: "Sun")!
        sunEmitter.zPosition = Layers.emitter
        sunEmitter.position = CGPoint(x: view!.frame.size.width / 11*3, y: view!.frame.size.height)
        sunEmitter.advanceSimulationTime(30)
        addChild(sunEmitter)
        
//        sunTimer = Timer(fire: Date(), interval: 30, repeats: true, block: { (timer) in
//
//
//            let endPoint = CGPoint(x: self.view!.frame.size.width, y: self.view!.frame.size.height)
//            let action = SKAction.move(to: endPoint, duration: 120)
//            sunEmitter.run(action)
//        })
    }
    
//    func addGem() {
//        addChild(gem)
//        gem.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
//        gem.zPosition = Layers.gem
//        gem.setScale(2.5)
//    }
    
    
    func addFumes() {
        let fumesEmitter = SKEmitterNode(fileNamed: "Fumes")!
        fumesEmitter.zPosition = Layers.emitter
        fumesEmitter.position = CGPoint(x: view!.frame.size.width / 2, y: 0)
        fumesEmitter.advanceSimulationTime(30)
        addChild(fumesEmitter)
    }
    
    // MARK: - Interaction Handler
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if addingSolarPannels {
            addSolarPanel(location: touchLocation)
        }
        
        
        
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
    
    // MARK: - Solar Power
    
    func setupSolarPower() {
        solarPanel = SKSpriteNode(imageNamed: "SolarPanel-Off")
        solarPanel.size = CGSize(width: 100, height: 100)
        solarPanel.zPosition = Layers.sprite
        
        addingSolarPannels = true
    }
    
    func addSolarPanel(location: CGPoint) {
        
        let newSolarPanel = solarPanel.copy() as! SKSpriteNode
        newSolarPanel.position = location
        addChild(newSolarPanel)
        
        solarPanelCopies.append(newSolarPanel)
    }
    
    func turnOnSolarPanels() {
        
        for solarPanel in solarPanelCopies {
            solarPanel.texture = SKTexture(imageNamed: "SolarPanel-On")
        }
        
        // Rebuild new panels as 'on'
        solarPanel = SKSpriteNode(imageNamed: "SolarPanel-On")
        solarPanel.size = CGSize(width: 100, height: 100)
        solarPanel.zPosition = Layers.sprite
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
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
}

// TODO: put this in the VC?
extension GameScene: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let metadataDict:CFDictionary = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)!
        let metadata = NSDictionary(dictionary: metadataDict)
        guard let exifMetadata = metadata[kCGImagePropertyExifDictionary] as? NSDictionary else {return}
        guard let brightnessNum = exifMetadata[kCGImagePropertyExifBrightnessValue] as? NSNumber else {return}
        
        brightness = brightnessNum.floatValue
    }
}
