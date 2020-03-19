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
        EventData(title: "Event 1", venue: "Venue 1", imageId: "calendar", startDate: Date()),
        EventData(title: "Event 2", venue: "Venue 2", imageId: "calendar", startDate: Date()),
        EventData(title: "Event 3", venue: "Venue 3", imageId: "calendar", startDate: Date())
    ]
    
    public func homePageEvents() -> [EventData] {
        return events
    }
}
