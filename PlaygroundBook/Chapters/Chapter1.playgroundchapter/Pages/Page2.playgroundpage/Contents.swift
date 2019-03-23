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
//#-code-completion(description, show, "addTree(x: /*#-editable-code*/<#T##x coordinate##Int#>/*#-end-editable-code*/, y: /*#-editable-code*/<#T##y coordinate##Int#>/*#-end-editable-code*/)")
/*:
 # Phase 1: Planting Trees
 
 First let's start by planting new trees.
 
 **Did you know:** Forests help clean our water, filter our air, and also provide food, medicine, and fuel when needed! Plant one in your backyard to make your difference.
 
 # 🌳 🌳 🌳
 
 ## Instructions
 
 1. Enter coordinates of trees to be planted using the `addTree` method below
 2. Tap "Run My Code" to begin planting trees
 */

addTree(x: 500, y: 250)
