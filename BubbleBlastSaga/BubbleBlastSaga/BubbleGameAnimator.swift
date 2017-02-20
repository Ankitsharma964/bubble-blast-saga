//
//  BubbleGameAnimator.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 19/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class BubbleGameAnimator {
    
    private let gameArea: UIView
    private let renderer: Renderer
    private let bubbleGrid: UICollectionView
    
    init(gameArea: UIView, renderer: Renderer, bubbleGrid: UICollectionView) {
        self.gameArea = gameArea
        self.renderer = renderer
        self.bubbleGrid = bubbleGrid
    }
    
    func dropBubble(_ gameBubble: GameBubble) {
        // Check that there is an image for animation
        guard let bubbleImage = renderer.getImage(for: gameBubble) else {
            return
        }
        
        let bottomOfScreen = gameArea.frame.maxY
        
        // Calculate the final position after the drop
        let finalDropPosition = bottomOfScreen +
            (bubbleImage.frame.size.height * Constants.dropDistanceMultiplier)
        
        // Calculate the distance to drop by
        let distanceToDrop = finalDropPosition - bubbleImage.center.y
        
        // Compute drop duration
        let distanceToBottom = gameArea.frame.maxY - gameBubble.center.y
        let dropDuration = Double(distanceToBottom) * Constants.dropDurationMultiplier
        
        // Run the animation
        UIView.animate(withDuration: dropDuration, animations: {
            let initialFrame = bubbleImage.frame
            let finalFrame = initialFrame.offsetBy(dx: Constants.dropHorizontalOffset,
                dy: distanceToDrop)
            bubbleImage.frame = finalFrame
        }, completion: { _ in
            self.renderer.deregisterImage(for: gameBubble)
        })
    }
    
    func popBubble(_ gameBubble: GameBubble) {
        // Check that there is an image for animation
        guard let bubbleImage = renderer.getImage(for: gameBubble) else {
            return
        }
        
        bubbleImage.animationImages = Constants.bubbleBurstAnimationImages
        bubbleImage.animationDuration = Constants.popDuration
        bubbleImage.animationRepeatCount = Constants.popRepeatCount
        bubbleImage.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: Constants.popRemovalTime, repeats: false, block: { _ in
            self.renderer.deregisterImage(for: gameBubble)
        })
    }
    
    func flashHintLocations(_ indexPath: IndexPath) {
        
        guard indexPath != IndexPath() else {
            return
        }
        
        guard let cell = bubbleGrid.cellForItem(at: indexPath) else {
            return
        }
        
        UIView.animate(withDuration: 1.0, animations: {
            cell.backgroundColor = UIColor.yellow
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, animations: {
                cell.backgroundColor = UIColor.clear
            })
        })

    }
    
}
