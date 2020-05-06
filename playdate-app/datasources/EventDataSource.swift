//
//  EventDataSource.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

protocol EventDataSource {
    
    func allEvents(completion: @escaping ([EventDataType]) -> Void)
    
    func eventsOnDate(year: Int, month: Int, day: Int, completion: @escaping ([EventDataType]) -> Void)
    
    func eventsWithCategory(_: String, completion: @escaping ([EventDataType]) -> Void)
    
    func homePageEvents(completion: @escaping ([EventDataType]) -> Void)
    
    func starredEvents(completion: @escaping ([EventDataType]) -> Void)
    
    // not used
    func searchEvents(_: String, completion: @escaping ([EventDataType]) -> Void)
    
    // not used
    func searchEvents(_: String, withCategory: String, completion: @escaping ([EventDataType]) -> Void)
    
    func event(withId: String, completion: @escaping (EventDataType?) -> Void)
    
    func isEventStarred(withId: String, completion: @escaping (Bool) -> Void)
    
    func setEventStarred(withId: String, starred: Bool, completion: @escaping (Bool) -> Void)
}
