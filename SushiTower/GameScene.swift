//
//  GameScene.swift
//  SushiTower
//
//  Created by Parrot on 2019-02-14.
//  Copyright © 2019 Parrot. All rights reserved.
//

import SpriteKit
import GameplayKit
import WatchConnectivity

class GameScene: SKScene, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        DispatchQueue.main.async {
            if (message.keys.contains("moveDirection")){
                print("Move command recieved from Watch")
                //set move direction to left/right based on message recieved and call function
                self.moveDirection = message["moveDirection"] as! String
                self.moveCat()
            }
            
            
            
            if (message.keys.contains("moreTimeReply")){
                //phone accepted more time powerup
                if (self.SecondsRemaining <= 15) {
                    // add 10 seconds to Time remaining
                    self.SecondsRemaining = self.SecondsRemaining + 10
                    //update timeBar width and position
                    self.timeBar.size.width = self.timeBar.size.width + 100
                    self.timeBar.position.x = self.timeBar.position.x + 50
                }
                else {
                    // increase seconds remaining to 25
                    self.SecondsRemaining = 25
                    //update timeBar width and position
                    self.timeBar.size.width = 250
                    self.timeBar.position.x = self.size.width/2
                }
             
            }
            if (message.keys.contains("pause")){
                //Pause the Game as per Watch Command
                self.secondsRemainingLabel.text = "GAME PAUSED"
                self.scene!.view?.isPaused = true
                

            }
        }
    }
    
    
    let cat = SKSpriteNode(imageNamed: "character1")
    let sushiBase = SKSpriteNode(imageNamed:"roll")

    // Make a tower
    var sushiTower:[SushiPiece] = []
    let SUSHI_PIECE_GAP:CGFloat = 80
    var catPosition = "left"
    
    
    // Show life and score labels
    let lifeLabel = SKLabelNode(text:"Lives: ")
    let scoreLabel = SKLabelNode(text:"Score: ")
    let secondsRemainingLabel = SKLabelNode(text: "25")
    var timeBar:SKSpriteNode!
    
    var lives = 5
    var score = 0

    var moveDirection = "left"
    var updateCount = 1
    var SecondsRemaining = 25
    //var moreTime = [String]()
    var powerUpCount = 0
    // Random number between 5 and 23 at which the powerup would be sent to watch
    var randomNum = Int.random(in: 5...23)
    
    
    func spawnSushi() {
        
        // -----------------------
        // MARK: PART 1: ADD SUSHI TO GAME
        // -----------------------
        
        // 1. Make a sushi
        let sushi = SushiPiece(imageNamed:"roll")
        
        // 2. Position sushi 10px above the previous one
        if (self.sushiTower.count == 0) {
            // Sushi tower is empty, so position the piece above the base piece
            sushi.position.y = sushiBase.position.y
                + SUSHI_PIECE_GAP
            sushi.position.x = self.size.width*0.5
        }
        else {
            let previousSushi = sushiTower[self.sushiTower.count - 1]
            sushi.position.y = previousSushi.position.y + SUSHI_PIECE_GAP
            sushi.position.x = self.size.width*0.5
        }
        
        // 3. Add sushi to screen
        addChild(sushi)
        
        // 4. Add sushi to array
        self.sushiTower.append(sushi)
    }
    
    override func didMove(to view: SKView) {
        
        
        DispatchQueue.main.async {
            // 1. Check if phone supports WCSessions
            print("Phone view loaded")
            if WCSession.isSupported() {
               print("Phone supports WCSession")
                WCSession.default.delegate = self
                WCSession.default.activate()
               print("Session Activated")
            }
            else {
                print("Phone does not support WCSession")
            }
        }
        
        
        
        // add background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        // add cat
        cat.position = CGPoint(x:self.size.width*0.25, y:100)
        addChild(cat)
        
        // add base sushi pieces
        sushiBase.position = CGPoint(x:self.size.width*0.5, y: 100)
        addChild(sushiBase)
        
        // build the tower
        self.buildTower()
        
        // Game labels
        self.scoreLabel.position.x = 60
        self.scoreLabel.position.y = size.height - 150
        self.scoreLabel.fontName = "Avenir"
        self.scoreLabel.fontSize = 30
        self.scoreLabel.fontColor = UIColor.green
        self.scoreLabel.zPosition = 19
        addChild(scoreLabel)
        
        // Life label
        self.lifeLabel.position.x = 60
        self.lifeLabel.position.y = size.height - 200
        self.lifeLabel.fontName = "Avenir"
        self.lifeLabel.fontSize = 30
        self.lifeLabel.zPosition = 18
        self.lifeLabel.fontColor = UIColor.green
        addChild(lifeLabel)
        
        self.timeBar = SKSpriteNode(imageNamed: "timeBar")
        self.timeBar.position = CGPoint(x: self.size.width/2, y: self.size.height - 80)
        self.timeBar.zPosition = 20
        addChild(timeBar)
        
        self.secondsRemainingLabel.position = CGPoint(x: 105, y: self.size.height - 90)
        self.secondsRemainingLabel.fontName = "Avenir"
        self.secondsRemainingLabel.fontSize = 30
        self.secondsRemainingLabel.zPosition = 22
        self.secondsRemainingLabel.fontColor = UIColor.white
        addChild(secondsRemainingLabel)
    }
    
    func buildTower() {
        for _ in 0...10 {
            self.spawnSushi()
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        self.updateCount = self.updateCount + 1
        if (self.updateCount%60 == 0)&&(self.SecondsRemaining > 0) {
            //Decrease secomnds remaining by 1 every second/60 frames
            self.SecondsRemaining = self.SecondsRemaining - 1
            print("Seconds: \(self.SecondsRemaining)")
            //update secondsRemaining Label and timeBar width
            self.secondsRemainingLabel.text = "\(self.SecondsRemaining)"
            self.timeBar.size.width = CGFloat(self.SecondsRemaining*10)
            self.timeBar.position.x = self.timeBar.position.x - 5
            //send Time Warning to watch
            self.sendTimeWarningTowatch()
            //ask for more time from watch (maximum 2 times)
            self.askMoreTime()
            print("powerUp count: \(self.powerUpCount)")
        }
        if SecondsRemaining == 0 {
            //Pause the Game if seconds remaining = 0 and show "GAME OVER" on phone
            scene!.view?.isPaused = true
            self.secondsRemainingLabel.fontColor = UIColor.red
            self.secondsRemainingLabel.text = "GAME OVER"
        }
        
    }
    
    public func askMoreTime(){
        //Send More time powerup request to Watch
        if (self.powerUpCount < 2){
            
            if (self.SecondsRemaining == self.randomNum){
                if (WCSession.default.isReachable) {
                    print("Watch reachable")
                    let message = ["moreTime": "10 seconds more?"]
                    WCSession.default.sendMessage(message, replyHandler: nil)
                    // output a debug message to the console
                    print("Asked watch for more time")
                    //increase powerUp count by 1
                    self.powerUpCount = self.powerUpCount + 1
                }
                else {
                    print("WATCH: Cannot reach watch")
                }
                // set randomNum to any random number between current secondsRemaining and 0
                self.randomNum = Int.random(in: 0...self.randomNum)
            }
    
            
        }
        
    }
    
    public func sendTimeWarningTowatch(){
        // send time remaining warning to watch at 15,10,5 and 0 seconds remaining
        if ((self.SecondsRemaining == 15)||(self.SecondsRemaining == 10)||(self.SecondsRemaining == 5))||(self.SecondsRemaining == 0){
            if (WCSession.default.isReachable) {
                print("Watch reachable")
                let message = ["timeRemaining": self.SecondsRemaining]
                WCSession.default.sendMessage(message, replyHandler: nil)
                // output a debug message to the console
                print("sent time remaining to watch")
            }
            else {
                print("WATCH: Cannot reach watch")
            }
        }
        
        
    }
    
    public func moveCat(){
        //move the cat left/right
        if self.moveDirection == "left" {
            cat.position = CGPoint(x:self.size.width*0.25, y:100)
            
            // change the cat's direction
            let facingRight = SKAction.scaleX(to: 1, duration: 0)
            self.cat.run(facingRight)
            
            // save cat's position
            self.catPosition = "left"
        }
        if self.moveDirection == "right"{
            cat.position = CGPoint(x:self.size.width*0.85, y:100)
            
            // change the cat's direction
            let facingLeft = SKAction.scaleX(to: -1, duration: 0)
            self.cat.run(facingLeft)
            
            // save cat's position
            self.catPosition = "right"

        }
        // ------------------------------------
        // MARK: ANIMATION OF PUNCHING CAT
        // -------------------------------------
        
        // show animation of cat punching tower
        let image1 = SKTexture(imageNamed: "character1")
        let image2 = SKTexture(imageNamed: "character2")
        let image3 = SKTexture(imageNamed: "character3")
        
        let punchTextures = [image1, image2, image3, image1]
        
        let punchAnimation = SKAction.animate(
            with: punchTextures,
            timePerFrame: 0.1)
        
        self.cat.run(punchAnimation)
        
        
        // ------------------------------------
        // MARK: WIN AND LOSE CONDITIONS
        // -------------------------------------
        
        if (self.sushiTower.count > 0) {
            // 1. if CAT and STICK are on same side - OKAY, keep going
            // 2. if CAT and STICK are on opposite sides -- YOU LOSE
            let firstSushi:SushiPiece = self.sushiTower[0]
            let chopstickPosition = firstSushi.stickPosition
            
            if (catPosition == chopstickPosition) {
                // cat = left && chopstick == left
                // cat == right && chopstick == right
                print("Cat Position = \(catPosition)")
                print("Stick Position = \(chopstickPosition)")
                print("Conclusion = LOSE")
                print("------")
                
                self.lives = self.lives - 1
                self.lifeLabel.text = "Lives: \(self.lives)"
            }
            else if (catPosition != chopstickPosition) {
                // cat == left && chopstick = right
                // cat == right && chopstick = left
                print("Cat Position = \(catPosition)")
                print("Stick Position = \(chopstickPosition)")
                print("Conclusion = WIN")
                print("------")
                
                self.score = self.score + 10
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
            
        else {
            print("Sushi tower is empty!")
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        // This is the shortcut way of saying:
        //      let mousePosition = touches.first?.location
        //      if (mousePosition == nil) { return }
        guard let mousePosition = touches.first?.location(in: self) else {
            return
        }

        print(mousePosition)
        
        // ------------------------------------
        // MARK: UPDATE THE SUSHI TOWER GRAPHICS
        //  When person taps mouse,
        //  remove a piece from the tower & redraw the tower
        // -------------------------------------
        let pieceToRemove = self.sushiTower.first
        if (pieceToRemove != nil) {
            // SUSHI: hide it from the screen & remove from game logic
            pieceToRemove!.removeFromParent()
            self.sushiTower.remove(at: 0)
            
            // SUSHI: loop through the remaining pieces and redraw the Tower
            for piece in sushiTower {
                piece.position.y = piece.position.y - SUSHI_PIECE_GAP
            }
            
            // To make the tower inifnite, then ADD a new piece
            self.spawnSushi()
        }
        
        // ------------------------------------
        // MARK: SWAP THE LEFT & RIGHT POSITION OF THE CAT
        //  If person taps left side, then move cat left
        //  If person taps right side, move cat right
        // -------------------------------------
        
        // 1. detect where person clicked
        let middleOfScreen  = self.size.width / 2
        if (mousePosition.x < middleOfScreen) {
            print("TAP LEFT")
            self.moveDirection = "left"
            self.moveCat()
            // 2. person clicked left, so move cat left
//            cat.position = CGPoint(x:self.size.width*0.25, y:100)
//
//            // change the cat's direction
//            let facingRight = SKAction.scaleX(to: 1, duration: 0)
//            self.cat.run(facingRight)
//
//            // save cat's position
//            self.catPosition = "left"
            
        }
        else {
            print("TAP RIGHT")
            self.moveDirection = "right"
            self.moveCat()
            // 2. person clicked right, so move cat right
//            cat.position = CGPoint(x:self.size.width*0.85, y:100)
//
//            // change the cat's direction
//            let facingLeft = SKAction.scaleX(to: -1, duration: 0)
//            self.cat.run(facingLeft)
//
//            // save cat's position
//            self.catPosition = "right"
        }

       
        
    }
 
}
