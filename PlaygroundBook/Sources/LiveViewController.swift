//
//  LiveViewController.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import UIKit
import PlaygroundSupport
import SpriteKit
import AVFoundation

@objc(Book_Sources_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    public var scene:GameScene!
    var skView:SKView!
    public var airQuality: AirQuality!
    public var waterQuality: WaterQuality!
    
    var player: AVAudioPlayer?
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playBackgroundMusic()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        
        stopBackgroundMusic()
    }
    
    public override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // The orientation must be updated for the accelerometer readings to be correct
        scene.orientation = toInterfaceOrientation
    }
    
    // MARK: Scene setup functions
    
    public func setupScene() {
        
        // Setup the basic scene. This won't have any UI elements until we add them using the functions below
        scene = GameScene(size: view.frame.size)
        scene.scaleMode = .aspectFill
        skView = self.view as? SKView
        skView.presentScene(scene)
        
        // NOTE: Deprecated usage here as I had troubles with the current implementation from UIDevice
        scene.orientation = interfaceOrientation
        
        PlaygroundPage.current.wantsFullScreenLiveView = false
    }
    
    // MARK: Scene configurations
    
    public func setupForDirtyCity() {
        scene.setupDirtyCity()
    }
    
    public func setupForCleanCity() {
        scene.setupCleanCity()
    }
    
    public func setupForSolarPower() {
        scene.setupCoalHill()
    }
    
    public func setupForTrees() {
        scene.setupTreeHill()
    }
    
    public func setupForRiver() {
        scene.setupRiver()
    }
    
    // MARK: Functions to be called from the code editor (LiveView.swift)
    
    func addTree(x: Int, y: Int) {
        scene.addTree(location: CGPoint(x: x, y: y))
    }
    
    public func updatePowerSource(_ powerSource: PowerSource) {
        if powerSource == PowerSource.coal {
            scene.setupCoalHill()
        } else if powerSource == PowerSource.solarPower {
            scene.setupSolarPowerHill()
        }
    }
    
    public func startGame() {
        scene.startRiverGame()
    }
    
    // MARK: Background audio functions
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "DripDropTrack", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            player?.numberOfLoops = -1
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopBackgroundMusic() {
        player?.stop()
    }
}

extension LiveViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened() {
        // Implement this method to be notified when the live view message connection is opened.
        // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    }
    
    public func liveViewMessageConnectionClosed() {
        // Implement this method to be notified when the live view message connection is closed.
        // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
        // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    }
    
    public func receive(_ message: PlaygroundValue) {
        
        // Interpret where the type of message and call the correct function
        if case .dictionary(let dict) = message {
            
            guard let type_val = dict["type"] else { return }
            guard case .string(let type) = type_val else { return }
            
            
            if type == "treeCoordinate" {
                guard let x_val = dict["x"] else { return }
                guard let y_val = dict["y"] else { return }
                
                if case (.integer(let x), .integer(let y)) = (x_val, y_val) {
                    addTree(x: x, y: y)
                }
            } else if type == "powerSource" {
                guard let powerSource_val = dict["powerSource"] else { return }
                guard case .integer(let powerSource) = powerSource_val else { return }
                
                updatePowerSource(PowerSource(rawValue: powerSource)!)
            } else if type == "startGame" {
                startGame()
            }
        }
    }
}
