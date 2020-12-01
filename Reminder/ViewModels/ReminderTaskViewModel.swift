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
    
    func addTasksToCoreData(completion: @escaping (Result<[ReminderTask], Error>) -> Void) {
        
    }
}
