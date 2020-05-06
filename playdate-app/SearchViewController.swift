//
//  SearchViewController.swift
//  playdate-app
//
//  Created by David Sikabwe on 4/7/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    private var events: [EventDataType] = []
    private var results: [EventDataType] = []
    private var dataSource: EventDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        dataSource = AppDelegate.instance.dataSource
        dataSource.allEvents { events in
            self.events = events
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventData = results[indexPath.row]
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        if let cell = reusableCell as? EventTableViewCell {
            cell.index = indexPath.row
            cell.eventId = eventData.id
            cell.eventImageView.image = UIImage(named: eventData.imageId)
            cell.eventTitleLabel.text = eventData.title
            cell.eventTitleLabel.font = UIFont(name: "Gibson-Bold", size: 20)
            cell.eventVenueLabel.text = eventData.venueName
            cell.eventVenueLabel.font = UIFont(name: "Gibson-Regular", size: 18)
            cell.eventDatesLabel.text = eventData.startDateTimeDescription
            cell.eventDatesLabel.font = UIFont(name: "Gibson-Regular", size: 18)
            return cell
        } else {
            return reusableCell
        }
    }
    
    // Scope button changed
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        let index = selectedScope
        
        switch index {
        case 0:
            dataSource.allEvents { events in
                self.events = events
                self.performQuery()
            }
            
        case 1:
            dataSource.eventsWithCategory("Theatre") { events in
                self.events = events
                self.performQuery()
            }
            
        case 2:
        dataSource.eventsWithCategory("Music") { events in
            self.events = events
            self.performQuery()
        }
            
        case 3:
        dataSource.eventsWithCategory("Comedy") { events in
            self.events = events
            self.performQuery()
        }
            
        case 4:
        dataSource.eventsWithCategory("Fine Art") { events in
            self.events = events
            self.performQuery()
        }
            
        case 5:
        dataSource.eventsWithCategory("miscellaneous") { events in
            self.events = events
            self.performQuery()
        }
            
        default:
            dataSource.allEvents { events in
                self.events = events
                self.performQuery()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        performQuery()
        searchBar.resignFirstResponder()
    }
    
    func performQuery() {
        guard let query = searchBar.text, query != "" else {
            return
        }
        results = events.filter {$0.title.localizedCaseInsensitiveContains(query) || $0.venueName.localizedCaseInsensitiveContains(query)}
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetail",
            let dest = segue.destination as? EventDetailViewController,
            let cell = sender as? EventTableViewCell {

            dest.event = results[cell.index]
        }
    }
    
    // dismiss keyboard on background touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
