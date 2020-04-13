//
//  EventDataSource.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

protocol EventDataSource {
    
    func homePageEvents(completion: @escaping ([EventDataType]) -> Void)
    
    func starredEvents(completion: @escaping ([EventDataType]) -> Void)
    
    func searchEvents(_: String, completion: @escaping ([EventDataType]) -> Void)
    
    func searchEvents(_: String, withCategory: String, completion: @escaping ([EventDataType]) -> Void)
    
    func event(withId: String, completion: @escaping (EventDataType?) -> Void)
    
    func isEventStarred(withId: String, completion: @escaping (Bool) -> Void)
    
    func setEventStarred(withId: String, starred: Bool, completion: @escaping (Bool) -> Void)
}
