//
//  ReminderViewController.swift
//  Reminder
//
//  Created by admin on 17/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var titleText: String?
    var descriptionText: String?
    var dateValue: Date?
    var idValue: String?
    
    public var completion: ((String, String, Date) -> Void)?
    public var completionDelete: ((String, String, Date, String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        descriptionField.delegate = self
        titleField.text = titleText
        descriptionField.text = descriptionText
        datePicker.setDate(dateValue ?? Date(), animated: true)
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(didTapDelete))
        
        var buttons = [saveButton]
        
        if self.title == "Edit Reminder" {
            buttons.append(deleteButton)
        }
        
        navigationItem.rightBarButtonItems = buttons
    }

    @objc func didTapSave() {
        if let titleText = titleField.text, !titleText.isEmpty,
            let descriptionText = descriptionField.text, !descriptionText.isEmpty {
            let scheduledDate = datePicker.date
            if self.title == "Edit Reminder" {
                completionDelete?(titleText, descriptionText, scheduledDate, idValue!, "update")
            } else {
                completion?(titleText, descriptionText, scheduledDate)
            }
        }
    }
    
    @objc func didTapDelete() {
        completionDelete?(titleText!, descriptionText!, dateValue!, idValue!, "delete")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
