//
//  JournalsTableViewController.swift
//  Paradigm
//
//  Created by Isha Mahadalkar on 3/15/21.
//  Copyright © 2021 team5. All rights reserved.
//

import UIKit

struct Journal {
    var id : Int
    var created : Date
    var lastedited : Date
    var hidden : Int
    var sentiment : String
    var sentScore : Double
    var rating : Int
    var entry : String
    var topics : String
}

func retToJournal(retjournals: [RetJournal]) -> [Journal] {
    var journals:[Journal] = []
    
    for retjournal in retjournals {
        let journal = Journal(id: Int(retjournal.jourID)!, created: parseDate(retjournal.created), lastedited: parseDate(retjournal.lastEdited), hidden: Int(retjournal.hidden)!, sentiment: retjournal.sentiment, sentScore: Double(retjournal.sentScore)!, rating: Int(retjournal.rating)!, entry: retjournal.entry, topics: retjournal.topics)
        journals.append(journal)
    }
    
    return journals
}

func parseDate(_ str : String) -> Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormat.date(from: str)!
}

// Computing first day of the month
func firstDayOfMonth(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components)!
}

// Grouping the Sections and ordering them by month and year
struct MonthSection {
    var month: Date
    var journals: [Journal]
    
    static func group(journals : [Journal]) -> [MonthSection] {
        let groups = Dictionary(grouping: journals) { journal in
            firstDayOfMonth(date: journal.created)
        }
        return groups.map(MonthSection.init(month:journals:))
    }
}

class JournalsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    var numJournals = "0"
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelNum: UILabel!
    
    // Journals Array
    
    var journals: [Journal] = []
    
    // Implementing the Search Bar
    var searchController = UISearchController(searchResultsController: nil)
    var filteredJournals:[Journal] = []
    
    // Checking if the text typed in the search bar is empty
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // Checking if the search bar is active
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return "Results"
        }
        let section = self.sections[section]
        let date = section.month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredJournals.count
        }
        let sect = self.sections[section]
        return sect.journals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Journal Cell", for: indexPath)
        
        let section = self.sections[indexPath.section]
        
        let journal: Journal
        
        if isFiltering {
            journal = filteredJournals[indexPath.row]
            labelNum.text = String(filteredJournals.count)
        }
        else {
            journal = section.journals[indexPath.row]
            labelNum.text = numJournals
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en-US")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE, `MMM d")
        
        cell.textLabel?.text = dateFormatter.string(from: journal.created)
        
        // Only show the contents of the topics if the journal is not hidden
        if (journal.hidden == 0) {
            cell.detailTextLabel?.text = journal.topics
        }
        else {
            cell.detailTextLabel?.text = "Hidden"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if it selects a "hidden" cell
        
        if (self.journals[indexPath.row].hidden == 1) {
            // Show alert

            let alert = UIAlertController(title: "Hidden Journal", message: "Unhide the journal to view the detailed content.", preferredStyle: .alert)
            alert.addAction(UIAlertAction( title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            // Only perforing the segue if the Journal is not hidden
            self.performSegue(withIdentifier: "detailJournalSegue", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath)
        
        if (self.journals[indexPath.row].hidden == 0) {
            let hideAction = UIContextualAction(style: .normal, title: "Hide") { (action, view, completionHandler) in
                // Hide the journal data
                cell?.detailTextLabel?.text = "Hidden"
                
                // Updating the journal's hidden attribute
                self.journals[indexPath.row].hidden = 1
                
                // TODO: Update the hidden status in the database
                let ret = hideJournal(jourID: self.journals[indexPath.row].id)
                print(ret)
                // After completing what we had to do
                completionHandler(true)
                
            }
                hideAction.backgroundColor = .systemGray
                let configuration = UISwipeActionsConfiguration(actions: [hideAction])
                configuration.performsFirstActionWithFullSwipe = false
                return configuration
        }
        else {
            let hideAction = UIContextualAction(style: .normal, title: "Unhide") { (action, view, completionHandler) in
                // Unhide the journal data
                cell?.detailTextLabel?.text = self.journals[indexPath.row].topics
                
                // Updating the journal's hidden attribute
                self.journals[indexPath.row].hidden = 0
                
                // TODO: Update the hidden status in the database
                let ret = unhideJournal(jourID: self.journals[indexPath.row].id)
                print(ret)
                // After completing what we had to do
                completionHandler(true)
                    
            }
                hideAction.backgroundColor = .gray
                let configuration = UISwipeActionsConfiguration(actions: [hideAction])
                configuration.performsFirstActionWithFullSwipe = false
                return configuration
        }
        
    }
    
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    var sections = [MonthSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        journals = retToJournal(retjournals: getJournals(userID: Int(Utils.global_userID)!))

        // Do any additional setup after loading the view.
        self.sections = MonthSection.group(journals: self.journals)
        
        // Sorting the sections
        self.sections.sort { (lhs, rhs) in lhs.month < rhs.month }
        
        // Implementing Search Bar
        // Inform the class of any text changes in the search bar
        searchController.searchResultsUpdater = self
        
        // Show the information in the current view
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Journals"
        
        // Adding the search bar to the Navigation Item
        navigationItem.searchController = searchController
        
        // Exit Search Bar if user navigates to different page
        definesPresentationContext = true
        
        //get number of journals written by user
        numJournals = getJournalNum(userID: Utils.global_userID)
        labelNum.text = numJournals
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
        journals = retToJournal(retjournals: getJournals(userID: Int(Utils.global_userID)!))
        self.tableView.reloadData()
        
    }
    
    
    func getJournalNum(userID: String) -> String {
        let semaphore = DispatchSemaphore (value: 0)
        var ret = "";
        
        let link = "https://boilerbite.000webhostapp.com/paradigm/getJournalNum.php"
        let request = NSMutableURLRequest(url: NSURL(string: link)! as URL)
        request.httpMethod = "POST"
        
        let postString = "userID=\(userID)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                print("ERROR")
                print(String(describing: error!))
                ret = "ERROR"
                semaphore.signal()
                return
            }
            
            print("PRINTING DATA")
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            ret = String(describing: responseString!)
            semaphore.signal()
            print(ret)
        }
        task.resume()
        semaphore.wait()
        return ret
    }

    func filterContentForSearchText(_ searchText: String) {
      filteredJournals = journals.filter { (journal: Journal) -> Bool in
        return journal.entry.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destination as? DetailViewController
        let section = sections[tableView.indexPathForSelectedRow!.section].journals
        
        let journal: Journal
        if isFiltering {
            journal = filteredJournals[tableView.indexPathForSelectedRow!.row]
        }
        else {
            journal = section[tableView.indexPathForSelectedRow!.row]
        }
        
        // Send the current selected journal data to the Detail View Controller
        vc?.journal = journal
        vc?.journID = journal.id
    }
    

}


