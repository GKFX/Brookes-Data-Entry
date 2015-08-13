//
//  TwoFieldTableViewCell.swift
//  Data Entry
//
//  Created by Dax on 12/08/2015.
//  Copyright (c) 2015 Oxford Brookes. All rights reserved.
//

import UIKit

class TwoFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    var picker: UIPickerView!
    var row: Int = 0
    var view: NewTestViewController?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshContent() {
        nameField.text = view?.fields[row].name
        typeField.text = view?.fields[row].type
    }
    
    
    func configure(picker p: UIPickerView, vc: NewTestViewController, row n: Int) {
        self.picker = p
        self.row = n
        self.view = vc
        if (nameField.delegate !== self) {
            nameField.delegate = self
        }
        if (typeField.delegate !== self) {
            typeField.delegate = self
        }
        typeField.inputView = picker
        refreshContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField === typeField) {
            view?.activeTypeField = typeField
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        view?.fields[row].name = nameField.text ?? ""
        view?.fields[row].type = typeField.text ?? ""
        view?.activeTypeField = nil
    }
}
