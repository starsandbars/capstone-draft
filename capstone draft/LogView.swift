//
//  LogView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/8/26.

import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var context

    // Fetch all day buckets, newest first
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
                // Ensure today's group exists when this screen first appears
                _ = try? SymptomService.ensureTodayBucket(context: context)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // If user returns after midnight, create today's bucket
                _ = try? SymptomService.ensureTodayBucket(context: context)
            }
        }
    }
}

/*
import SwiftUI

struct LogView: View {
    @ObservedObject var store: SymptomStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.days) { dayLog in
                    Section(dayLog.day.formatted(date: .abbreviated, time: .omitted)) {
                        if dayLog.entries.isEmpty {
                            Text("No symptoms logged.")
                                .foregroundStyle(.secondary)
                        } else {
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
                                        .foregroundStyle(.secondary)
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
            }
            .sheet(isPresented: $showingAdd) {
                NavigationStack {
                    NewSymptomView(store: store)
                }
            }
        }
        .onAppear {
            store.ensureTodayBucketExists()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.ensureTodayBucketExists()
            }
        }
    }
}
*/

/*
import SwiftUI

struct LogView: View {
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    

                }
                .navigationTitle("Symptom Log")
                .toolbar{
                    Button{
                        
                    } label: {
                        NavigationLink(destination: NewSymptomView()){
                            Image(systemName:"plus")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LogView()
}
*/
