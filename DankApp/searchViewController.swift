//
//  searchViewController.swift
//  DankApp
//
//  Created by Evan Chang on 16/09/17.
//  Copyright © 2017 Evan Chang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class searchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let databaseRef = Database.database().reference()
    let currentUID = Auth.auth().currentUser?.uid
    var competitors = [String]()
    var competitorIDs = [String]()
    var currentName = String()
    
    @IBOutlet weak var toHomeButton: UIButton!
    
    @IBOutlet weak var numberOfDaysTextField: UITextField!
    
    @IBOutlet weak var searchBarTextField: UITextField!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        fetchName { (values) in
            self.currentName = values
        }
        searchTableView.delegate = self
        searchTableView.dataSource = self
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGameButtonPressed(_ sender: Any) {
        if let duration = Int(numberOfDaysTextField.text!) {
            let date = Date()
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.month = calendar.component(.month, from: date)
            dateComponents.day = calendar.component(.day, from: date)
            let currentDate = String(describing: dateComponents.month!) + "-" + String(describing: dateComponents.day!)
            let endDate = String(describing: dateComponents.month!) + "-" + String(describing: dateComponents.day! + duration)
            let before = competitorIDs
            let before2 = competitors
            for user in before {
                updateInComp(uid: user, competitorIDs: before, competitors: before2, interval: duration, startDate: currentDate, endDate: endDate)
            }
            updateInComp(uid: currentUID!, competitorIDs: before, competitors: before2, interval: duration, startDate: currentDate, endDate: endDate)
            performSegue(withIdentifier: "searchToHome", sender: Any?.self)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Input a duration!!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func updateInComp(uid : String, competitorIDs: [String], competitors: [String], interval: Int, startDate: String, endDate: String) {
        let temp = competitorIDs + [currentUID!]
        let temp2 = competitors + [currentName]
        let values = ["inComp" : true, "competitors" : temp2, "compIDs" : temp, "compInterval" : interval, "startDate" : startDate, "endDate": endDate] as [String : Any]
        self.databaseRef.child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        })
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if searchBarTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            let username = searchBarTextField.text!
            databaseRef.child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    let name = (Array(dict.values)[0] as! [String : AnyObject])["username"]!
                    let inComp = (Array(dict.values)[0] as! [String : AnyObject])["inComp"]! as! Bool
                    let id = Array(dict.keys)[0] as! String
                    if (!inComp && !self.competitors.contains(name as! String)) {
                        self.competitors.append(name as! String)
                        self.competitorIDs.append(id)
                        self.searchTableView.reloadData()
                    } else {
                        let alertController = UIAlertController(title: "Error", message: (name as! String) + " is already in a competition", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                }) { (err) in
                    print(err)
                }
        }
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "searchToHome", sender: Any?.self)
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        competitors.remove(at: indexPath.row)
        competitorIDs.remove(at: indexPath.row)
        searchTableView.reloadData()
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchTableViewCell
        cell.usernameLabel.text = competitors[indexPath.row]
        return cell
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return competitors.count
    }
    
    func fetchName(andOnCompletion completion:@escaping (String)->()){
        let userRef = databaseRef.child("users").child(currentUID!)
        var value : String = ""
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                value = (dict["username"] as? String)!
            }
            completion(value)
        })
    }
}
