//#-hidden-code

import UIKit
import PlaygroundSupport

class Listener: PlaygroundRemoteLiveViewProxyDelegate {
    
    public func addTree(x: Int, y: Int) {
        guard let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else { return }
        let value = PlaygroundValue.dictionary(["type": .string("treeCoordinate"), "x": .integer(x), "y": .integer(y)])
        proxy.send(value)
    }
    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {}
    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) { }
}

let listener = Listener()
if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.delegate = listener
}

func addTree(x: Int, y: Int) {
    listener.addTree(x: x, y: y)
}

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, addTree(x:y:))
/*:
 # Step 1: Planting Trees
 
 Let's start by planting new trees to replace those which have been cut down.
 
 * Callout(**Did You Know**):
 Forests help clean our water, filter our air, and also provide food, medicine, and fuel when needed! Plant one in your backyard to make your difference.
 
 # 🌳 🌳 🌳
 
 ## Instructions
 
 1. Enter coordinates of trees to be planted using the `addTree` method below
 2. Tap "Run My Code" to begin planting trees
 */

// For example:
addTree(x: 500, y: 250)
// Use loops to add multiple trees
for i in 0..<5 {
    addTree(x: 500 + i*50, y: 350)
}
// Add more trees below
