//
//  NewSymptomView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/8/26.
//
import SwiftUI
import SwiftData

struct NewSymptomView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var symptomName = ""
    @State private var severity = 5

    var body: some View {
        Form {
            Section("Symptom") {
                TextField("Symptom name (e.g., headache)", text: $symptomName)
                Stepper("Severity: \(severity)", value: $severity, in: 1...10)
            }
        }
        .navigationTitle("Add Symptom")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    try? SymptomService.addSymptom(
                        context: context,
                        name: symptomName,
                        severity: severity
                    )
                    dismiss()
                }
                .disabled(symptomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
