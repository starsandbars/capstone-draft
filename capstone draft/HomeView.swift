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
    enum RangeMode: String, CaseIterable, Identifiable {
        case week = "This Week"
        case month = "This Month"
        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var context

    @State private var mode: RangeMode = .week

    @State private var rangeStart: Date = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.start
    @State private var rangeEnd: Date = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!.end

    @State private var entries: [SymptomEntryModel] = []
    @State private var allSymptomsInRange: [String] = []
    @State private var selectedSymptoms: Set<String> = []

    @State private var series: [SymptomSeries] = []
    @State private var showingFilter = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // Toggle: This Week / This Month
                Picker("Range", selection: $mode) {
                    ForEach(RangeMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 4)

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.headline)
                    Text(rangeString(start: rangeStart, end: rangeEnd))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Chart
                if series.isEmpty {
                    ContentUnavailableView(
                        "No data to show",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Try adding symptoms or adjusting filters.")
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
                        if mode == .week {
                            AxisMarks(values: weekDays(start: rangeStart)) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let d = value.as(Date.self) {
                                        Text(d, format: .dateTime.weekday(.abbreviated))
                                    }
                                }
                            }
                        } else {
                            // Month: label every 7 days to avoid clutter
                            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let d = value.as(Date.self) {
                                        Text(d, format: .dateTime.day())
                                    }
                                }
                            }
                        }
                    }
                    .chartYAxis { AxisMarks(position: .leading) }
                    .chartLegend(position: .bottom, alignment: .leading)
                    .frame(height: 320)
                    .padding(.horizontal)
                }

                Spacer(minLength: 0)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filter Symptoms")
                    .disabled(allSymptomsInRange.isEmpty)
                }
            }
            .sheet(isPresented: $showingFilter) {
                NavigationStack {
                    SymptomFilterView(
                        allSymptoms: allSymptomsInRange,
                        selectedSymptoms: $selectedSymptoms
                    )
                }
            }
            .task { await reloadForCurrentMode() }
            .onChange(of: mode) { _, _ in
                Task { await reloadForCurrentMode() }
            }
            .onChange(of: selectedSymptoms) { _, _ in
                // Rebuild chart when filters change (no need to refetch DB)
                series = buildSeries(entries: entries, start: rangeStart, end: rangeEnd, mode: mode, selected: selectedSymptoms)
            }
        }
    }

    // MARK: - Reload logic

    private func reloadForCurrentMode() async {
        setRangeForMode()
        await reload()
    }

    private func setRangeForMode() {
        let cal = Calendar.current
        let interval: DateInterval
        switch mode {
        case .week:
            interval = cal.dateInterval(of: .weekOfYear, for: Date())!
        case .month:
            interval = cal.dateInterval(of: .month, for: Date())!
        }
        rangeStart = interval.start
        rangeEnd = interval.end
    }

    private func reload() async {
        do {
            let descriptor = FetchDescriptor<SymptomEntryModel>(
                predicate: #Predicate { entry in
                    entry.time >= rangeStart && entry.time < rangeEnd
                }
            )
            let fetched = try context.fetch(descriptor)
            entries = fetched

            let symptoms = Array(Set(fetched.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }))
                .filter { !$0.isEmpty }
                .sorted()

            allSymptomsInRange = symptoms

            // If the user hasn't chosen filters yet, default to "all"
            if selectedSymptoms.isEmpty {
                selectedSymptoms = Set(symptoms)
            } else {
                // Keep only still-valid selections
                selectedSymptoms = selectedSymptoms.intersection(symptoms)
                // If everything got filtered out (e.g., switching range), fall back to all
                if selectedSymptoms.isEmpty {
                    selectedSymptoms = Set(symptoms)
                }
            }

            series = buildSeries(entries: fetched, start: rangeStart, end: rangeEnd, mode: mode, selected: selectedSymptoms)

        } catch {
            print("❌ Fetch failed:", error)
            entries = []
            allSymptomsInRange = []
            selectedSymptoms = []
            series = []
        }
    }

    // MARK: - Build series (average per day, 0 if missing)

    private func buildSeries(
        entries: [SymptomEntryModel],
        start: Date,
        end: Date,
        mode: RangeMode,
        selected: Set<String>
    ) -> [SymptomSeries] {

        let cal = Calendar.current
        let days: [Date] = (mode == .week)
            ? weekDays(start: start)
            : monthDays(start: start, end: end)

        // Only show selected symptoms
        let symptomNames = Array(selected).sorted()

        // symptom -> dayStart -> (sum,count)
        var sumCount: [String: [Date: (sum: Int, count: Int)]] = [:]

        for e in entries {
            let name = e.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard selected.contains(name) else { continue }

            let dayStart = cal.startOfDay(for: e.time)
            let current = sumCount[name]?[dayStart] ?? (0, 0)
            sumCount[name, default: [:]][dayStart] = (current.sum + e.severity, current.count + 1)
        }

        return symptomNames.map { name in
            let points = days.map { day -> SymptomPoint in
                if let sc = sumCount[name]?[day], sc.count > 0 {
                    let avg = Double(sc.sum) / Double(sc.count)
                    return SymptomPoint(id: UUID(), day: day, intensity: Int(avg.rounded()))
                } else {
                    return SymptomPoint(id: UUID(), day: day, intensity: 0)
                }
            }
            return SymptomSeries(name: name, points: points)
        }
    }

    // MARK: - Date helpers

    private func weekDays(start: Date) -> [Date] {
        let cal = Calendar.current
        let s = cal.startOfDay(for: start)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: s).map(cal.startOfDay(for:)) }
    }

    private func monthDays(start: Date, end: Date) -> [Date] {
        let cal = Calendar.current
        var result: [Date] = []
        var d = cal.startOfDay(for: start)
        while d < end {
            result.append(d)
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }
        return result
    }

    private func rangeString(start: Date, end: Date) -> String {
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

#Preview {
    HomeView()
}

