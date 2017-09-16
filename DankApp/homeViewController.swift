//
//  homeViewController.swift
//  DankApp
//
//  Created by Evan Chang on 16/09/17.
//  Copyright © 2017 Evan Chang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class homeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let databaseRef = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var competitors = [String]()
    
    @IBOutlet weak var toSearchButton: UIButton!
    
    @IBOutlet weak var medalTableView: UITableView!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var streakTableView: UITableView!
    
    @IBOutlet weak var numberOfDaysTextField: UITextField!
    
    @IBOutlet weak var competitorTableView: UITableView!
    
    override func viewDidLoad() {
        competitorTableView.delegate = self
        competitorTableView.dataSource = self
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchCompInfo { (values) in
            if self.checkDate(endDate: values[4] as! String) {
                for user in values[0] as! [String] {
                    self.endCompetition(uid: user)
                }
            } else if values[2] as! Int == 0 && values[1] as! Bool {
                let alertController = UIAlertController(title: "Budget", message: "Please input how much you aim to spend this round", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                    if let field = alertController.textFields![0] as? UITextField {
                        let values = ["budget" : Int(field.text!)]
                        self.databaseRef.child("users").child(self.uid!).updateChildValues(values, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print(error!)
                                return
                            }
                        })
                    } else {
                        // user did not fill field
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                
                alertController.addTextField { (textField) in
                    textField.placeholder = "Spending Maximum"
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                //show competitor progress
                if ((values[0] as! [String])[0] != "") {
                    self.competitors = values[0] as! [String]
                    self.competitorTableView.reloadData()
                }
            }
        }
        super.viewDidAppear(false)
    }
    
    func checkDate(endDate: String) -> Bool {
        let date = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date)
        let currentDate = String(describing: dateComponents.month!) + "-" + String(describing: dateComponents.day!)
        return currentDate == endDate
    }
    
    func endCompetition(uid: String) {
        let values = ["budget" : 0, "competitors" : [String](), "compIDs" : [String](), "inComp" : false, "competInterval": 0, "endDate": ""] as [String : Any]
        self.databaseRef.child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toSearchButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToSearch", sender: Any?.self)
    }
    
    @IBAction func addTransactionPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToTransaction", sender: Any?.self)
    }
    
    func fetchData(andOnCompletion completion:@escaping (Int)->()){
        let userRef = databaseRef.child("users").child(uid!).child("currentRound")
        var value : Int = 0
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                value = (dict["currentRound"] as? Int)!
            }
            completion(value)
        })
    }
    
    func fetchCompInfo(andOnCompletion completion:@escaping ([Any])->()){
        let userRef = databaseRef.child("users").child(uid!)
        var value : [Any] = []
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                if let c = dict["competitors"] {
                    value.append(c)
                } else {
                    value.append([""])
                }
                value.append(dict["inComp"]!)
                value.append(dict["budget"]!)
                value.append(dict["compInterval"]!)
                value.append(dict["endDate"]!)
            }
            completion(value)
        })
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return competitors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "competitorCell", for: indexPath) as! competitorTableViewCell
        cell.usernameLabel.text = competitors[indexPath.row]
        cell.placementLabel.text = String(indexPath.row + 1)
        databaseRef.child("users").queryOrdered(byChild: "username").queryEqual(toValue: cell.usernameLabel.text).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let budget = (Array(dict.values)[0] as! [String : AnyObject])["budget"]
                let currentRound = (Array(dict.values)[0] as! [String : AnyObject])["currentRound"] as! Int
                if let stats = (Array(dict.values)[0] as! [String : AnyObject])["stats"] {
                    let total = (stats[currentRound] as! [String : AnyObject])["total"] as! Double
                    cell.budgetLabel.text = "Percent: " + String(total / (budget as! Double)) + "%"
                } else {
                    cell.budgetLabel.text = "Percent: 0%"
                }
            }
        }) { (err) in
            print(err)
        }
        return cell
    }
}
