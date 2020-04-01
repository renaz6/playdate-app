//
//  EventsHomeViewController.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-03-18.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit

class EventsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let eventDetailSegueId = "homeToEventDetail"
    
    private var dataSource: EventDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource = MockDataSource()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.homePageEvents().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventData = dataSource.homePageEvents()[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        (cell.contentView.viewWithTag(1) as? UIImageView)?.image = UIImage(systemName: eventData["imageId"] as! String)
        (cell.contentView.viewWithTag(2) as? UILabel)?.text = eventData["title"] as? String
        (cell.contentView.viewWithTag(3) as? UILabel)?.text = eventData["venue"] as? String
        (cell.contentView.viewWithTag(4) as? UILabel)?.text = describeDate(eventData["startDate"] as? Date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: eventDetailSegueId, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == eventDetailSegueId,
//            let dest = segue.destination as? EventDetailViewController,
//            let ip = sender as? IndexPath {
//
//            dest.event = dataSource.homePageEvents()[ip.row]
//        }
    }
    
    private func describeDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormat = DateFormatter()
            let timeFormat = DateFormatter()
            dateFormat.dateStyle = .medium
            timeFormat.timeStyle = .short
            
            return dateFormat.string(from: date) + ", " + timeFormat.string(from: date)
        } else {
            return ""
        }
    }
}
