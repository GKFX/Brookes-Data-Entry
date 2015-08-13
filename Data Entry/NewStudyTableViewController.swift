//
// NewStudyTableViewController.swift
// Brookes Data Entry
//
// Created by George Bateman, 2015.
//
// This file is part of Brookes Data Entry.
//
// Brookes Data Entry is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Brookes Data Entry is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Brookes Data Entry.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class NewStudyTableViewController: UITableViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        studyNameField.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    
    
    // MARK: - Text field
    
    @IBOutlet weak var studyNameField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //    // Get the new view controller using [segue destinationViewController].
    //    // Pass the selected object to the new view controller.
    //}
    
    @IBAction func clickOnCancelButton() {
        self.performSegueWithIdentifier("closeNewStudy", sender: self)
    }
    
    @IBAction func clickOnDoneButton() {
        var newStudy = Study()
        newStudy.name = studyNameField.text
        let studyLoader: StudyLoader = StudyLoader()
        if contains(studyLoader.listStudies(), newStudy.name) {
            let alert = UIAlertView(title: "Name taken",
                message: "The name \"\(newStudy.name)\" is taken.",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        } else if newStudy.name.isEmpty {
            let alert = UIAlertView(title: "No name",
                message: "You must provide a name.",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        } else {
            let studySaver = StudySaver()
            studySaver.saveStudy(newStudy.name, study: newStudy)
            self.performSegueWithIdentifier("closeNewStudy", sender: self)
        }
    }
}
