//
//  EventData.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

public class EventData {
    
    public var title: String
    public var venueName: String
    public var imageId: String
    public var startDate: Date
    public var endDate: Date?
    
    init(title: String, venue: String, imageId: String, startDate: Date, endDate: Date? = nil) {
        self.title = title
        self.venueName = venue
        self.imageId = imageId
        self.startDate = startDate
        self.endDate = endDate
    }
}
