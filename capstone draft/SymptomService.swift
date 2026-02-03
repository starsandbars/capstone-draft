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

    static func addSymptom(context: ModelContext, name: String, severity: Int) throws {
        let normalized = normalizeSymptomName(name)
        guard !normalized.isEmpty else { return }

        let dayLog = try ensureTodayBucket(context: context)

        let entry = SymptomEntryModel(
            name: normalized,
            severity: severity,
            time: Date()
        )

        entry.dayLog = dayLog
        context.insert(entry)
        try context.save()
    }
    
    static func normalizeSymptomName(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        return lower.capitalized
    }
}
