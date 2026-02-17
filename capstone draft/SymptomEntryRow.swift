//
//  SymptomEntryRowItem.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 2/17/26.
//
import SwiftUI
import SwiftData

struct SymptomEntryRow: View {
    let entry: SymptomEntryModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)

                Text(entry.time.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(entry.severity)")
                .foregroundStyle(.secondary)
        }
    }
}
