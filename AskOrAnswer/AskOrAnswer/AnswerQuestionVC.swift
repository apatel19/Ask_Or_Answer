//
//  AnswerQuestionVC.swift
//  AskOrAnswer
//
//  Created by Apurva Patel on 10/14/17.
//  Copyright © 2017 Apurva Patel. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class AnswerQuestionVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var allAnswer: [String] = []
    var handle: DatabaseHandle?
    var ref: DatabaseReference?
    var getQuestion = String()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAnswer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = allAnswer[indexPath.row]
        return cell
    }
    
    @IBOutlet weak var showQuestionHere: UITextView!
    @IBOutlet weak var answerTabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showQuestionHere.text = getQuestion
        ref = Database.database().reference()
        handle = ref?.child(getQuestion).observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? String
            {
                self.allAnswer.append(item)
                self.answerTabelView.reloadData()
            }})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedTapHereToAnswer(_ sender: Any) {
        let alert = UIAlertController(title: "Answer", message: "Type your answer", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Type here..."
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let post = UIAlertAction(title: "Post", style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text else {return}
            print (text)
            if text != "" {
                self.ref?.child(self.getQuestion).childByAutoId().setValue(text)
            }
        })
        alert.addAction(cancel)
        alert.addAction(post)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedBackButton(_ sender: Any) {
    }
    
    @IBAction func tappedLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(vc, animated: false, completion: nil)
        }
    }
}
