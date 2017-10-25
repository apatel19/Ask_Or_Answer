//
//  LoggedInVC.swift
//  AskOrAnswer
//
//  Created by Apurva Patel on 10/12/17.
//  Copyright © 2017 Apurva Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoggedInVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var allQuestions: [String] = []
    var handle: DatabaseHandle?
    var ref: DatabaseReference?
    
    @IBOutlet weak var questionTabelView: UITableView!
    
    @IBOutlet weak var userNameShow: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTheUserName()
        ref = Database.database().reference()
        handle = ref?.child("Questions").observe(.childAdded, with: {(snapshot) in
            if let item = snapshot.value as? String
            {
                self.allQuestions.append(item)
                self.questionTabelView.reloadData()
            }
        })
    }
    
    func getTheUserName () {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("user").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.userNameShow.text = dictionary["UserName"] as? String
                }
            }, withCancel: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func tappedToAskQuestionButton(_ sender: Any) {
        let alert = UIAlertController(title: "Ask Question", message: "Type Your Question.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Type here..."
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Post", style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text else {return}
            print (text)
            
            if text != "" {
                self.ref?.child("Questions").childByAutoId().setValue(text)
            }
        })
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = allQuestions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DestinationVC: AnswerQuestionVC = storyboard.instantiateViewController(withIdentifier: "AnswerQuestionVC") as! AnswerQuestionVC
        DestinationVC.getQuestion = allQuestions[indexPath.row] as String
        self.present(DestinationVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
            handleLogOut()
    }
    
    @objc func handleLogOut () {
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(vc, animated: false, completion: nil)
        }
    }
}
