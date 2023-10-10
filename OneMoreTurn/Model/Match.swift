//
//  Match.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import Foundation
import SwiftData

@Model
final class Match {
    var uuid: UUID = UUID()
    
    @Relationship(inverse: \Player.homeMatches)
    var homePlayers: [Player] = []
    @Relationship(inverse: \Player.visitMatches)
    var visitPlayers: [Player]  = []
    
    @Relationship(inverse: \Team.homeMatches)
    var homeTeam: Team?
    @Relationship(inverse: \Team.visitMatches)
    var visitTeam: Team?
    
    var homeGoal: Int?
    var visitGoal: Int?
    
    @Transient
    var homeResult: MatchResultType? {
        let (homeResult, _) = calcResult()
        return homeResult
    }
    @Transient
    var visitResult: MatchResultType? {
        let (_, visitResult) = calcResult()
        return visitResult
    }
    var matchDate: Date
    
    init(matchDate: Date = Date()) {
        self.matchDate = matchDate
    }
    
    private func calcResult() -> (MatchResultType?, MatchResultType?) {
        guard let homeGoal = homeGoal,
              let visitGoal = visitGoal else {
            return (nil, nil)
        }
        
        if homeGoal > visitGoal {
            return (.win, .lose)
        } else if homeGoal == visitGoal {
            return (.draw, .draw)
        } else {
            return (.lose, .win)
        }
    }
}

extension Match {
    static func tonightPredicate() -> Predicate<Match> {
        let currentDate = Date.now
        return #Predicate<Match> { match in
            match.matchDate > currentDate
        }
    }
}
