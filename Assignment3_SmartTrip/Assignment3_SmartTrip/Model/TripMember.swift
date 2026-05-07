//
//  TripMember.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

// Represents one member participating in a trip.
// The role helps identify whether the person is a host or regular member.
import Foundation

struct TripMember: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var role: String
}
