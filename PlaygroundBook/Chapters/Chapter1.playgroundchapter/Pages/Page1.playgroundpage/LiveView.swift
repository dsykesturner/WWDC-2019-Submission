//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import PlaygroundSupport

// Instantiate a new instance of the live view from the book's auxiliary sources and pass it to PlaygroundSupport.
let initialView = sharedLiveVC as! LiveViewController

initialView.setupWith(AirQuality.low, waterQuality: WaterQuality.low)

//initialView.showMessage(title: "t 1", message: "m 1") {
//    initialView.showMessage(title: "t 2", message: "m 2") {
//
//    }
//}

PlaygroundPage.current.liveView = initialView
