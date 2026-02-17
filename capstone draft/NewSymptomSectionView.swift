//
//  NewSymptomSectionView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 2/17/26.
//



import SwiftUI
import SwiftData

struct NewSymptomSectionView: View {
    let dayLog: NewSymptomModel

    private var entriesSorted: [SymptomEntryModel] {
        dayLog.entries.sorted { $0.time > $1.time }
    }

    var body: some View {
        Section(dayLog.day.formatted(date: .abbreviated, time: .omitted)) {
            if entriesSorted.isEmpty {
                Text("No symptoms logged.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entriesSorted) { entry in
                    SymptomEntryRow(entry: entry)
                }
            }
        }
    }
}
