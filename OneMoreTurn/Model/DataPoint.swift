//
//  DataPoint.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 4/10/2023.
//

import Foundation
import Charts

enum MatchResultType: String, Plottable {
    case win = "win"
    case draw = "draw"
    case lose = "lose"
    case none = "Total Points"
}

enum PointType: String, Plottable  {
    case pointsEarned = "Total Points"
    case matchAttended = "Match Attended"
}

struct DataPoint: Identifiable {
    let id = UUID()
    let player: Player
    let pointType: PointType
    let matchResult: MatchResultType
    var points: Int
    
    init(player: Player, pointType: PointType, matchResult: MatchResultType, points: Int) {
        self.player = player
        self.pointType = pointType
        self.matchResult = matchResult
        self.points = points
    }
}


