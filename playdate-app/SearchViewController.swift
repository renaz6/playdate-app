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
            cell.eventVenueLabel.text = eventData.venueName
            cell.eventDatesLabel.text = eventData.startDateTimeDescription
            return cell
        } else {
            return reusableCell
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query != "" else {
            return
        }
        results = events.filter {$0.title.localizedCaseInsensitiveContains(query) || $0.venueName.localizedCaseInsensitiveContains(query)} 
        self.tableView.reloadData()
        
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetail",
            let dest = segue.destination as? EventDetailViewController,
            let cell = sender as? EventTableViewCell {

            dest.event = results[cell.index]
            }
    }
    
    // code to dismiss keyboard when user clicks on background
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
