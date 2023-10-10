//
//  Team.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import Foundation
import SwiftData

@Model
final class Team {
    var uuid: UUID = UUID()
    
    @Attribute(.unique)
    let name: String
    var isInGame: Bool
    
    @Relationship()
    var homeMatches: [Match] = []
    @Relationship()
    var visitMatches: [Match] = []
    
    init(name: String, isInGame: Bool = true) {
        self.name = name
        self.isInGame = isInGame
    }
}

