//
//  EventDetailViewController.swift
//  playdate-app
//
//  Created by Serena  Zamarripa on 4/3/20.
//  Copyright © 2020 Serena Zamarripa. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    var event: Int!
    private var dataSource: EventDataSource!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = MockDataSource()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let eventData = dataSource.homePageEvents()[event]
        
        imageOutlet.image = UIImage(systemName: eventData["imageId"] as! String)
        eventName.text = eventData["title"] as? String
        eventLocation.text = eventData["venue"] as? String
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
