//
//  ViewController.swift
//  AskOrAnswer
//
//  Created by Apurva Patel on 10/11/17.
//  Copyright © 2017 Apurva Patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
  
    var saveUserNames : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        if let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
                if let firebaseError = error {
                    print (firebaseError.localizedDescription)
                    return
                }
                print ("Login Sucsess")
                guard let uid = user?.uid else {
                    return
                }
                let ref = Database.database().reference(fromURL: "https://askoranswer-ec8e0.firebaseio.com/")
                let userReference = ref.child("user").child(uid)
                let values = ["UserName" : username, "email": email]
                userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print (Error.self)
                        return
                    }
                    print ("Saved user successfully into firebase DB")
                })
                self.passwordTextField.text = ""
                self.presentLogedInScreen()
            })
        }
    }
    func binarySearch<T:Comparable>(inputArr:Array<T>, searchItem: T) -> Bool {
        var lowerIndex = 0;
        var upperIndex = inputArr.count - 1
        
        while (true) {
            let currentIndex = (lowerIndex + upperIndex)/2
            if(inputArr[currentIndex] == searchItem) {
                return true
            } else if (lowerIndex > upperIndex) {
                return false
            } else {
                if (inputArr[currentIndex] > searchItem) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
       
        var uniqueUsername = false
        saveUserNames = saveUserNames.sorted()
        if saveUserNames.isEmpty{
            uniqueUsername = false
        }
        else {
            uniqueUsername = binarySearch(inputArr: saveUserNames, searchItem: usernameTextField.text!)
        }
        
        if uniqueUsername == false {
        if let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
                if let firebaseError = error {
                    print (firebaseError.localizedDescription)
                    return
                }
                print ("Created an account successfully")
                self.saveUserNames.append(self.usernameTextField.text!)
                guard let uid = user?.uid else {
                    return
                }
                let ref = Database.database().reference(fromURL: "https://askoranswer-ec8e0.firebaseio.com/")
                let userReference = ref.child("user").child(uid)
                let values = ["UserName" : username, "email": email]
                userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print (Error.self)
                        return
                    }
                    print ("Saved user successfully into firebase DB")
                })
                self.passwordTextField.text = ""
                self.presentLogedInScreen()
            })
        }
        }
        else {
            print ("Choose new username")
        }
    }
    func presentLogedInScreen() {
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggedInVC:LoggedInVC = storyBoard.instantiateViewController(withIdentifier: "LoggedInVC") as! LoggedInVC
        self.present(loggedInVC, animated: true, completion: nil)
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

