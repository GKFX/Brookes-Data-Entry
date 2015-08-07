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


// Apparently no standard XML writer on iOS.
class StudySaver {
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
                xmlOut += "      </test>"
            }
            xmlOut += "  </participant>\n"
        }
        xmlOut += "  </results>\n"
        xmlOut += "</study>"
        
        xmlOut.writeToFile(docsPath + "/study_\(id).xml", atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func xmlFormat(str: String, _ args: String...) -> String {
        return String(format: str, arguments: args.map({
            $0.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
              .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
              .stringByReplacingOccurrencesOfString(">", withString: "&gt;")
              .stringByReplacingOccurrencesOfString("\"", withString: "&quot;")
              .stringByReplacingOccurrencesOfString("'", withString: "&apos;")
              as NSString
        }))
    }
    
    
    func exportStudy(study: Study) {
        var noCols = 0
        for (t: Test in study.tests) {
            noCols += t.fields.count
        }
        if (noCols <= 0) {
            UIAlertView(title: "No fields",
                message: "You must have some data before you export it.",
                delegate: nil,
                cancelButtonTitle: "OK").show()
            return
        }
        
        var csvOut = study.name + String(count: noCols - 1, repeatedValue: Character(",")) + "\n"
        for t: Test in study.tests {
            if (t.fields.count == 0) { continue }
            csvOut += t.name + String(count: t.fields.count - 1, repeatedValue: Character(","))
        }
        csvOut += "\n"
        
        for var i = 0; i < study.tests.count; i++ {
            for var j = 0; j < study.tests[i].fields.count; j++ {
                csvOut += study.tests[i].fields[j].name
                if (i < study.tests.count - 1) || (j < study.tests[i].fields.count - 1) {
                    csvOut += ","
                }
            }
        }
        csvOut += "\n"
        
        for participant in study.results {
            for var i = 0; i < study.tests.count; i++ {
                for var j = 0; j < study.tests[i].fields.count; j++ {
                    csvOut += getResultOfTest(participant.testsRun, testName: study.tests[i].name, study.tests[i].fields[j].name)
                    if (i < study.tests.count - 1) || (j < study.tests[i].fields.count - 1) {
                        csvOut += ","
                    }
                }
            }
            csvOut += "\n"
        }
    }
    
    func getResultOfTest(testsRun: [TestRun], testName: String, fieldName: String) -> (String?) {
        for testRun: TestRun in testsRun {
            if (testRun.name == testName) {
                for value: Value in testRun {
                    if (value.name == fieldName) {
                        return value.content
                    }
                }
            }
        }
        return nil
    }
}
