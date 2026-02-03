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

                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.headline)
                    Text(weekRangeString(start: weekStart, end: weekEnd))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

              
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
                    .chartYScale(domain: 0...10)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("This Month") { /*new function that shows a month*/ }
                        Button("This Week") { setCurrentWeek() }
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


    private func reload() async {
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

    private func buildSeries(entries: [SymptomEntryModel], weekStart: Date) -> [SymptomSeries] {
        let cal = Calendar.current
        let days = weekDays(start: weekStart)

        let symptomNames: [String] = Array(Set(entries.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }))
            .filter { !$0.isEmpty }
            .sorted()

        var maxBySymptomByDay: [String: [Date: Int]] = [:]

        for e in entries {
            let name = e.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            let d = cal.startOfDay(for: e.time)
            maxBySymptomByDay[name, default: [:]][d] = max(maxBySymptomByDay[name]?[d] ?? 0, e.severity)
        }

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


    private func setCurrentWeek() {
        let interval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
        weekStart = interval.start
        weekEnd = interval.end
    }

    private func weekDays(start: Date? = nil) -> [Date] {
        let cal = Calendar.current
        let s = start ?? weekStart
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: s).map(cal.startOfDay(for:)) }
    }

    private func weekRangeString(start: Date, end: Date) -> String {
        let cal = Calendar.current
        let lastDay = cal.date(byAdding: .day, value: -1, to: end) ?? end
        return "\(start.formatted(date: .abbreviated, time: .omitted)) – \(lastDay.formatted(date: .abbreviated, time: .omitted))"
    }
}


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
