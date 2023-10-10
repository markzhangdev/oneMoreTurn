//
//  NewMatchUtil.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 5/10/2023.
//

import Foundation

enum NewMatchUtil {
    
}

extension NewMatchUtil {
    static func choosePlayers(players: [Player], lastMatch: Match?, homePlayerScale: Int) -> ([Player], [Player]) {
        guard players.count >= homePlayerScale,
         let lastMatch = lastMatch else { 
            if players.count >= homePlayerScale {
                let shuffled = Array(players.shuffled())
                return (Array(shuffled.prefix(homePlayerScale)), Array(shuffled.dropFirst(homePlayerScale)))
            } else {
                return ([], [])
            }

        }
        
        var option = Array(players.shuffled())
        var optionHomePlayer = option.prefix(homePlayerScale)
        
        while optionHomePlayer.map(\.name).sorted() == lastMatch.homePlayers.map(\.name).sorted() {
            option = Array(players.shuffled())
            optionHomePlayer = option.prefix(homePlayerScale)
        }
        
        let result = (Array(option.prefix(homePlayerScale)), Array(option.dropFirst(homePlayerScale)))
        
        return result
    }
    
    static func chooseTeams(teams: [Team], lastMatch: Match?) -> (Team,Team) {
        guard teams.count >= 2,
              let lastMatch = lastMatch else { 
            if teams.count >= 2 {
                let shuffled = Array(teams.shuffled())
                return (shuffled[0], shuffled[1])
            } else {
                fatalError("Not enough teams")
            }
        }
        var option = Array(teams.shuffled().prefix(2))

        while option.map(\.name).contains(lastMatch.homeTeam!.name) || option.map(\.name).contains(lastMatch.visitTeam!.name) {
            option = Array(teams.shuffled().prefix(2))
        }
        return (option[0], option[1])
    }
}
