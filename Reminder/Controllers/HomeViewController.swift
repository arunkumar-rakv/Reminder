//
//  ViewController.swift
//  Reminder
//
//  Created by admin on 15/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class HomeViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet var table: UITableView!
    
    var notificationPermission: Bool = false
    var reminderTaskVM = ReminderTaskViewModel()
    var notification = Notification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getPermission()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        reminderTaskVM.fetchTasksFromCoreData { [weak self] reminderTasks in
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
    }
    
    func getPermission() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, error in
            if granted {
                self.notificationPermission = true
            } else if error != nil {
                print("Error: \(error?.localizedDescription ?? "Permission Error")")
            }
        })
    }

    @IBAction func didTapNew() {
        
        guard let vc = storyboard?.instantiateViewController(identifier: "reminder") as? ReminderViewController else { return }
        
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { title, description, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = ReminderTask(title: title, body: description, date: date, id: UUID().uuidString)
                self.reminderTaskVM.addTasksToCoreData(reminderTask: new) { [weak self] reminderTasks in
                    DispatchQueue.main.async {
                        self?.table.reloadData()
                    }
                }
                
                self.notification.addNotification(reminderTask: new)
            }
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.table.indexPathForSelectedRow
        let task = reminderTaskVM.reminderDM[indexPath!.row]
        let reminderVC = segue.destination as! ReminderViewController
        reminderVC.titleText = task.value(forKey: "title") as? String
        reminderVC.descriptionText = task.value(forKey: "body") as? String
        reminderVC.dateValue = task.value(forKey: "date") as? Date
        reminderVC.idValue = task.value(forKey: "id") as? String
        reminderVC.title = "Edit Reminder"
        reminderVC.navigationItem.largeTitleDisplayMode = .never
        
        reminderVC.completionDelete = { title, description, date, id, action in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = ReminderTask(title: title, body: description, date: date, id: id)
                if action == "delete" {
                    self.reminderTaskVM.deleteTasksFromCoreData(reminderTask: new) { [weak self] reminderTasks in
                        DispatchQueue.main.async {
                            self?.getData()
                        }
                    }
                } else if action == "update" {
                    self.reminderTaskVM.updateTasksToCoreData(reminderTask: new) { [weak self] reminderTasks in
                        DispatchQueue.main.async {
                            self?.getData()                        }
                    }
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let task = response.notification.request.content.userInfo
        if !task.isEmpty {
            guard let reminderVC = storyboard?.instantiateViewController(identifier: "reminder") as? ReminderViewController else { return }
            
            reminderVC.titleText = task["title"] as? String
            reminderVC.descriptionText = task["body"] as? String
            reminderVC.dateValue = task["date"] as? Date
            reminderVC.idValue = task["id"] as? String
            reminderVC.title = "Edit Reminder"
            reminderVC.navigationItem.largeTitleDisplayMode = .never
            
            reminderVC.completionDelete = { title, description, date, id, action in
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    let new = ReminderTask(title: title, body: description, date: date, id: id)
                    if action == "delete" {
                        self.reminderTaskVM.deleteTasksFromCoreData(reminderTask: new) { [weak self] reminderTasks in
                            DispatchQueue.main.async {
                                self?.getData()
                            }
                        }
                    } else if action == "update" {
                        self.reminderTaskVM.updateTasksToCoreData(reminderTask: new) { [weak self] reminderTasks in
                            DispatchQueue.main.async {
                                self?.getData()                        }
                        }
                    }
                }
            }
            navigationController?.pushViewController(reminderVC, animated: true)
        }
        completionHandler()
    }
}
