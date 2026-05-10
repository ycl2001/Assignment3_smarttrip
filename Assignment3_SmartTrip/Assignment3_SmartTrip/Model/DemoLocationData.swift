//
//  DemoLocationData.swift
//  Assignment3_SmartTrip
//
//  Created by Yen-Chun Liu on 10/5/2026.
//

import Foundation

struct DemoLocationData {

    static let places: [SuggestedPlace] = [

        // MARK: - Tokyo

        SuggestedPlace(
            destination: "Tokyo, Japan",
            name: "Shibuya Sky",
            location: "Shibuya, Tokyo",
            suggestedBy: "Selina",
            note: "Great sunset view and photo spot.",
            category: .attraction
        ),

        SuggestedPlace(
            destination: "Tokyo, Japan",
            name: "Ichiran Ramen",
            location: "Shinjuku, Tokyo",
            suggestedBy: "Leo",
            note: "Easy dinner option after shopping.",
            category: .food
        ),

        SuggestedPlace(
            destination: "Tokyo, Japan",
            name: "TeamLab Planets",
            location: "Toyosu, Tokyo",
            suggestedBy: "Zoe",
            note: "Interactive art experience.",
            category: .attraction
        ),

        SuggestedPlace(
            destination: "Tokyo, Japan",
            name: "Asakusa Senso-ji",
            location: "Asakusa, Tokyo",
            suggestedBy: "Jimmy",
            note: "Classic Tokyo temple visit and good for first-day exploring.",
            category: .attraction
        ),

        // MARK: - Fiji

        SuggestedPlace(
            destination: "Fiji",
            name: "Cloud 9",
            location: "Mamanuca Islands",
            suggestedBy: "Zoe",
            note: "Floating bar with ocean views.",
            category: .attraction
        ),

        SuggestedPlace(
            destination: "Fiji",
            name: "Nadi Market",
            location: "Nadi",
            suggestedBy: "Jimmy",
            note: "Good for local food and souvenirs.",
            category: .shopping
        ),

        SuggestedPlace(
            destination: "Fiji",
            name: "Natadola Beach",
            location: "Viti Levu",
            suggestedBy: "Selina",
            note: "Relaxing beach day option.",
            category: .attraction
        ),

        // MARK: - Bangkok

        SuggestedPlace(
            destination: "Bangkok, Thailand",
            name: "Chatuchak Market",
            location: "Kamphaeng Phet 2 Road",
            suggestedBy: "Mia",
            note: "Good for shopping and street food.",
            category: .shopping
        ),

        SuggestedPlace(
            destination: "Bangkok, Thailand",
            name: "Wat Arun",
            location: "Riverside Bangkok",
            suggestedBy: "Leo",
            note: "Beautiful temple near the river.",
            category: .attraction
        ),
        
        SuggestedPlace(
            destination: "Bangkok, Thailand",
            name: "Grand Palace",
            location: "Phra Nakhon, Bangkok",
            suggestedBy: "Sandra",
            note: "Famous cultural landmark with traditional Thai architecture.",
            category: .attraction
        ),

        SuggestedPlace(
            destination: "Bangkok, Thailand",
            name: "Yaowarat Road",
            location: "Chinatown",
            suggestedBy: "Jimmy",
            note: "Great night food street.",
            category: .food
        )
    ]

    // MARK: - Filter Demo Locations

    static func places(
        for destination: String,
        members: [String]
    ) -> [SuggestedPlace] {

        let normalisedDestination = destination
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let normalisedMembers = members.map {
            $0.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return places.filter { place in

            let placeDestination = place.destination
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let suggestedBy = place.suggestedBy
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let destinationMatches =
                placeDestination == normalisedDestination
                || placeDestination.contains(normalisedDestination)
                || normalisedDestination.contains(placeDestination)

            let memberMatches =
                normalisedMembers.contains { member in
                    member == suggestedBy
                    || member.contains(suggestedBy)
                    || suggestedBy.contains(member)
                }

            return destinationMatches && memberMatches
        }
    }
}
