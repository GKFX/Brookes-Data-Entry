//
// StudyLoader.swift
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


class StudyLoader : NSObject, NSXMLParserDelegate {
    var state:    Int      = 0
    var study:    Study    = Study()
    var dataType: DataType = ("", [Field]())
    var test:     Test     = ("", [Field]())
    var testRun:  TestRun  = ("", [Value]())
    var valueName: String? = nil
    var elemCont: String   = ""
    var participant        = Participant()


    /// List names of studies for use with loadStudy
    func listStudies() -> [String] {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        println(path)
        let filemgr = NSFileManager.defaultManager()
        var error: NSError?
        let filelist = filemgr.contentsOfDirectoryAtPath(path, error: &error)!
        var idlist: [String] = [String]()

        for filename in filelist {
            var str: String = filename as! String
            str = str.substringWithRange(Range<String.Index>(start: advance(str.startIndex, 6), end: advance(str.endIndex, -4)))
            idlist.append(str)
        }
        return idlist
    }

    /// Load the study with name "study_\(id).xml". Return `nil` otherwise.
    func loadStudy(id: String) -> (Study?) {
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String

        if let inputStream = NSInputStream(fileAtPath: path + "/study_\(id).xml") {
            let parser = NSXMLParser(stream: inputStream)
            parser.delegate = self
            parser.parse()

            return study
        } else {
            return nil
        }
    }


    func parser(parser: NSXMLParser??!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        if (elementName == "study") {
            study.name = attributeDict["name"] as! String
        } else if (elementName == "plan") {
            state = 1


        } else if (elementName == "data-type") && (state == 1) {
            state = 11
            dataType = (attributeDict["name"] as! String, [Field]())
            study.customDataTypes.append(dataType)
        } else if (elementName == "value") && (state == 11) {
            dataType.fields.append((attributeDict["name"] as! String, attributeDict["type"] as! String))


        } else if (elementName == "test") && (state == 1) {
            test = (attributeDict["name"] as! String, [Field]())
            study.tests.append(test)
        } else if (elementName == "value") && (state == 1) {
            test.fields.append((attributeDict["name"] as! String, attributeDict["type"] as! String))
        }


        else if (elementName == "results") {
            state = 2
        } else if (elementName == "participant") && (state == 2) {
            participant = Participant()
            if let id = (attributeDict["id"] as? String)?.toInt() {
                participant.id = id
                study.results.append(participant)
            } // else no participant added.
        } else if (elementName == "test") && (state == 2) {
            testRun = (attributeDict["name"] as! String, [Value]())
        } else if (elementName == "value") && (state == 2) {
            valueName = attributeDict["name"] as? String
            state = 21
        } else if (elementName == "note") && (state == 2) {
            state = 22
        }
    }


    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if ((state == 21) || (state == 22)) && (string != nil) {
            elemCont += string!
        }
    }


    func parser(parser: NSXMLParser??!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        if (elementName == "plan") || (elementName == "results") {
            state = 0;
        } else if (elementName == "data-type") && (state == 11) {
            state = 1;

        } else if (elementName == "test") && (state == 2) {
            participant.testsRun.append(testRun)
        } else if (elementName == "value") && (state == 21) {
            testRun.append((valueName, elemCont))
            elemCont == ""
            state = 2
        } else if (elementName == "note") && (state == 22) {
            participant.notes += elemCont
            elemCont = ""
            state = 2
        }
    }
}
