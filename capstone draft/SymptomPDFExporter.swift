//
//  SymptomPDFExporter.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 2/17/26.
//

import Foundation
import UIKit

enum SymptomPDFExporter {

    static func export(days: [NewSymptomModel]) throws -> URL {
        let pageWidth: CGFloat = 612   // US Letter @ 72 dpi
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 36

        let bounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SymptomLog-\(timestampString()).pdf")

        try renderer.writePDF(to: url) { ctx in
            var y = margin

            func newPage() {
                ctx.beginPage()
                y = margin
            }

            func drawText(_ text: String, font: UIFont, x: CGFloat = margin, extraSpacing: CGFloat = 6) {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font
                ]
                let maxWidth = pageWidth - margin * 2
                let rect = CGRect(x: x, y: y, width: maxWidth, height: pageHeight - margin - y)
                let nsText = NSString(string: text)
                let usedRect = nsText.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                   options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                   attributes: attrs,
                                                   context: nil)

                // Page break if needed
                if y + usedRect.height > pageHeight - margin {
                    newPage()
                }

                nsText.draw(in: CGRect(x: x, y: y, width: maxWidth, height: usedRect.height), withAttributes: attrs)
                y += usedRect.height + extraSpacing
            }

            // First page
            newPage()
            drawText("Symptom Log Export", font: .boldSystemFont(ofSize: 18), extraSpacing: 10)
            drawText("Generated: \(Date().formatted(date: .abbreviated, time: .shortened))",
                     font: .systemFont(ofSize: 12),
                     extraSpacing: 14)

            if days.isEmpty {
                drawText("No data available for this export.", font: .systemFont(ofSize: 14))
                return
            }

            // Content
            for day in days {
                drawText(day.day.formatted(date: .abbreviated, time: .omitted),
                         font: .boldSystemFont(ofSize: 14),
                         extraSpacing: 8)

                let entriesSorted = day.entries.sorted { $0.time < $1.time } // oldest->newest reads nicely in PDF
                if entriesSorted.isEmpty {
                    drawText("• No symptoms logged.", font: .systemFont(ofSize: 12), extraSpacing: 10)
                    continue
                }

                for e in entriesSorted {
                    let line = "• \(e.time.formatted(date: .omitted, time: .shortened))  \(e.name) — severity \(e.severity)"
                    drawText(line, font: .systemFont(ofSize: 12), extraSpacing: 4)
                }

                y += 8
            }
        }

        return url
    }

    private static func timestampString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmmss"
        return f.string(from: Date())
    }
}
