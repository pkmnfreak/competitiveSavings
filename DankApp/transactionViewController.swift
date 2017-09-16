//
//  transactionViewController.swift
//  DankApp
//
//  Created by Evan Chang on 16/09/17.
//  Copyright © 2017 Evan Chang. All rights reserved.
//
import Foundation
import UIKit
import Firebase

class transactionViewController: UIViewController {
    
    let types = ["Food", "Transportation", "Recreational"]
    let databaseRef = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var currentRound = ""
    var currentDate = ""
    
    
    @IBOutlet weak var costTextField: UITextField!
    
    @IBOutlet weak var typeOfTransaction: UISegmentedControl!
    
    @IBOutlet weak var commentsTextField: UITextView!
    
    override func viewDidLoad() {
        fetchData { (value) in
            self.currentRound = String(value)
        }
        let date = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date)
        currentDate = String(describing: dateComponents.month) + "-" + String(describing: dateComponents.day)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createTransactionPressed(_ sender: Any) {
        let type = types[typeOfTransaction.selectedSegmentIndex]
        let cost = costTextField.text
        let userRef = databaseRef.child("users").child(uid!).child("stats").child(currentRound).child(currentDate)
        let comment = commentsTextField.text
        if let temp = Double(cost!) {
            if comment != "" && type != "" {
                let values : [String : Double] = [comment! : temp]
                userRef.child(type).updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                })
                
                fetchTotal { (values) in
                    let newTotal = values + temp
                    let newValues = ["total" : newTotal]
                    let totalRef = self.databaseRef.child("users").child(self.uid!).child("stats").child(self.currentRound)
                    totalRef.updateChildValues(newValues, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    })
                }
                
                
                performSegue(withIdentifier: "transactionToHome", sender: Any?.self)
            } else {
                let alertController = UIAlertController(title: "Error", message: "Please enter a comment and type", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter a number for cost", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchData(andOnCompletion completion:@escaping (Int)->()){
        let userRef = databaseRef.child("users").child(uid!).child("currentRound")
        var value : Int = 0
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                value = (dict["currentRound"] as? Int!)!
            }
            completion(value)
        })
    }
    
    func fetchTotal(andOnCompletion completion:@escaping (Double)->()){
        let userRef = databaseRef.child("users").child(uid!).child("stats").child(currentRound)
        var value : Double = 0
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                if let total = dict["total"] {
                    value = total as! Double
                }
            }
            completion(value)
        })
    }
    
}
