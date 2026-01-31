//
//  SymptomService.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/31/26.
//
import Foundation
import SwiftData

enum SymptomService {
    static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    /// Ensures a DayLog exists for today and returns it.
    static func ensureTodayBucket(context: ModelContext) throws -> NewSymptomModel {
        let today = startOfToday()

        let descriptor = FetchDescriptor<NewSymptomModel>(
            predicate: #Predicate { $0.day == today }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let newDay = NewSymptomModel(day: today)
        context.insert(newDay)
        try context.save()
        return newDay
    }

    /// Adds a symptom entry to today's DayLog.
    static func addSymptom(context: ModelContext, name: String, severity: Int) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let dayLog = try ensureTodayBucket(context: context)

        let entry = SymptomEntryModel(name: trimmed, severity: severity, time: Date())
        entry.dayLog = dayLog

        // Keep newest first in the day's array (optional; you can sort at display time too)
        dayLog.entries.insert(entry, at: 0)

        context.insert(entry)
        try context.save()
    }
}
