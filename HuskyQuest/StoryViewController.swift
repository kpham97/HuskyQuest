//
//  StoryViewController.swift
//  HuskyQuest
//
//  Created by studentuser on 6/1/17.
//  Copyright © 2017 Chris Li. All rights reserved.
//

import UIKit
import Alamofire

class StoryViewController: UIViewController {

    @IBOutlet weak var StoryTextBox: UITextView!
    @IBOutlet weak var Choice1Button: UIButton!
    @IBOutlet weak var Choice2Button: UIButton!
    @IBOutlet weak var Choice3Button: UIButton!
    
    
    var url = URL(string:"https://students.washington.edu/kpham97/Story.JSON")
    var jsonArray:[[String:Any]] = []
    var currTree:[[String:Any]] = []
    var choices:[[String:Any]] = []
    var mainIndex = 0
    var StatsIndex = [
        "RR" : 0,
        "stat2" : 1
    ]
    var Stats = [5,0,0,0,0,0,0]

    override func viewDidLoad() {
        let destination: DownloadRequest.DownloadFileDestination = {_, _ in
        
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("story.json")
            
            return(fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url!, method: .get, to: destination).responseJSON{response in
            
            print(response.result)
            let content = NSData(contentsOf: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("story.json"))
            
            if content != nil{
                do{
                    self.jsonArray = try JSONSerialization.jsonObject(with: content! as Data, options: []) as! [[String:Any]]
                } catch {
                    print("ERROR ERROR FILE NOT FOUND")
                }
            }
            
            print(self.jsonArray[1]["tree"]!)
            self.currTree = self.jsonArray[1]["tree"] as! [[String:Any]]
            self.turnPage()
            
            
            
        }
    }
    
    @IBAction func choiceClick(_ sender: UIButton) {
        var pickedChoice : [String:Any] = [:]
        if sender.tag == 1 {
            pickedChoice = self.choices[0]
        } else if sender.tag == 2{
            pickedChoice = self.choices[1]
        } else {
            pickedChoice = self.choices[2]
        }
        if pickedChoice["increase"] != nil {
            Stats[StatsIndex[pickedChoice["increase"] as! String]!] += 1
        }
        if pickedChoice["decrease"] != nil {
            Stats[StatsIndex[pickedChoice["increase"] as! String]!] -= 1
        }
        
        mainIndex = pickedChoice["response"] as! Int
        turnPage()
        
    }
    
    func turnPage(){
        StoryTextBox.text = currTree[mainIndex]["text"] as! String
        self.choices = self.currTree[mainIndex]["choices"] as! [[String:Any]]
        self.Choice1Button.setTitle(self.choices[0]["title"] as? String, for: UIControlState.normal)
        self.Choice2Button.isHidden = true
        self.Choice3Button.isHidden = true
        if self.choices.count > 2{
            self.Choice2Button.isHidden = false
            var Random = Int(arc4random_uniform(100))
            self.Choice2Button.setTitle(self.choices[1]["title"] as? String, for: UIControlState.normal)
            if self.choices[1]["modifier"] != nil {
                Random += Stats[StatsIndex[self.choices[1]["modifier"] as! String]!] * 10
            }
            if self.choices[1]["chance"] != nil && Random <= self.choices[1]["chance"] as! Int{
                self.Choice2Button.isHidden = true
            }
            Random = Int(arc4random_uniform(100))
            if self.choices.count > 3{
                self.Choice3Button.isHidden = false
                self.Choice3Button.setTitle(self.choices[2]["title"] as? String, for: UIControlState.normal)
                
                if self.choices[2]["modifier"] != nil {
                    Random += Stats[StatsIndex[self.choices[2]["modifier"] as! String]!] * 10
                }
                if self.choices[2]["chance"] != nil && Random <= self.choices[2]["chance"] as! Int{
                    self.Choice3Button.isHidden = true
                }
            }
            
        }
    }
    
    
}