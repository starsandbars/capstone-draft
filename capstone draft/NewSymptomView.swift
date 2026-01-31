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
/*
import SwiftUI

struct NewSymptomView: View {
    @ObservedObject var store: SymptomStore

    @Environment(\.dismiss) private var dismiss

    @State private var symptomName = ""
    @State private var severity = 5

    var body: some View {
        Form {
            Section("Symptom") {
                TextField("Symptom name (e.g., headache)", text: $symptomName)
                Stepper("Severity: \(severity)", value: $severity, in: 1...10)
            }
/*
            Section {
                Button("Save") {
                    store.addSymptom(name: symptomName, severity: severity)
                    dismiss() // go back
                }
                .disabled(symptomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
 */
            }
            .navigationTitle("Add Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        store.addSymptom(name: symptomName, severity: severity)
                        dismiss()
                    }
                    .disabled(symptomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
        }
        }
      

}
*/

/*import SwiftUI

struct SymptomLogView: View {
    @ObservedObject var store: SymptomStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var symptomName = ""
    @State private var severity = 5

    var body: some View {
        NavigationStack {
            Form {
                Section("Add Symptom (Today)") {
                    TextField("Symptom name", text: $symptomName)
                    Stepper("Severity: \(severity)", value: $severity, in: 1...10)

                    Button("Add to Log") {
                        store.addSymptom(name: symptomName, severity: severity)
                        symptomName = ""
                        severity = 5
                    }
                    .disabled(symptomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Daily Log") {
                    List {
                        ForEach(store.days) { dayLog in
                            Section(dayLog.day.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(dayLog.entries) { entry in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.name).font(.headline)
                                            Text(entry.time.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("\(entry.severity)")
                                    }
                                }
                            }
                        }
                    }
                    .frame(minHeight: 300)
                }
            }
            .navigationTitle("Symptom Log")
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { store.ensureTodayBucketExists() }
        }
    }
}
*/
/*
struct NewSymptomView: View {
    
    @StateObject var viewModel = NewSymptomViewModel()
    var body: some View {
        NavigationStack{
            VStack{
                Text("New Symptom")
                    .font(.system(size:32))
                    .bold()
                
                Form{
                    TextField("Title", text: $viewModel.title)
                    
                    HStack{
                        TextField("Severity", text: $viewModel.severityString)
                            .keyboardType(.numberPad)
                        
                        Text("/10")
                        
                    }
                    
                    Button{
                        
                    } label:{
                        Text("Save")
                    }
                }
                
            }
        }
        }
    }


#Preview {
    NewSymptomView()
}
*/
