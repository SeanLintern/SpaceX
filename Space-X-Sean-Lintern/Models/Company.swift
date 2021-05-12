import Foundation

struct Company: Codable {
    let name: String
    let founder: String
    let founded: Int
    let employees: Int
    let launchSites: Int
    let valuation: Int
}

/*
 {
   "name": "SpaceX",
   "founder": "Elon Musk",
   "founded": 2002,
   "employees": 7000,
   "vehicles": 3,
   "launch_sites": 3,
   "test_sites": 1,
   "ceo": "Elon Musk",
   "cto": "Elon Musk",
   "coo": "Gwynne Shotwell",
   "cto_propulsion": "Tom Mueller",
   "valuation": 15000000000,
   "headquarters": {
     "address": "Rocket Road",
     "city": "Hawthorne",
     "state": "California"
   },
   "summary": "SpaceX designs, manufactures and launches advanced rockets and spacecraft. The company was founded in 2002 to revolutionize space technology, with the ultimate goal of enabling people to live on other planets."
 }
*/
