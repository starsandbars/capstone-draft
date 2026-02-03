//
//  LogView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/8/26.

import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \NewSymptomModel.day, order: .reverse)
    private var days: [NewSymptomModel]

    @Environment(\.scenePhase) private var scenePhase
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(days) { dayLog in
                    Section(dayLog.day.formatted(date: .abbreviated, time: .omitted)) {
                        let entriesSorted = dayLog.entries.sorted { $0.time > $1.time }

                        if entriesSorted.isEmpty {
                            Text("No symptoms logged.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(entriesSorted) { entry in
                                HStack(alignment: .top) {
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
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            .navigationTitle("Symptom Log")
            .toolbar {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Symptom")
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    NewSymptomView()
                }
            }
            .task {
                _ = try? SymptomService.ensureTodayBucket(context: context)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // if user returns after midnight, create today
                _ = try? SymptomService.ensureTodayBucket(context: context)
            }
        }
    }
    
    private func deleteEntry(_ entry: SymptomEntryModel) {
        context.delete(entry)
        do {
            try context.save()
        } catch {
            print("Delete failed:", error)
        }
    }
}

