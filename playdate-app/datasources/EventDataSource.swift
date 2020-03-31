//
//  EventDataSource.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

public protocol EventDataSource {
    
    func homePageEvents() -> [[String: Any]]
    
    func searchEvents(_: String) -> [[String: Any]]
    
    func searchEvents(_: String, withCategory: String) -> [[String: Any]]
    
    func event(withId: String) -> [String: Any]?
}
