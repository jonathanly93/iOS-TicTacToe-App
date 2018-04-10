//
//  ViewController.swift
//  TicTacToe
//
//  Created by Jonathan L on 7/29/2017.
//  Copyright © 2017 Jonatahan L. All rights reserved.
//

///
// - Attribution: https://www.safaribooksonline.com/library/view/hello-android-4th/9781680500875/f_0038.html
// - Attribution: https://stackoverflow.com/questions/24172180/swift-creating-an-array-of-uiimage

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //Mark: Variables
    var board = ["N", "N", "N", "N", "N", "N", "N", "N", "N"] // Create array of 9 "N" to determine which move placements
    
    let winConditions = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]] // winConditions are the possible ways to win the match
    
    
    let winLocations = [[25.0, 135.5, 325.0, 20.0, 0.0],
                      [25.0, 260.5, 325.0, 20.0, 0.0],
                      [25.0, 385.5, 325.0, 20.0, 0.0],
                      [52.5, 105.5, 20.0, 325.0, 0.0],
                      [177.5, 105.0, 20.0, 325.0, 0.0],
                      [302.5, 105.0, 20.0, 325.0, 0.0],
                      [177.5, 85.0, 20.0, 375.0, 2.356],
                      [177.5, 85.0, 20.0, 375.0, 0.78]] // winLocation is the division are the x and y coordinates to determine connecting 3 in a row.
    
    
    var winner = "N"         // variable check to determine winner.
    var player = "x"         // Player X moves first
    var panGestureX: UIPanGestureRecognizer?
    var panGestureO: UIPanGestureRecognizer?
    
    
    // Victory line when 3 symbols are connected in a row
    var line = UIView(frame: CGRect(x: 0, y: 83, width: 200.0, height: 200.0))

    //Mark: Properties
    @IBOutlet weak var playerO: UIImageView!
    @IBOutlet weak var playerX: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGestureX = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureO = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        playerX.addGestureRecognizer(panGestureX!)
        playerO.addGestureRecognizer(panGestureO!)
        playerO.alpha = 0.5
        panGestureO?.isEnabled = false // Ensure only player X can move first
        self.view.addSubview(self.line)
    }
    
    
    //handlePan handles the pan gesture used to move x and o. Put pieces into blocks if no other pieces
    //occupy the block. Play the okSound if move is successful. Play the notOkSound if there is already 
    //a piece in the block. If the user moves a piece, but does not put it in any block, simply move the
    //piece back to its original place and wait for the user to make a move again. 
    
    func handlePan(_ recognizer:UIPanGestureRecognizer) {
        
        // sets up pangesture for player x
        var coordinate = CGPoint(x: 100, y: 525)
        var nextPlayer = self.panGestureO
        var nextPlayerName = "o"
        var nextPlayerImg = playerO
        
        // sets up pangesture for player o
        if self.player == "o" {
            coordinate = CGPoint(x: 275, y: 525)
            nextPlayer = self.panGestureX
            nextPlayerName = "x"
            nextPlayerImg = playerX
        }
        
       
        let translation = recognizer.translation(in: self.view)

        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        

        /**
        handleMove checks for movement of X and O and ensures
        the player is making a legal move. There are 9 possible
        locations and they are checked via the coordinate points.
        If a viable location is available, then the image will
        be reset to match the current player's image.
        */
        func handleMove(imgTag: Int) {
            guard let tempImgView = self.view.viewWithTag(imgTag) as? UIImageView else {
                print("Could not unwrap")
                return
            }
            
            let precisionFrame = tempImgView.frame.insetBy(dx: 50.0, dy: 50.0) // allows for better judgement on which imageview to place a move.
            
            
            if (recognizer.view?.frame)!.intersects(precisionFrame) && playableSpot(board: self.board).contains(imgTag){
                board[imgTag - 1] = self.player
                tempImgView.image = UIImage(named: self.player)
                recognizer.view?.alpha = 0.5
                recognizer.view?.center = coordinate
                recognizer.isEnabled = false
                self.player = nextPlayerName
                nextPlayer?.isEnabled = true
                nextPlayerImg?.alpha = 1
                UIView.animate(withDuration: 0.6, animations: {
                    nextPlayerImg?.transform = CGAffineTransform(scaleX: 2, y: 2) },
                               completion: { (finish: Bool) in
                                UIView.animate(withDuration: 0.6, animations: {
                                    nextPlayerImg?.transform = CGAffineTransform.identity }) })
                

            } else if ((recognizer.view?.frame)!.intersects(tempImgView.frame) && !playableSpot(board: self.board).contains(imgTag)) {
        
            }
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {

            for i in 1...9{
                handleMove(imgTag: i)
            }
            recognizer.view?.center = coordinate
            
            for i in 0...7{

                
                let patterns = self.winConditions[i]
                if board[patterns[0]] != "N" && board[patterns[0]] == board[patterns[1]] && board[patterns[1]] == board[patterns[2]]{
                    self.winner = board[patterns[0]]

                    self.panGestureO?.isEnabled = false
                    self.panGestureX?.isEnabled = false
                    drawLine(value: self.winLocations[i])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        self.performSegue(withIdentifier: "win", sender: Any?.self)
                        self.restartGame()
                    }
                    break
                }
            }
            
            if playableSpot(board: board) == [] && self.winner == "N" {
                print("TIE GAME!")
                self.performSegue(withIdentifier: "win", sender: Any?.self)
                restartGame()
            }
        }
    }
    
    
    // Returns the number of playable spots left
    func playableSpot(board: [String]) -> [Int]{
        var emptyBlock:[Int] = []
        for i in 0...8{
            if board[i] == "N" {
                emptyBlock.append(i+1)
            }
        }
        return emptyBlock
    }
    
    // Reinitializes the starting point of the game
    func restartGame(){
        for i in 1...9 {
            if let tempImg = self.view.viewWithTag(i) as? UIImageView {
                tempImg.image  = nil
            }
        }
        self.board = ["N", "N", "N", "N", "N", "N", "N", "N", "N"]
        self.playerO.alpha = 0.5
        self.playerX.alpha = 1
        self.panGestureO?.isEnabled = false
        self.panGestureX?.isEnabled = true
        self.playerX.center = CGPoint(x: 50, y: 475)
        self.playerO.center = CGPoint(x: 225, y: 475)
        self.player = "x"
        self.winner = "N"
        self.line.alpha = 0
        self.view.willRemoveSubview(self.line)
    }

    
    @IBAction func unwindToRVC(sender: UIStoryboardSegue) {
        print("Back at RVC")
    }

     /**
    Allows second segue to be displayed. The second segue consist
    of both the info page and the end game page. The message will 
    be determined by the listed conditios
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "info") {
            
            let viewController = segue.destination as! InfoViewController
            
            viewController.passedData = "info"
        }
        if (segue.identifier == "win") {
            
            let viewController = segue.destination as! InfoViewController
            
            viewController.passedData = winner
        }
    }
    
  
    
    // Draws the winning line that connects 3 in a row
    func drawLine(value:[Double]){
        self.line = UIView(frame: CGRect(x: value[0], y: value[1], width: value[2], height: value[3]))
        self.line.alpha = 1
        self.line.layer.backgroundColor = UIColor.red.cgColor
        self.line.transform = CGAffineTransform(rotationAngle: CGFloat(value[4]));
        self.view.addSubview(self.line)
    }
    
}

