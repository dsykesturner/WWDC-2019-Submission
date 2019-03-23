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
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    var messageTappedBlock: (() -> Void)?
    
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
        
        if case .dictionary(let dict) = message {
            
            guard let type_val = dict["type"] else { return }
            guard case .string(let type) = type_val else { return }
            
            
            if type == "treeCoordinates" {
                guard let x_val = dict["x"] else { return }
                guard let y_val = dict["y"] else { return }
                
                if case (.integer(let x), .integer(let y)) = (x_val, y_val) {
                    addTree(x: x, y: y)
                }
            } else if type == "powerSource" {
                guard let powerSource_val = dict["powerSource"] else { return }
                guard case .integer(let powerSource) = powerSource_val else { return }
                
                updatePowerSource(PowerSource(rawValue: powerSource)!)
            }
        }
    }
    
    
    
    public override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        print("new orientation: \(toInterfaceOrientation.rawValue)")
        scene.orientation = toInterfaceOrientation
    }
    
    
    public func setupWith(_ airQuality: String, waterQuality: String) {
        
        scene = GameScene(size: view.frame.size)
        scene.scaleMode = .aspectFill
        skView = self.view as? SKView
        skView.presentScene(scene)
        
        // NOTE: Deprecated usage here as I had troubles with the current implementation from UIDevice
        print("new orientation: \(interfaceOrientation.rawValue)")
        scene.orientation = interfaceOrientation
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
    
    public func showMessage(title: String, message: String, tapped: @escaping () -> Void) {
        
        titleLabel.text = title
        messageLabel.text = message
        messageView.isHidden = false
        
        messageTappedBlock = tapped
    }
    
    func addTree(x: Int, y: Int) {
        
        scene.addTree(location: CGPoint(x: x, y: y))
    }
    
    func updatePowerSource(_ powerSource: PowerSource) {
        
        if powerSource == PowerSource.coal {
            
        } else if powerSource == PowerSource.solarPower {
            scene.addSolarPanel(location: CGPoint(x: scene.size.width/2, y: scene.size.height/2))
        }
    }
}
