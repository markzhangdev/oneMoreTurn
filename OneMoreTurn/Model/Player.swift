//
//  Player.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import Foundation
import SwiftData

@Model
final class Player {
    var uuid: UUID = UUID()
    
    @Attribute(.unique)
    let name: String
    var isInGame: Bool
    var handicapCount: Int = 0
    
    @Relationship()
    var homeMatches: [Match] = []
    @Relationship()
    var visitMatches: [Match] = []
    
    init(name: String, isInGame: Bool = true) {
        self.name = name
        self.isInGame = isInGame
    }
}

