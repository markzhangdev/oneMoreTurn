//
//  MatchUtil.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 7/10/2023.
//

import Foundation

enum MatchUtil {
    
}

extension MatchUtil {
    static func mapMatchResultToPoints(_ result: MatchResultType) -> Int {
        let userSettings = UserSettingsUseCase()
        switch result {
        case .win :
            return userSettings.shared.winPoints
        case .draw :
            return userSettings.shared.drawPoints
        case .lose :
            return userSettings.shared.losePoints
        default :
            return userSettings.shared.losePoints
        }
    }
    
    static func calcPoints(with matches: [Match], for player: Player) -> Int {
        let homePoints = matches.filter{$0.homePlayers.contains(player)}.compactMap{$0.homeResult}.map{mapMatchResultToPoints($0)}.reduce(0, +)
        let visitPoints = matches.filter{$0.visitPlayers.contains(player)}.compactMap{$0.visitResult}.map{mapMatchResultToPoints($0)}.reduce(0, +)
        return homePoints + visitPoints
    }
    
    static func calcMatchPlayed(with matches: [Match], for player: Player) -> Int {
        let homePoints = matches.filter{$0.homePlayers.contains(player)}.count
        let visitPoints = matches.filter{$0.visitPlayers.contains(player)}.count
        return homePoints + visitPoints
    }
    
    static func generateDataPoints(with matches: [Match], and players: [Player], withHandicap: Bool, withSettings userSettingsUseCase: UserSettingsUseCase = UserSettingsUseCase()) -> [DataPoint] {
        var dataPoints: [DataPoint] = []
        let userSettings = userSettingsUseCase.shared

        for player in players {
            let homeResultArray = matches.filter{$0.homePlayers.contains(player)}.compactMap{$0.homeResult}
            
            let visitResultArray = matches.filter{$0.visitPlayers.contains(player)}.compactMap{$0.visitResult}
            
            let winCounts = homeResultArray.filter({$0 == .win}).count + visitResultArray.filter({$0 == .win}).count
            
            let drawCounts = homeResultArray.filter({$0 == .draw}).count + visitResultArray.filter({$0 == .draw}).count
            
            let loseCounts = homeResultArray.filter({$0 == .lose}).count + visitResultArray.filter({$0 == .lose}).count
            
            let totalPointsWithoutHandicap = winCounts * userSettings.winPoints + drawCounts * userSettings.drawPoints + loseCounts * userSettings.losePoints
            
            let totalPointsWithhandicap = totalPointsWithoutHandicap - player.handicapCount * userSettings.handicapPoints
            
            if withHandicap {
                dataPoints.append(DataPoint(player: player, pointType: .pointsEarned, matchResult: .none, points: withHandicap ? totalPointsWithhandicap : totalPointsWithoutHandicap))
            }
                        
            dataPoints.append(DataPoint(player: player, pointType: .matchAttended, matchResult: .win, points: winCounts))
            
            dataPoints.append(DataPoint(player: player, pointType: .matchAttended, matchResult: .draw, points: drawCounts))
            
            dataPoints.append(DataPoint(player: player, pointType: .matchAttended, matchResult: .lose, points: loseCounts))

        }
        
        return dataPoints
    }
    
}
