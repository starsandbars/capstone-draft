//
//  NewSymptomViewModel.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/13/26.
//

import Foundation
import SwiftData

@Model
final class NewSymptomModel {
    var day: Date

    // One day has many entries. Cascade delete is handy.
    @Relationship(deleteRule: .cascade, inverse: \SymptomEntryModel.dayLog)
    var entries: [SymptomEntryModel] = []

    init(day: Date) {
        self.day = day
    }
}

@Model
final class SymptomEntryModel {
    var id: UUID
    var name: String
    var severity: Int
    var time: Date

    // Back-reference to the day bucket
    var dayLog: NewSymptomModel?

    init(name: String, severity: Int, time: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.severity = severity
        self.time = time
    }
}

/*import Foundation
import Combine

class NewSymptomViewModel: ObservableObject{
    @Published var title = ""
    @Published var severityString = ""
    @Published var severity = 0
    
    init() {
    }
    
    func save() {
        
    }
}
*/
