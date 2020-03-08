//
//  MockDataSource.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

public class MockDataSource: EventDataSource {
    
    let events = [
        EventData(title: "Event 1", venue: "asdf", imageId: "calendar", startDate: Date()),
        EventData(title: "Event 2", venue: "ghjkl", imageId: "calendar", startDate: Date()),
        EventData(title: "Event 3", venue: "qwerty", imageId: "calendar", startDate: Date())
    ]
    
    public func homePageEvents() -> [EventData] {
        return events
    }
}
