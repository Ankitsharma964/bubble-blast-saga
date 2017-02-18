//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by Edmund Mok on 10/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class PhysicsEngine {
    
    var collisionHandler: CollisionHandler?
    
    // Update the state of all objects in the entire physics world.
    func updateState(for physicsBodies: [PhysicsBody]) {
        
        for physicsBody in physicsBodies {
            
            // Update the positions of all physics bodies
            let didUpdate = update(physicsBody)
            
            // If body did not update, can just continue
            guard didUpdate else {
                continue
            }
            
            // Otherwise if body did update, we need to check
            // for collisions
            checkCollisions(for: physicsBody, with: physicsBodies)
        }

    }
    
    private func update(_ physicsBody: PhysicsBody) -> Bool {
        // If no velocity, not moving so won't be updated
        guard physicsBody.velocity != CGVector.zero else {
            return false
        }
        
        // Update position according to velocity
        physicsBody.position.x += physicsBody.velocity.dx
        physicsBody.position.y += physicsBody.velocity.dy
        
        return true
    }
    
    // Checks if the given physics body is colliding with any other 
    // physics body in the current physics world.
    private func checkCollisions(for physicsBody: PhysicsBody, with physicsBodies: [PhysicsBody]) {
        
        // Check collision for given physics circle
        if let physicsCircle = physicsBody as? PhysicsCircle {
            checkCollisions(for: physicsCircle, with: physicsBodies)
            return
        }
        
        // Check collision for given physics box
        if let physicsBox = physicsBody as? PhysicsBox {
            checkCollisions(for: physicsBox, with: physicsBodies)
            return
        }
        
        // No collision detection is defined for any other PhysicsBody
        // types for now.
        return
    }

    // Checks if the given physics circle is colliding with any other
    // physics body in the current physics world.
    private func checkCollisions(for physicsCircle: PhysicsCircle, with physicsBodies: [PhysicsBody]) {
        
        for otherPhysicsBody in physicsBodies {
            
            // Check collision between circle and circle
            if let otherPhysicsCircle = otherPhysicsBody as? PhysicsCircle {
                checkCollisions(for: physicsCircle, with: otherPhysicsCircle)
            }
            
            // Check collision between circle and box
            if let otherPhysicsBox = otherPhysicsBody as? PhysicsBox {
                checkCollisions(for: physicsCircle, with: otherPhysicsBox)
            }
            
            // No collision detection is defined for any other PhysicsBody
            // types for now.
            continue
        }
    }
    
    // Checks if the given physics box is colliding with any other
    // physics body in the current physics world.
    private func checkCollisions(for physicsBox: PhysicsBox, with physicsBodies: [PhysicsBody]) {
        
        for otherPhysicsBody in physicsBodies {
            
            // Check collision between box and circle
            if let otherPhysicsCircle = otherPhysicsBody as? PhysicsCircle {
                checkCollisions(for: otherPhysicsCircle, with: physicsBox)
            }
            
            // Check collision between box and box
            if let otherPhysicsBox = otherPhysicsBody as? PhysicsBox {
                checkCollisions(for: physicsBox, with: otherPhysicsBox)
            }
            
            // No collision detection is defined for any other PhysicsBody
            // types for now.
            continue
        }
        
    }
    
    // Checks if the given physics circle and other physics circle are in collision.
    private func checkCollisions(for physicsCircle: PhysicsCircle, with otherPhysicsCircle: PhysicsCircle) {
        
        // Collision cannot be using the same object
        guard physicsCircle !== otherPhysicsCircle else {
            return
        }
        
        // Different circles
        // Collision detection algorithm for two circles:
        
        // Calculate difference between centres
        let distX = physicsCircle.center.x - otherPhysicsCircle.center.x
        let distY = physicsCircle.center.y - otherPhysicsCircle.center.y
        
        // Get distance with Pythagoras
        let dist = sqrt(Double((distX * distX)) + Double((distY * distY)))
        let radiusSum = Double(physicsCircle.radius) + Double(otherPhysicsCircle.radius)
        
        // The circles are colliding if the distance between their centers
        // is greater than the sum of their radii.
        let isColliding = (dist <= radiusSum)
        
        // If not colliding, just return
        guard isColliding else {
            return
        }
        
        // If is colliding, get someone to handle it.
        collisionHandler?.handleCollisionBetween(physicsCircle, and: otherPhysicsCircle)
    }
    
    // Checks if the given physics circle and other physics box are in collision.
    private func checkCollisions(for physicsCircle: PhysicsCircle, with otherPhysicsBox: PhysicsBox) {
        
        // Collision detection algorithm for circle and box (rectangle):
        
        
        
        // Finds closest point to the circle within the rectangle.
        // Assumes axis alignment.
        let closestX = clamp(val: physicsCircle.center.x, rangeMin: otherPhysicsBox.position.x,
            rangeMax: otherPhysicsBox.position.x + otherPhysicsBox.size.width)
        
        let closestY = clamp(val: physicsCircle.center.y, rangeMin: otherPhysicsBox.position.y,
            rangeMax: otherPhysicsBox.position.y + otherPhysicsBox.size.height)
    
        // Calculates the distance between the circle's center and this closest point
        let distanceX = physicsCircle.center.x - closestX
        let distanceY = physicsCircle.center.y - closestY
        
        let distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)
        
        // If the distance is less than the circle's radius, a collision occurs
        let isColliding = distanceSquared < (physicsCircle.radius * physicsCircle.radius)
        
        // If not colliding, just return
        guard isColliding else {
            return
        }
        
        // If is colliding, get someone to handle it.
        collisionHandler?.handleCollisionBetween(physicsCircle, and: otherPhysicsBox)
    }
    
    // Returns a limit for the value to the range min..max
    private func clamp(val: CGFloat, rangeMin: CGFloat, rangeMax: CGFloat) -> CGFloat {
        return max(rangeMin, min(rangeMax, val))
    }
    
    // Checks if the given physics box and other physics box are in collision.
    private func checkCollisions(for physicsBox: PhysicsBox, with otherPhysicsBox: PhysicsBox) {
        
        // Collision cannot be using the same object
        guard physicsBox !== otherPhysicsBox else {
            return
        }
        
        // Different boxes
        // Collision detection algorithm for two boxes:
        // Using AABB Collision Detection
        
        // Check for collision on x-axis
        let collisionX = (physicsBox.position.x + physicsBox.size.width >= otherPhysicsBox.position.x)
            && (otherPhysicsBox.position.x + otherPhysicsBox.size.width >= physicsBox.position.x)
        
        // Check for collision on y-axis
        let collisionY = (physicsBox.position.y + physicsBox.size.height >= otherPhysicsBox.position.y)
            && (otherPhysicsBox.position.y + otherPhysicsBox.size.height >= physicsBox.position.y)
        
        // Collision only if on both axes
        let isColliding = collisionX && collisionY
        
        // If not colliding, just return
        guard isColliding else {
            return
        }
        
        // If is colliding, get someone to handle it.
        collisionHandler?.handleCollisionBetween(physicsBox, and: otherPhysicsBox)
    }
}