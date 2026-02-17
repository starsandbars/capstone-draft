//
//  FullLogView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 2/17/26.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct FullLogView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \NewSymptomModel.day, order: .reverse)
    private var allDays: [NewSymptomModel]
    
    @State private var searchText: String = ""
    @State private var pdfURL: URL? = nil
    @State private var showingExportError = false
    
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        List {
            ForEach(filteredDays) { dayLog in
                NewSymptomSectionView(dayLog: dayLog)
                
            }
        }
        .navigationTitle("Detailed Log")
        .searchable(text: $searchText, prompt: "Search symptoms (e.g., Headache)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    do {
                        let url = try SymptomPDFExporter.export(days: filteredDays)
                        shareItems = [url]
                        showingShareSheet = true
                    } catch {
                        showingExportError = true
                    }
                } label: {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                }
                .disabled(filteredDays.isEmpty)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }        .alert("Couldn’t export PDF", isPresented: $showingExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
    }
    
    private var filteredDays: [NewSymptomModel] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return allDays }
        
        // Keep only days that have at least one entry matching the query
        return allDays.filter { day in
            day.entries.contains { $0.name.lowercased().contains(q) }
        }
    }
}

#Preview {
    FullLogView()
}
