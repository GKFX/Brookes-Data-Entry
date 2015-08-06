//
//  NewStudyTableViewController.swift
//  Data Entry
//
//  Created by Dax on 04/08/2015.
//  Copyright (c) 2015 Oxford Brookes. All rights reserved.
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

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
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
