//
// DataTypes.swift
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


class Study {
    var name = ""
    var tests = [Test]()
    var results = [Participant]()
    var customDataTypes = [Test]()
}


class Participant {
    var id = 0
    // An array of tuples of test name and values input.
    var testsRun = [TestRun]()
}


typealias Test     = (name: String, fields: [Field])
typealias DataType = (name: String, fields: [Field])
typealias TestRun  = (name: String, values: [String])

typealias Field    = (name: String, type: String)

let stdTypes = ["Plain", "Number", "Date", "Email", "Prose"]
