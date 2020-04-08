//
//  EventUserInteractionManager.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-07.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

protocol EventUserInteractionManager {
    
    func setEventStarred(withId id: String, starred: Bool) -> Bool
}
