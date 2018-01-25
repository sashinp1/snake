//  SwiftSnake
//
//  Created by Sashin Pradhan on 12/3/17.
//  Copyright © 2017 Sashin Pradhan. All rights reserved.

import Foundation

typealias WorldSize = Int

struct Point {
    var x:Int
    var y:Int
}

enum Direction: Int {
    case left
    case right
    case up
    case down
    
    func canChangeTo(_ newDirection:Direction) -> Bool {
        var canChange = false   //direction cannot change unless swipe gesture is correct
        switch self {
        case .left, .right:
            canChange = newDirection == .up || newDirection == .down    //if left, right, new direction cannot be up or down
        case .up, .down:
            canChange = newDirection == .left || newDirection == .right     //if up, down gesture, new direction cannot be left or right
        }
        return canChange
    }
    
    func move(_ point:Point, worldSize:WorldSize) -> (Point) {    //new point location on the screen
        var theX = point.x
        var theY = point.y
        switch self {
        case .left:
            theX -= 1
            if theX < 0 {
                theX = worldSize - 1
            }
        case .up:
            theY -= 1
            if theY < 0 {
                theY = worldSize - 1
            }
        case .right:
            theX += 1
            if theX > worldSize {
                theX = 0
            }
        case .down:
            theY += 1
            if theY > worldSize {
                theY = 0
            }
        }
        return Point(x: theX, y: theY)  //return the point in the world
    }
}

class Snake {
    var worldSize : WorldSize
    var length:Int = 0
    var points:Array<Point> = []
    var direction:Direction = .left
    var directionLocked:Bool = false
    
    init(wSize:WorldSize, length wLength:Int) {
        self.worldSize = wSize
        self.length = wLength
        
        let x:Int = self.worldSize / 2
        let y:Int = self.worldSize / 2
        for i in 0...wLength {
            let p:Point = Point(x:x + i, y: y)
            self.points.append(p)
        }
    }
    
    func move() {
        self.points.removeLast()
        let head = self.direction.move(points[0], worldSize: self.worldSize)    //when the head of snake hits the point, the point moves
        self.points.insert(head, at: 0)
    }
    
    func changeDirection(_ newDirection:Direction) {
        if self.directionLocked {
            return
        }
        if self.direction.canChangeTo(newDirection) {
            self.direction = newDirection
        }
    }
    
    func increaseLength(_ inLength:Int) {   //when snake hits point, snake increases in length
        let lastPoint:Point = self.points[self.points.count-1]
        let theOneBeforeLastPoint:Point = self.points[self.points.count-2]
        var x = lastPoint.x - theOneBeforeLastPoint.x
        var y = lastPoint.y - theOneBeforeLastPoint.y
        if lastPoint.x == 0 &&
            theOneBeforeLastPoint.x == self.worldSize - 1	{
            x = 1
        }
        if (lastPoint.x == self.worldSize - 1 && theOneBeforeLastPoint.x == 0) {
            x = -1
        }
        if (lastPoint.y == 0 && theOneBeforeLastPoint.y == worldSize - 1) {
            y = 1
        }
        if (lastPoint.y == worldSize - 1 && theOneBeforeLastPoint.y == 0) {
            y = -1
        }
        for i in 0..<inLength {
            let theX:Int = (lastPoint.x + x * (i + 1)) % worldSize
            let theY:Int = (lastPoint.y + y * (i + 1)) % worldSize
            self.points.append(Point(x:theX, y:theY))
        }
    }
    
    func isHeadHitBody() -> Bool {  //if head hits body "true" otherwise false
        let headPoint = self.points[0]
        for bodyPoint in self.points[1..<self.points.count] {
            if (bodyPoint.x == headPoint.x &&
                bodyPoint.y == headPoint.y) {
                return true
            }
        }
        return false
    }
    
    func lockDirection() { //direction is locked
        self.directionLocked = true
    }
    
    func unlockDirection() { //direction is not locked
        self.directionLocked = false
    }
}
