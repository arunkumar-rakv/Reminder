//
//  ReminderTests.swift
//  ReminderTests
//
//  Created by admin on 15/11/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import XCTest
@testable import Reminder

class ReminderTests: XCTestCase {
    
    var reminderTaskVM = ReminderTaskViewModel()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdd() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let newTask = ReminderTask(title: "New", body: "New Body", date: Date(), id: UUID().uuidString)
        reminderTaskVM.addTasksToCoreData(reminderTask: newTask) { reminderTask in
            XCTAssertNotNil(reminderTask)
            XCTAssertTrue(try! reminderTask.get().title == "New")
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
