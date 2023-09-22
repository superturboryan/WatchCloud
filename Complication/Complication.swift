//
//  Complication.swift
//  Complication
//
//  Created by Ryan Forsyth on 2023-09-22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct ComplicationEntryView : View {
    @Environment(\.widgetFamily) private var family
    
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: family == .accessoryCorner ? "cloud.circle.fill" : "cloud.fill")
                .resizable()
                .scaledToFit()
        }
        .padding(.horizontal, 4)
    }
}

@main
struct Complication: Widget {
    let kind: String = "Complication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                ComplicationEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ComplicationEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Open WatchCloud")
        .description("Opens the WatchCloud app")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

#Preview(as: .accessoryCorner) {
    Complication()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
}

#Preview(as: .accessoryCircular) {
    Complication()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
}
