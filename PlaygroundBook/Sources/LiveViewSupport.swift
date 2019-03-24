//
//  LiveViewSupport.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import UIKit
import PlaygroundSupport

var currentLiveViewController: LiveViewController = instantiateLiveView()

/// Instantiates a new instance of a live view.
///
/// By default, this loads an instance of `LiveViewController` from `LiveView.storyboard`.
func instantiateLiveView() -> LiveViewController {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

    guard let viewController = storyboard.instantiateInitialViewController() else {
        fatalError("LiveView.storyboard does not have an initial scene; please set one or update this function")
    }

    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("LiveView.storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }
    liveViewController.setupScene()
    
    return liveViewController
}

public var sharedLiveVC: LiveViewController {
    get {
        return currentLiveViewController
    }    
}
