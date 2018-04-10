//
//  InfoViewController.swift
//  TicTacToe
//
//  Created by Jonathan L on 7/29/2017.
//  Copyright © 2017 Jonatahan L. All rights reserved.
//



import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textLabel: UILabel!
    var passedData: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.textLabel.lineBreakMode = .byWordWrapping
        self.textLabel.numberOfLines = 0
        
    }
    
    
    // Displays the correct label according to the conditions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if passedData == "x"{
            titleLabel.text = "GAME OVER!"
            textLabel.text = "Player X Wins!"
        } else if passedData == "o" {
            titleLabel.text = "GAME OVER!"
            textLabel.text = "Player O Wins!"
        } else if passedData == "info" {
            titleLabel.text = "Instructions"
            textLabel.text = "Players take turns dropping their icon on the grid. First player to connect 3 in a row wins!"
        } else if passedData == "E" {
            titleLabel.text = "GAME OVER!"
            textLabel.text = "TIE GAME!"
        }
        
    }
}
