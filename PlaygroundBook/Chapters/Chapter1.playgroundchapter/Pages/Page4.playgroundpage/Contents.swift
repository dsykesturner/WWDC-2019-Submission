//#-code-completion(everything, hide)
//#-hidden-code

import UIKit
import PlaygroundSupport

class Listener: PlaygroundRemoteLiveViewProxyDelegate {
    
    public func startGame() {
        guard let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else { return }
        let value = PlaygroundValue.dictionary(["type": .string("startGame")])
        proxy.send(value)
    }
    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {}
    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) { }
}

let listener = Listener()
if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.delegate = listener
}
listener.startGame()

//#-end-hidden-code
/*:
 # Step 3: Sea Bins
 
 Lastly, let's make sure that any plactic that reaches the water doesn't end up floating out to the ocean.
 
 Sea bins clean up plastics and other harmful waste from the water. Surrounding waste flows into the bin while water is pumped out the bottom trapping any waste in a filter.
 
 * Callout(**Did You Know**):
 Almost 9 million tons of plastic end up in the ocean every year. Estimates state that 90% of all sea birds have already eaten some kind of plastic.
 
 # 🚮 ❤️ 🐢
 
 ## Instructions
 
 - Note:
 Turn on rotate-lock here to avoid your screen from rotating when tilting your device
 
 1. Tap "Run My Code" to start cleaning
 2. Tilt your device to move the waste into the sea bins provided
 */
