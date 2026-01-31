//
//  capstone_draftApp.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/5/26.
//
import SwiftUI
import SwiftData

@main
struct SymptomLoggerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [NewSymptomModel.self, SymptomEntryModel.self])
    }
}
