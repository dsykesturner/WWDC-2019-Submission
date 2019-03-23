//#-hidden-code

import UIKit
import PlaygroundSupport

class Listener: PlaygroundRemoteLiveViewProxyDelegate {
    
    public func updatePowerSource(_ powerSource: PowerSource) {
        guard let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else { return }
        let value = PlaygroundValue.dictionary(["type": .string("powerSource"), "powerSource": .integer(powerSource.rawValue)])
        proxy.send(value)
    }
    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {}
    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) { }
}

let listener = Listener()
if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.delegate = listener
}

struct City {
    var powerSource: PowerSource? {
        didSet {
            if let powerSource = powerSource {
                listener.updatePowerSource(powerSource)
            }
        }
    }
}

var city = City()

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, city, powerSource, PowerSource, coal, solarPower)
/*:
 # Phase 2: Solar Panels
 
 The city needs power, so let's setup solar panels to use the sun's energy to our advantage.
 
  * Callout(**Did You Know**):
    If the entire world switched to renewable eneregy by 2050, $600 billion would be saved every year in health care costs due to the elimination of risks associated with non-renewable sources. What would you do with that money?
 
 # ☀️ ⚡️ 💡
 
 ## Instructions
 
 - Note:
 This will use the camera to detect light sensitivity. Please tap "OK" when prompted.
 
 1. Change the city's power source from `.coal` to `.solarPower`
 2. Tap "Run My Code" to build the solar panels
 3. Place your device near a light source to power the city
 */

city.powerSource = PowerSource.coal
