//
//  TripMember.swift
//  Assignment3_Smarttrip
//
//  Created by Yen-Chun Liu on 30/4/2026.
//

import Foundation

struct TripMember: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var role: String
}
