//  SwiftSnake
//
//  Created by Sashin Pradhan on 12/3/17.
//  Copyright © 2017 Sashin Pradhan. All rights reserved.
//
import UIKit
import AudioToolbox
import AVFoundation

class ViewController: UIViewController, SnakeViewDelegate {
    @IBOutlet var startButton:UIButton?
    var snakeView:SnakeView?
    var timer:Timer?
    
    var snake:Snake?
    var fruit:Point?
    var player: AVAudioPlayer!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var fruitCount: UILabel!
    
    
    override func viewDidLoad() {   //load main view on startup
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        
        let height = self.view.frame.size.height
        let width = self.view.frame.size.width + 5
        
        let imageName = "Default1024x768.png/"  //call for background image
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        
        imageView.frame = self.view.frame
        
        self.view?.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        let snakeSize = Int((width - height) / 2)
        
        let snakeShape = CGRect(x: Int(snakeSize), y: Int(0), width: Int(height), height: Int(height))
        
        
        self.snakeView = SnakeView(frame: snakeShape)
        
        self.view.insertSubview(self.snakeView!, at: 0)  //bring the layers to front in order
        self.view.bringSubview(toFront: self.snakeView!)
        self.view.bringSubview(toFront: startButton!)
        self.view.bringSubview(toFront: gameOverLabel)
        
        if let view = self.snakeView {
            view.delegate = self
        }
        for direction in [UISwipeGestureRecognizerDirection.right,  //gestures for swipes on phone
                          UISwipeGestureRecognizerDirection.left,
                          UISwipeGestureRecognizerDirection.up,
                          UISwipeGestureRecognizerDirection.down] {
                            let swipeGest = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipe(_:)))
                            swipeGest.direction = direction
                            self.view.addGestureRecognizer(swipeGest)
        }
       playSound()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func swipe (_ swipeGest:UISwipeGestureRecognizer) {    //functions for swipe directions
        let direction = swipeGest.direction
        switch direction {
        case UISwipeGestureRecognizerDirection.right:
            if (self.snake?.changeDirection(Direction.right) != nil) {  //swipe directions right, lock direction
                self.snake?.lockDirection()
            }
        case UISwipeGestureRecognizerDirection.left:
            if (self.snake?.changeDirection(Direction.left) != nil) {      //swipe directions left, lock direction
                self.snake?.lockDirection()
            }
        case UISwipeGestureRecognizerDirection.up:
            if (self.snake?.changeDirection(Direction.up) != nil) { //swipe directions up, lock direction
                self.snake?.lockDirection()
            }
        case UISwipeGestureRecognizerDirection.down:
            if (self.snake?.changeDirection(Direction.down) != nil) {   //swipe directions down, lock direction
                self.snake?.lockDirection()
            }
        default:
            assert(false, "Can't happen")
        }
    }
    
    func makeNewFruit() {   //function to make new fruit when called
        srandomdev()    //create random number swift created function
        let worldSize = self.snake!.worldSize
        var x = 0, y = 0
        while (true) {
            x = Int(arc4random_uniform(UInt32(worldSize)))  //create random x
            y = Int(arc4random_uniform(UInt32(worldSize)))  //create random y
            var isBody = false  //cannot create fruit in snake body
            for p in self.snake!.points {
                if p.x == x && p.y == y {
                    isBody = true
                    break
                }
            }
            if !isBody {
                break
            }
        }
        self.fruit = Point(x: x, y: y)
    }
    
    func startGame() {  //function to start game
        gameOverLabel.isHidden = true   //game over label is hidden
        if self.timer != nil {
            return
        }
        
        self.startButton!.isHidden = true   //start button hidden when game starts
        let height = self.view.frame.size.height
        let worldSize = Int(height.truncatingRemainder(dividingBy: 110))
        self.snake = Snake(wSize: worldSize, length: 3)
        
        self.makeNewFruit() //call new fruit function
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.timerMethod(_:)), userInfo: nil, repeats: true)   //calls for timer function every 0.1 seconds
        self.snakeView!.setNeedsDisplay()
    }
    
    func endGame() {       //ends game, reset fuit count to zero, hide game over label and start button, and timer starts over
        fruitCount.text = "0"
        gameOverLabel.isHidden = false
        self.startButton!.isHidden = false
        self.timer!.invalidate()
        self.timer = nil
    }
    func playSound() {  //function to play sound
        let url = Bundle.main.url(forResource: "Bite", withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func timerMethod(_ timer:Timer) {  //timer, checks everything, if head hit body, or head hit fruit
        self.snake?.move()
        let headHitBody = self.snake?.isHeadHitBody()
        if headHitBody == true {
            let systemSoundId: SystemSoundID = 1322
            AudioServicesPlaySystemSound(systemSoundId)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.endGame()
            return
        }
        
        let head = self.snake?.points[0]
        if head?.x == self.fruit?.x &&
            head?.y == self.fruit?.y {
            player.play()
            self.snake!.increaseLength(2)
            fruitCount.text = String(Int(fruitCount.text ?? "0")! + 1)
            self.makeNewFruit()
        }
        
        self.snake?.unlockDirection()
        self.snakeView!.setNeedsDisplay()
    }
    
    @IBAction func start(_ sender:AnyObject) {
        self.startGame()
    }
    
    func snakeForSnakeView(_ view:SnakeView) -> Snake? {
        
        return self.snake
    }
    func pointOfFruitForSnakeView(_ view:SnakeView) -> Point? {
        return self.fruit
    }
}
