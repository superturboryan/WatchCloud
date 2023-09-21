//
//  Complication.swift
//  Complication
//
//  Created by Ryan Forsyth on 2023-09-19.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ComplicationEntryView : View {
    
    @Environment(\.widgetFamily) private var family
    
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .padding(2)
        }
        .widgetLabel {
            Text("WatchCloud")
        }
    }
}

@main
struct Complication: Widget {
    let kind: String = "Complication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Open WatchCloud")
        .description("Opens the WatchCloud app.")
    }
}

struct Complication_Previews: PreviewProvider {
    static var previews: some View {
        ComplicationEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
