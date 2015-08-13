//
//  NewTestViewController.swift
//  Data Entry
//
//  Created by Dax on 12/08/2015.
//  Copyright (c) 2015 Oxford Brookes. All rights reserved.
//

import UIKit

class NewTestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var testNameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var pickerView: UIPickerView!
    var activeTypeField: UITextField?
    
    var study : Study?
    var fields : [Field] = [Field]()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addField() {
        fields.append(Field("", ""))
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: fields.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelNewTest() {
        self.performSegueWithIdentifier("returnFromNewTest", sender: self)
    }
    
    @IBAction func doneNewTest() {
        if let s = study {
            if let name: String = testNameField?.text {
                if (name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
                    UIAlertView(title: "No title", message: "Please name the study.", delegate: nil, cancelButtonTitle: "OK").show()
                    return;
                }
                s.tests.append(Test(name, fields.filter({$0.name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != ""})))
                
                self.performSegueWithIdentifier("returnFromNewTest", sender: self)
                return;
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    // MARK: - PickerViewDelegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (row < stdTypes.count) {
            return stdTypes[row]
        } else {
            return nil;
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let field = activeTypeField {
            field.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        }
    }


    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewFieldCell") as! TwoFieldTableViewCell
        pickerView.dataSource = self
        cell.configure(picker: pickerView, vc: self, row: indexPath.row)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
