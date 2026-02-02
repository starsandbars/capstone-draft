//
//  HomeView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/8/26.
//

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var context

    @State private var weekStart: Date = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.start
    @State private var weekEnd: Date = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.end

    @State private var entries: [SymptomEntryModel] = []
    @State private var series: [SymptomSeries] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.headline)
                    Text(weekRangeString(start: weekStart, end: weekEnd))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Chart
                if series.isEmpty {
                    ContentUnavailableView(
                        "No symptoms logged this week",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Add a symptom to see trends.")
                    )
                    .padding(.top, 24)
                } else {
                    Chart {
                        ForEach(series) { symptomSeries in
                            ForEach(symptomSeries.points) { p in
                                LineMark(
                                    x: .value("Day", p.day),
                                    y: .value("Intensity", p.intensity)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(by: .value("Symptom", symptomSeries.name))

                                PointMark(
                                    x: .value("Day", p.day),
                                    y: .value("Intensity", p.intensity)
                                )
                                .foregroundStyle(by: .value("Symptom", symptomSeries.name))
                            }
                        }
                    }
                    .chartYScale(domain: 0...10) // assuming severity is 1-10
                    .chartXAxis {
                        AxisMarks(values: weekDays()) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let d = value.as(Date.self) {
                                    Text(d, format: .dateTime.weekday(.abbreviated))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartLegend(position: .bottom, alignment: .leading)
                    .frame(height: 320)
                    .padding(.horizontal)
                }

                Spacer(minLength: 0)
            }
            .navigationTitle("Home")
            .toolbar {
                // Optional: quick jump to previous/next week
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Previous Week") { shiftWeek(by: -1) }
                        Button("Current Week") { setCurrentWeek() }
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .task { await reload() }
            .onChange(of: weekStart) { _, _ in
                Task { await reload() }
            }
        }
    }

    // MARK: - Data loading

    private func reload() async {
        // Fetch entries in [weekStart, weekEnd)
        do {
            let descriptor = FetchDescriptor<SymptomEntryModel>(
                predicate: #Predicate { entry in
                    entry.time >= weekStart && entry.time < weekEnd
                }
            )
            let fetched = try context.fetch(descriptor)
            entries = fetched
            series = buildSeries(entries: fetched, weekStart: weekStart)
        } catch {
            print("Failed to fetch weekly entries:", error)
            entries = []
            series = []
        }
    }

    // MARK: - Build series with 0s for missing days

    /// For each symptom name, create 7 points (one per day). Missing day => 0.
    /// If multiple entries exist for the same symptom on a day, we take the MAX severity.
    /// (Tell me if you prefer average instead.)
    private func buildSeries(entries: [SymptomEntryModel], weekStart: Date) -> [SymptomSeries] {
        let cal = Calendar.current
        let days = weekDays(start: weekStart) // 7 dates, start-of-day

        // Normalize symptom names (optional: keep as-is if you prefer case-sensitive)
        let symptomNames: [String] = Array(Set(entries.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }))
            .filter { !$0.isEmpty }
            .sorted()

        // Map: symptom -> dayStart -> maxSeverity
        var maxBySymptomByDay: [String: [Date: Int]] = [:]

        for e in entries {
            let name = e.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            let d = cal.startOfDay(for: e.time)
            maxBySymptomByDay[name, default: [:]][d] = max(maxBySymptomByDay[name]?[d] ?? 0, e.severity)
        }

        // Create 7 points per symptom with 0 for missing days
        let result: [SymptomSeries] = symptomNames.map { name in
            let points = days.map { day in
                SymptomPoint(
                    id: UUID(),
                    day: day,
                    intensity: maxBySymptomByDay[name]?[day] ?? 0
                )
            }
            return SymptomSeries(name: name, points: points)
        }

        return result
    }

    // MARK: - Week helpers

    private func setCurrentWeek() {
        let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
        weekStart = interval.start
        weekEnd = interval.end
    }

    private func shiftWeek(by weeks: Int) {
        let cal = Calendar.current
        if let newStart = cal.date(byAdding: .weekOfYear, value: weeks, to: weekStart) {
            let interval = cal.dateInterval(of: .weekOfYear, for: newStart)!
            weekStart = interval.start
            weekEnd = interval.end
        }
    }

    /// Returns 7 start-of-day dates starting at weekStart.
    private func weekDays(start: Date? = nil) -> [Date] {
        let cal = Calendar.current
        let s = start ?? weekStart
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: s).map(cal.startOfDay(for:)) }
    }

    private func weekRangeString(start: Date, end: Date) -> String {
        // end is start of next week; show through end - 1 day
        let cal = Calendar.current
        let lastDay = cal.date(byAdding: .day, value: -1, to: end) ?? end
        return "\(start.formatted(date: .abbreviated, time: .omitted)) – \(lastDay.formatted(date: .abbreviated, time: .omitted))"
    }
}

// MARK: - Chart data types

struct SymptomSeries: Identifiable {
    var id: String { name }
    let name: String
    let points: [SymptomPoint]
}

struct SymptomPoint: Identifiable {
    let id: UUID
    let day: Date
    let intensity: Int
}
/*import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("this is home")
    }
}*/

#Preview {
    HomeView()
}
