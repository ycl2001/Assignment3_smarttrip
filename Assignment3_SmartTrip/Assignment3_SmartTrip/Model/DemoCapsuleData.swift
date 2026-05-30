//
//  DemoCapsuleData.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 30/5/2026.
//

import Foundation

struct DemoCapsuleData {

    static func stamps(for trip: Trip) -> [JourneyCapsule] {

        let dates = generateDatesWithinTrip(
            startDate: trip.startDate,
            endDate: trip.endDate
        )

        return [
            JourneyCapsule(
                title: "Rainy Morning",
                caption: "Rainy morning outside the gallery",
                placeName: "Shibuya Sky",
                location: trip.destination,
                date: dates[0],
                suggestedPrompt: "Capture your Journey Capsule"
            ),
            JourneyCapsule(
                title: "Dessert Stop",
                caption: "Random dessert stop with friends",
                placeName: "Ichiran Ramen",
                location: "Shinjuku, Tokyo",
                date: dates[1],
                suggestedPrompt: "Capture your Journey Capsule"
            ),
            JourneyCapsule(
                title: "Golden Hour",
                caption: "Golden hour before heading back",
                placeName: "Odaiba Beach",
                location: trip.destination,
                date: dates[2],
                suggestedPrompt: "Capture your Journey Capsule"
            )
        ]
    }

    private static func generateDatesWithinTrip(
        startDate: Date,
        endDate: Date
    ) -> [Date] {

        let calendar = Calendar.current

        let totalDays = max(
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: startDate),
                to: calendar.startOfDay(for: endDate)
            ).day ?? 1,
            1
        )

        let dayOne = startDate

        let dayTwo = calendar.date(
            byAdding: .day,
            value: min(1, totalDays),
            to: startDate
        ) ?? startDate

        let dayThree = calendar.date(
            byAdding: .day,
            value: min(2, totalDays),
            to: startDate
        ) ?? startDate

        return [
            setTime(dayOne, hour: 9, minute: 30),
            setTime(dayTwo, hour: 15, minute: 20),
            setTime(dayThree, hour: 18, minute: 10)
        ]
    }

    private static func setTime(
        _ date: Date,
        hour: Int,
        minute: Int
    ) -> Date {

        let calendar = Calendar.current

        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        ) ?? date
    }
}
