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
    func saveStudy(id: Int, study: Study) -> () {
        var xmlOut = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xmlOut += xmlFormat("<study name=\"%s\">\n", study.name)
        xmlOut += "  <plan>\n"
        for dataType in study.customDataTypes {
            xmlOut += xmlFormat("    <data-type name=\"%s\">\n", dataType.name)
            for field in dataType.fields {
                xmlOut += xmlFormat("       <value name=\"%s\" type=\"%s\" />\n", field.name, field.type)
            }
            xmlOut += "    </data-type>\n"
        }
        for test in study.tests {
            xmlOut += xmlFormat("    <test name=\"%s\">\n", test.name)
            for field in test.fields {
                xmlOut += xmlFormat("       <value name=\"%s\" type=\"%s\" />\n", field.name, field.type)
            }
        }
        xmlOut += "  </plan>\n"
        
        xmlOut += "  <results>\n"
        for participant in study.results {
            xmlOut += xmlFormat("    <participant id=\"%s\">\n", "\(participant.id)")
            for test in participant.testsRun {
                xmlOut += xmlFormat("      <test name=\"%s\">\n", test.name)
                for value in test.values {
                    // No pretty-printing!!
                    xmlOut += xmlFormat("        <value name=\"%s\">%s</value>\n", value.name)
                }
                xmlOut += "      </test>"
            }
            xmlOut += "  </participant>\n"
        }
        xmlOut += "  </results>\n"
        xmlOut += "</study>"
    }
    
    func xmlFormat(str: String, _ args: String...) -> String {
        return String(format: str, arguments: args.map({
            $0.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
              .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
              .stringByReplacingOccurrencesOfString(">", withString: "&gt;")
              .stringByReplacingOccurrencesOfString("\"", withString: "&quot;")
              .stringByReplacingOccurrencesOfString("'", withString: "&apos;")
        }))
    }
}
