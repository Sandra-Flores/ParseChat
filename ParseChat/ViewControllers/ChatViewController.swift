//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Diego Medina on 2/25/18.
//  Copyright © 2018 Diego Medina. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    var chatMessages: [String] = []
    var chatUsers: [String] = []
    var chatDates: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onTimer(_:)), userInfo: nil, repeats: true)
        
        self.chatTableView.dataSource = self
        self.chatTableView.delegate = self
        
        // Auto size row height based on cell autolayout constraints
        chatTableView.rowHeight = UITableViewAutomaticDimension
        // Provide an estimated row height. Used for calculating scroll indicator
        chatTableView.estimatedRowHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSendButtonPressed(_ sender: Any) {
        
        let chatMessage = PFObject(className: "Message")
        let user = PFUser.current()

        chatMessage["text"] = messageTextField.text ?? ""
        chatMessage["user"] = user
    

        chatMessage.saveInBackground { (success, error) in
            if success {
                print("The message was saved!")
                self.messageTextField.text = ""
                
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
                
                let alertController = UIAlertController(title: "Oops!", message: "Message was unable to send", preferredStyle: .alert)
                
                // create an OK action
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    // handle response here.
                }
                // add the OK action to the alert controller
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatMessageTableViewCell
        
        // message
        cell.chatMessageLabel.text = self.chatMessages[indexPath.row]
        
        // user
        cell.usernameLabel.text = self.chatUsers[indexPath.row]
        
        // date
        cell.dateLabel.text = self.chatDates[indexPath.row]
        
        return cell
    }
    
    @objc func onTimer(_ sender: Any?){
        
        let df = DateFormatter()
        
        df.dateStyle = .short
        df.timeStyle = .short
        
        let query = PFQuery(className: "Message")
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (messages, error) in
            if(messages != nil){
                self.chatMessages = []
                self.chatUsers = []
                self.chatDates = []
                for message in messages!{
                    self.chatMessages.append(message["text"] as! String)
                    
                    if(message["user"] != nil){
                        self.chatUsers.append((message["user"] as! PFUser).username!)
                    }
                    else{
                        self.chatUsers.append("Unknown")
                    }
                    
                    self.chatDates.append(df.string(from: message.createdAt!))
                
                }
                
                self.chatTableView.reloadData()
            }
            else{
                print(error?.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
