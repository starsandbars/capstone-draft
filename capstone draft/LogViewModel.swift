//
//  Models.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/19/26.
//

import Foundation

struct SymptomEntry: Identifiable, Codable {
    let id:  UUID
    var name: String
    var severity:  Int
    var time: Date

    init(id: UUID = UUID(), name: String, severity: Int, time: Date = Date()) {
        self.id = id
        self.name = name
        self.severity = severity
        self.time = time
    }
}

struct DayLog: Identifiable, Codable {
    var id: Date { day }     // stable per day
    var day: Date            // start-of-day
    var entries: [SymptomEntry]
}
