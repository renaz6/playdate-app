//
//  TMEvent.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-12.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

class TMEvent: Decodable {
    var name: String
    var id: String
    var url: String
    var info: String?
    
    var classifications: [TMClassification]
    
    var images: [TMImage]
    
    var _embedded: TMEventEmbedding
}

class TMEventEmbedding: Decodable {
    var venues: [TMVenue]
}

class TMVenue: Decodable {
    var name: String
    var id: String
    var timezone: String
    var images: [TMImage]?
    
    var address: TMAddress?
    var city: TMCity?
    var state: TMState?
    var postalCode: String?
    
    var location: TMGeoPoint?
    
    class TMAddress: Decodable {
        var line1: String
        var line2: String?
    }
    
    class TMCity: Decodable {
        var name: String
    }
    
    class TMState: Decodable {
        var name: String
        var stateCode: String
    }
    
    class TMGeoPoint: Decodable {
        var latitude: Double
        var longitude: Double
    }
}

class TMDates: Decodable {
    var start: TMDate
    var status: TMStatusCode
    
    class TMDate: Decodable {
        var localDate: String?
        var localTime: String?
        var dateTime: String?
        var dateTBD: Bool
        var dateTBA: Bool
        var timeTBA: Bool
        var noSpecificTime: Bool
    }
    
    class TMStatusCode: Decodable {
        var code: String
    }
}

class TMClassification: Decodable {
    var primary: Bool
    var segment: TMSubClassification
    var genre: TMSubClassification
    var subGenre: TMSubClassification
    var family: Bool
}

class TMSubClassification: Decodable {
    var id: String
    var name: String
}

class TMImage: Decodable {
    var ratio: String
    var url: String
    var width: Int
    var height: Int
    var fallback: Bool
    var attribution: String?
}
