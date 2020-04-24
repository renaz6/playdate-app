//
//  CalendarViewController.swift
//  playdate-app
//
//  Created by David Sikabwe on 4/22/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate weak var calendar: FSCalendar!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var events: [EventDataType] = []
    private var eventsForThisDate: [EventDataType] = []
    private var dataSource: EventDataSource!
    private var playdateRed = UIColor(named: "High Contrast Accent")
    private var playdateRedButLighter = UIColor(displayP3Red: 196/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load calendar.
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        calendar.appearance.eventDefaultColor = playdateRed
        calendar.appearance.headerTitleColor = playdateRed
        calendar.appearance.selectionColor = playdateRedButLighter
        calendar.appearance.eventSelectionColor = playdateRedButLighter
        calendar.appearance.weekdayTextColor = .label
        calendar.appearance.titleWeekendColor = .label
        calendar.appearance.titleDefaultColor = .label
        self.calendar = calendar
        
        // Size table view.
        tableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height * 0.42, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.42))
        tableView.rowHeight = 100.0
        
        // Load all events.
        dataSource = AppDelegate.instance.dataSource
        dataSource.allEvents { events in
            self.events = events
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsForThisDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventData = eventsForThisDate[indexPath.row]
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        if let cell = reusableCell as? EventTableViewCell {
            cell.index = indexPath.row
            cell.eventId = eventData.id
            cell.eventImageView.image = UIImage(named: eventData.imageId)
            cell.eventTitleLabel.text = eventData.title
            cell.eventVenueLabel.text = eventData.venueName
            cell.eventDatesLabel.text = eventData.startDateTimeDescription
            return cell
        } else {
            return reusableCell
        }
    }

}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    // This function should return the number of events on a date,
    // represented as (at most three) dots.
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        let thisDate = dateFormat.string(from: date)
        let results = events.filter{dateFormat.string(from: $0.datesStart?.dateValue() ?? Date(timeIntervalSince1970: 0.0)) == thisDate}
        
        return results.count
    }
    
    // This function is called when you select a day.
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        let thisDate = dateFormat.string(from: date)
        
        // If datesStart is nil, thisDate will be compared to January 1, 1970.
        self.eventsForThisDate = events.filter{dateFormat.string(from: $0.datesStart?.dateValue() ?? Date(timeIntervalSince1970: 0.0)) == thisDate}
        
        self.tableView.reloadData()
    }
    
}
