//
// StudySaver.swift
// Brookes Data Entry
//
// Created by George Bateman on 30 July 2015.
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


import Foundation
import MessageUI


// Apparently no standard XML writer on iOS.
class StudySaver: NSObject, MFMailComposeViewControllerDelegate {
    let docsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    
    func saveStudy(id: String, study: Study) -> () {
        var xmlOut = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xmlOut += xmlFormat("<study name=\"%@\">\n", study.name)
        xmlOut += "  <plan>\n"
        for dataType in study.customDataTypes {
            xmlOut += xmlFormat("    <data-type name=\"%@\">\n", dataType.name)
            for field in dataType.fields {
                xmlOut += xmlFormat("       <value name=\"%@\" type=\"%@\" />\n", field.name, field.type)
            }
            xmlOut += "    </data-type>\n"
        }
        for test in study.tests {
            xmlOut += xmlFormat("    <test name=\"%@\">\n", test.name)
            for field in test.fields {
                xmlOut += xmlFormat("       <value name=\"%@\" type=\"%@\" />\n", field.name, field.type)
            }
            xmlOut += "    </test>"
        }
        xmlOut += "  </plan>\n"
        
        xmlOut += "  <results>\n"
        for participant in study.results {
            xmlOut += xmlFormat("    <participant id=\"%@\">\n", "\(participant.id)")
            for test in participant.testsRun {
                xmlOut += xmlFormat("      <test name=\"%@\">\n", test.name)
                for value in test.values {
                    // No pretty-printing!!
                    xmlOut += xmlFormat("        <value name=\"%@\">%@</value>\n", value.name)
                }
                xmlOut += "      </test>\n"
                if (participant.notes != "") {
                    xmlOut += xmlFormat("      <note>%@</note>\n", participant.notes)
                }
            }
            xmlOut += "  </participant>\n"
        }
        xmlOut += "  </results>\n"
        xmlOut += "</study>"
        
        xmlOut.writeToFile(docsPath + "/study_\(id).xml", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func xmlFormat(str: String, _ args: String...) -> String {
        return String(format: str, arguments: args.map({
            $0.stringByReplacingOccurrencesOfString("&",  withString: "&amp;")
              .stringByReplacingOccurrencesOfString("<",  withString: "&lt;")
              .stringByReplacingOccurrencesOfString(">",  withString: "&gt;")
              .stringByReplacingOccurrencesOfString("\"", withString: "&quot;")
              .stringByReplacingOccurrencesOfString("'",  withString: "&apos;")
              as NSString
        }))
    }
    
    
    /**
     * Export to CSV in an email popup.
     * See RFC 4180 at https://tools.ietf.org/html/rfc4180
     */
    func exportStudy(study: Study, viewController: UIViewController) {
        let CRLF = "\r\n"
        var noCols = 0
        for t: Test in study.tests {
            noCols += t.fields.count
        }
        if (noCols <= 0) {
            UIAlertView(title: "No fields",
                message: "You must have some data before you export it.",
                delegate: nil,
                cancelButtonTitle: "OK").show()
            return
        }
        
        var csvOut = csvEscape(study.name) + String(count: noCols - 1, repeatedValue: Character(",")) + CRLF
        for var i = 0; i < study.tests.count; i++ {
            if (study.tests[i].fields.count == 0) { continue }

            csvOut += csvEscape(study.tests[i].name) + String(count: (i == study.tests.count - 1)
                ? study.tests[i].fields.count - 1 : study.tests[i].fields.count, repeatedValue: Character(","))
        }
        csvOut += CRLF
        
        for var i = 0; i < study.tests.count; i++ {
            if (study.tests[i].fields.count == 0) { continue }
            for var j = 0; j < study.tests[i].fields.count; j++ {
                csvOut += csvEscape(study.tests[i].fields[j].name)
                if (i < study.tests.count - 1) || (j < study.tests[i].fields.count - 1) {
                    csvOut += ","
                }
            }
        }
        csvOut += CRLF
        
        for participant in study.results {
            for var i = 0; i < study.tests.count; i++ {
                if (study.tests[i].fields.count == 0) { continue }
                for var j = 0; j < study.tests[i].fields.count; j++ {
                    csvOut += csvEscape(getResultOfTest(participant.testsRun, testName: study.tests[i].name,
                        fieldName: study.tests[i].fields[j].name) ?? "")
                    if (i < study.tests.count - 1) || (j < study.tests[i].fields.count - 1) {
                        csvOut += ","
                    }
                }
            }
            csvOut += CRLF
        }

        if let csvData = (csvOut as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setMessageBody("Exported data from Brookes Data Entry.", isHTML: false)
            var r: NSRange = NSRange(location: 0, length: count(study.name))
            mailVC.addAttachmentData(csvData, mimeType: "text/csv", fileName: "\(study.name).csv")
        
            if MFMailComposeViewController.canSendMail() {
                viewController.presentViewController(mailVC, animated: true, completion: nil)
            } else {
                UIAlertView(title: "Cannot send file as email",
                   message: "Set up your email correctly and try again.",
                   delegate: nil,
                   cancelButtonTitle: "OK").show()
            }
        }
    }
    
    // MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getResultOfTest(testsRun: [TestRun], testName: String, fieldName: String) -> (String?) {
        for testRun: TestRun in testsRun {
            if (testRun.name == testName) {
                for value: Value in testRun.values {
                    if (value.name == fieldName) {
                        return value.content
                    }
                }
            }
        }
        return nil
    }

    func csvEscape(var str: String) -> String {
        str = str.stringByReplacingOccurrencesOfString("\r", withString: "")
                 .stringByReplacingOccurrencesOfString("\n", withString: "\r\n")
        if let x = str.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "\n\",")) {
            return "\"" + str.stringByReplacingOccurrencesOfString("\"", withString: "\"\"") + "\""
        } else {
            return str
        }
    }
}
