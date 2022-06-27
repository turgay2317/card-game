//
//  ViewController.swift
//  CardMatchingGame
//
//  Created by Turgay Ceylan on 27.06.2022.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var timeRecordLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var localTimer: UILabel!
    @IBOutlet weak var card6: UIImageView!
    @IBOutlet weak var card5: UIImageView!
    @IBOutlet weak var card4: UIImageView!
    @IBOutlet weak var card3: UIImageView!
    
    @IBOutlet weak var card2: UIImageView!
    @IBOutlet weak var card1: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    var timer = Timer()
    var cardSymbols : [UIImageView : String] = [:];
    var correctCounter = 0
    var status: Int8 = 0
    var localTime: Int = 0
    var record: Int = 9999
    /*
     Record value defined max value cause min should be record logically
     */
    var cards : [UIImageView] = []
    /*
        Status (-1): You can't click any
        Status (0): Game has not started
        Status (1): Selecting first card
        Status (2): Selecting second card
        Status (3): Game has ended
     */
    var selectedCard : UIImageView? = nil
    
    /* When the game started, showing recent saved record*/
    func loadRecentRecord(){
        if let maxRecord = UserDefaults.standard.object(forKey: "record"){
            record = maxRecord as! Int
            refreshRecord()
        }else {
            record = 9999
            timeRecordLabel.text = "Record: - s";
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCards()
        loadRecentRecord()
    }
    
    func getStarter(){
        closeAllCards()
        createNewCardsNewImages()
    }
    
    func closeAllCards(){
        for card in cards {
            card.image = UIImage(named: "qm")
        }
    }
    
    func createCards(){
        cards = [card1, card2, card3, card4, card5, card6]
    }
    
    func createNewCardsNewImages(){
        var images = ["strawberry","fish","strawberry","psychology","fish","psychology"]
        
        for card in cards{
            card.isUserInteractionEnabled = true;
            let tapGesture = CustomTapGestureRecognizer(target: self, action: #selector(clickedObject(sender:)))
            tapGesture.from = card
            card.addGestureRecognizer(tapGesture)
            let c = images.count - 1;
            let r = Int.random(in: 0...c)
            cardSymbols[card] = images[r]
            images.remove(at:r)
        }
    }
    
    @IBAction func startButton(_ sender: Any) {
        if status == 0 || status == 3 {
            getStarter()
            localTime = 0
            status = 1
            correctCounter = 0
            setInfo(message: "Game has started")
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeIncreaser), userInfo: nil, repeats: true)
        }
    }
    
    func setInfo(message: String){
        infoLabel.text = message
    }
    
    @objc func clickedObject(sender: CustomTapGestureRecognizer){
        if status == 1 {
            sender.from!.image = UIImage(named: cardSymbols[sender.from!]!)
            selectedCard = sender.from!;
            setInfo(message: "Select second card")
            status = 2
        } else if status == 2 {
            status = -1;
            sender.from!.image = UIImage(named: cardSymbols[sender.from!]!)
            // Wait 1 second after showing card
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if sender.from?.image! == selectedCard?.image{
                    sender.from!.isUserInteractionEnabled = false;
                    selectedCard?.isUserInteractionEnabled = false;
                    correctCounter += 1
                    setInfo(message: "succes!")
                    status = 1
                    if correctCounter >= 3 {
                        // End of the game
                        status = 3
                        setInfo(message: "Game has finished")
                        if localTime < record {
                            record = localTime
                            refreshRecord()
                        }
                    }
                }else{
                    selectedCard?.image = UIImage(named: "qm")
                    sender.from!.image = UIImage(named: "qm")
                    selectedCard = nil
                    status = 1
                    setInfo(message: "Wrong! try again")
                }
            }
            
        }
        
    }
    
    @objc func timeIncreaser(){
        if status == 0 {
            localTime = 0
        }else if status == 3 {
            timer.invalidate()
            if localTime < record {
                UserDefaults.standard.set(localTime, forKey: "record")
                record = localTime
                refreshRecord()
            }
        }else{
            localTime += 1
        }
        refreshTime()
    }
    
    func refreshTime(){
        localTimer.text = String(localTime) + "s"
    }
    
    func refreshRecord(){
        timeRecordLabel.text = "Record: "+String(localTime) + "s"
    }


}

class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var from: UIImageView?
}

