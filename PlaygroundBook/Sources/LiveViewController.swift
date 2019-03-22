//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  An auxiliary source file which is part of the book-level auxiliary sources.
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport
import SpriteKit

@objc(Book_Sources_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    public var scene:GameScene!
    var skView:SKView!
    public var airQuality: AirQuality!
    public var waterQuality: WaterQuality!
    
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
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        let scene = GameScene(size: view.frame.size)
//        scene.scaleMode = .aspectFill
//        skView = self.view as? SKView
//        skView.presentScene(scene)
        
        /// NOTE: this deprecated item must be used for interface orientation due to a playground bug with device orientation
//        self.interfaceOrientation
    }
    
    public override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        updateSceneOrientation(orientation: toInterfaceOrientation)
    }
    
    public func setupWith(_ airQuality: String, waterQuality: String) {
        
        scene = GameScene(size: view.frame.size)
        scene.scaleMode = .aspectFill
        skView = self.view as? SKView
        skView.presentScene(scene)
        
        updateSceneOrientation(orientation: interfaceOrientation)
    }
    
    public func enableBlank() {
        scene.setupDirtyCity()
    }
    
    public func enableSolarPanels() {
        scene.setupDirtyCity()
        scene.setupSolarPower()
    }
    
    public func enableTrees() {
        scene.setupDirtyCity()
        scene.setupTrees()
    }
    
    public func enableRiver() {
        scene.setupRiver()
    }
    
    func updateSceneOrientation(orientation: UIInterfaceOrientation) {
        print("new orientation: \(orientation.rawValue)")
        scene.orientation = orientation
    }
}
