//
//  JourneyCapsuleView.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/5/2026.
//

import SwiftUI

struct JourneyCapsuleView: View {

    let trip: Trip

    private var stamp: [JourneyCapsule] {
        DemoCapsuleData.stamps(for: trip)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                promptCard
                
                ForEach(stamp) { stamp in
                    stampCard(stamp)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Journey Capsule")
    }
    
    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Design your Journey Capsule now")
                .font(.headline)
            
            Text("Capture a real moment from this trip and place it directly into your travel timeline.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                // Camera placeholder for showcase
            } label: {
                Label("Capture Location", systemImage: "camera.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.02, green: 0.22, blue: 0.15))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }
    
    private func stampCard(_ stamp: JourneyCapsule) -> some View {
        HStack(alignment: .top, spacing: 14) {
            
            // Emoji stamp badge
            Text(emojiForStamp(stamp))
                .font(.system(size: 42))
                .frame(width: 72, height: 72)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text(stamp.title)
                        .font(.headline)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Text(itineraryDateLabel(for: stamp.date))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(stamp.caption)
                    .font(.subheadline)
                    .foregroundStyle(.black)
                
                Text(stamp.placeName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Label(stamp.location, systemImage: "location.fill")
                    
                    Spacer()
                    
                    Label(
                        stamp.date.formatted(date: .abbreviated, time: .shortened),
                        systemImage: "clock.fill"
                    )
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
    }
    
    private func emojiForStamp(_ stamp: JourneyCapsule) -> String {
        let text = "\(stamp.title) \(stamp.caption) \(stamp.placeName)".lowercased()

        if text.contains("rain") {
            return "🌧️"
        } else if text.contains("dessert") || text.contains("food") || text.contains("ramen") {
            return "🍜"
        } else if text.contains("golden") || text.contains("sunset") {
            return "🌅"
        } else if text.contains("beach") {
            return "🏖️"
        } else if text.contains("museum") || text.contains("gallery") {
            return "🖼️"
        } else {
            return "📍"
        }
    }
    
    private func itineraryDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        return formatter.string(from: date)
    }
}
    
#Preview {
    NavigationStack {
        JourneyCapsuleView(trip: DemoCardData.trip)
    }
}
