//
//  HomeVCExtensions.swift
//  Reminder
//
//  Created by admin on 17/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension HomeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderTaskVM.reminderTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let task = reminderTaskVM.reminderTasks[indexPath.row]
            //reminderDM[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = reminderTaskVM.reminderTasks[indexPath.row].title
            //task.value(forKey: "title") as? String
        
        let date = reminderTaskVM.reminderTasks[indexPath.row].date
            //task.value(forKey: "date") as? Date
            
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, dd, YYYY"
        cell.detailTextLabel?.text = dateFormatter.string(from: date)
        
        return cell
    }
}
