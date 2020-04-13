//
//  TMEventCollection.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-13.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

class TMEventCollection: Decodable {
    var events: [TMEvent]
}

class TMEventCollectionEmbedder: Decodable {
    var _embedded: TMEventCollection
}
