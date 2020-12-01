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

class HomeViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    //var reminderTasks = [ReminderTask]()
    var notificationPermission: Bool = false
    var reminderTaskVM = ReminderTaskViewModel()
    var reminderDM: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getPermission()
        //table.reloadData()
        //getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
//        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
//        do {
//            reminderDM = try managedContext.fetch(fetchRequest)
//        } catch let error as NSError {
//            print("Fetch Errro: \(error)")
//        }
    }
    
    func getData() {
        reminderTaskVM.fetchTasksFromCoreData { [weak self] reminderTasks in
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
    }
    
    func getPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, error in
            if granted {
                self.notificationPermission = true
            } else if error != nil {
                print("Error: \(error)")
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
                //let new = ReminderTask(title: title, date: date, id: UUID().uuidString)
                //self.reminderTaskVM.reminderTasks.append(new)
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)
                let task = NSManagedObject(entity: entity!, insertInto: managedContext)
                task.setValue(title, forKey: "title")
                task.setValue(date, forKey: "date")
                task.setValue(description, forKey: "body")
                let id = UUID().uuidString
                task.setValue(id, forKey: "id")
                do {
                    try managedContext.save()
                    self.reminderDM.append(task)
                } catch let error as NSError {
                    print("Saving Error: \(error)")
                }
                
                self.table.reloadData()
                
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = description
                
                let scheduledDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledDate), repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("error: \(error)")
                    }
                })
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
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
                fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                
                do {
                    let data = try managedContext.fetch(fetchRequest)
                    let task = data[0]
                    if action == "delete" {
                        managedContext.delete(task)
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    } else if action == "update" {
                        task.setValue(title, forKey: "title")
                        task.setValue(description, forKey: "body")
                        task.setValue(date, forKey: "date")
                        
                        let center = UNUserNotificationCenter.current()
                        let content = UNMutableNotificationContent()
                        content.title = title
                        content.sound = .default
                        content.body = description
                        
                        let scheduledDate = date
                        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledDate), repeats: false)
                        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                        center.add(request, withCompletionHandler: { error in
                            if error != nil {
                                print("error: \(error)")
                            }
                        })
                    }
                    do {
                        try managedContext.save()
                    } catch {
                        print(error)
                    }
                } catch let error as NSError {
                    print("Saving Error: \(error)")
                }
                self.getData()
            }
        }
    }
}

