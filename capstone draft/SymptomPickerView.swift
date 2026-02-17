//
//  SymptomPickerView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 2/17/26.
//

import SwiftUI

struct SymptomFilterView: View {
    let allSymptoms: [String]
    @Binding var selectedSymptoms: Set<String>

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                Button("Select All") {
                    selectedSymptoms = Set(allSymptoms)
                }
                Button("Clear All") {
                    selectedSymptoms.removeAll()
                }
            }

            Section("Symptoms") {
                ForEach(allSymptoms, id: \.self) { name in
                    Button {
                        toggle(name)
                    } label: {
                        HStack {
                            Text(name)
                            Spacer()
                            if selectedSymptoms.contains(name) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Filter Symptoms")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func toggle(_ name: String) {
        if selectedSymptoms.contains(name) {
            selectedSymptoms.remove(name)
        } else {
            selectedSymptoms.insert(name)
        }
    }
}


