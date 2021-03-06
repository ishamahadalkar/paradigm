//
//  SettingsViewController.swift
//  Paradigm
//
//  Created by Isha Mahadalkar on 2/16/21.
//  Copyright © 2021 team5. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBAction func switchClicked(_ sender: Any) {
        if notificationSwitch.isOn {
            // Turn on Notifications
            print("Notification switch is On")
            UserDefaults.standard.set(true, forKey: "notificationsOn")
            Utils.turnOnNotification()
            notificationSet = 1
        }
        else {
            // Turn off Notifications
            print("Notification switch is Off")
            UserDefaults.standard.set(false, forKey: "notificationsOn")
            Utils.turnOffNotifications()
            notificationSet = 0
        }
    }
    @IBAction func logoutTapped(_ sender: Any) {
        // When the logout button is tapped
        
        // Ask for an alert
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout of your account?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
            // Log out the user
            // Setting the User Defaults to false
            UserDefaults.standard.set(false, forKey: "status")
            
            // After user has successfully logged out
      
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginView = storyboard.instantiateViewController(identifier: "LoginViewController")

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginView)
        }))
        
        alert.addAction(UIAlertAction( title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }

    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        // When the delete account button is tapped
        // Add a comment
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        if (UserDefaults.standard.object(forKey: "notificationsOn") == nil) {
            notificationSwitch.isOn = true
        } else {
            notificationSwitch.isOn = UserDefaults.standard.object(forKey: "notificationsOn") as! Bool
        }

    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
