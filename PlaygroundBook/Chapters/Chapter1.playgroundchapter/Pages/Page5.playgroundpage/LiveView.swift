//
//  LiveView.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import UIKit
import PlaygroundSupport

// Instantiate a new instance of the live view from the book's auxiliary sources and pass it to PlaygroundSupport.
let initialView = sharedLiveVC as! LiveViewController
initialView.setupForCleanCity()
PlaygroundPage.current.liveView = initialView
