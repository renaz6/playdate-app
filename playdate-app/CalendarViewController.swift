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
    private var tableView: UITableView!
    private var events: [EventDataType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        let tableView = UITableView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height * 0.42, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.42)))
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        return reusableCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
}
