//
//  ReminderTaskViewModel.swift
//  Reminder
//
//  Created by admin on 17/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ReminderTaskViewModel {
    
    var reminderTasks: [ReminderTask] = []
    var reminderDM: [NSManagedObject] = []
    
    init(model: [ReminderTask]? = nil) {
        if let inputModel = model {
            reminderTasks = inputModel
        }
    }
}

extension ReminderTaskViewModel {
    
    func fetchReminderTasks(completion: @escaping (Result<[ReminderTask], Error>) -> Void) {
        completion(.success(reminderTasks))
    }
    
    func addReminderTask(completion: @escaping (Result<[ReminderTask], Error>) -> Void) {
        completion(.success(reminderTasks))
    }
    
    func fetchTasksFromCoreData(completion: @escaping (Result<[ReminderTask], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        do {
            reminderDM = try managedContext.fetch(fetchRequest)
            
            reminderTasks = []
            for task in reminderDM {
                let reminderTask = ReminderTask(title: (task.value(forKey: "title") as? String)!, body: (task.value(forKey: "body") as? String)!, date: (task.value(forKey: "date") as? Date)!, id: (task.value(forKey: "id") as? String)!)
//            reminderTask.title = task.value(forKey: "title") as? String
//            reminderTask.body = task.value(forKey: "body") as? String
//            reminderTask.date = task.value(forKey: "date") as? Date
//            reminderTask.id = task.value(forKey: "id") as? String
                reminderTasks.append(reminderTask)
            }
            completion(.success(reminderTasks))
        } catch let error as NSError {
            print("Fetch Errro: \(error)")
        }
    }
    
    func addTasksToCoreData(reminderTask: ReminderTask, completion: @escaping (Result<ReminderTask, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)
        let task = NSManagedObject(entity: entity!, insertInto: managedContext)
        task.setValue(reminderTask.title, forKey: "title")
        task.setValue(reminderTask.date, forKey: "date")
        task.setValue(reminderTask.body, forKey: "body")
        task.setValue(reminderTask.id, forKey: "id")
        do {
            try managedContext.save()
            reminderDM.append(task)
            reminderTasks.append(reminderTask)
            completion(.success(reminderTask))
        } catch let error as NSError {
            print("Saving Error: \(error)")
        }
    }
    
    func deleteTasksFromCoreData(reminderTask: ReminderTask, completion: @escaping (Result<[ReminderTask], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id = %@", reminderTask.id)
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            let task = data[0]
            managedContext.delete(task)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderTask.id])
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch let error as NSError {
            print("Saving Error: \(error)")
        }
    }
    
    func updateTasksToCoreData(reminderTask: ReminderTask, completion: @escaping (Result<[ReminderTask], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id = %@", reminderTask.id)
        
        do {
            let data = try managedContext.fetch(fetchRequest)
            let task = data[0]
            
            task.setValue(reminderTask.title, forKey: "title")
            task.setValue(reminderTask.body, forKey: "body")
            task.setValue(reminderTask.date, forKey: "date")
                
            Notification().addNotification(reminderTask: reminderTask)
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch let error as NSError {
            print("Saving Error: \(error)")
        }
    }
}
