//
//  CurrentGameView.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import SwiftUI
import SwiftData
import Charts

struct CurrentGameView: View {
    
    @Query var matches: [Match] = []
    @Query(filter: #Predicate<Team> {$0.isInGame}) var teams: [Team] = []
    @Query(filter: #Predicate<Player> {$0.isInGame}) var players: [Player] = []
    @Environment(\.modelContext) var context
    @Environment(UserSettings.self) var userSettings

    @State private var isEditingMatch: Bool = false
    @State private var editingMatchIndex: Int = 0
    @State private var settingsDetent = PresentationDetent.medium
    
    var dataPoints: [DataPoint] {
        generateDataPoints()
    }
    
    var legend: String {
        "Points -- Win: " + String(userSettings.winPoints) +
        " Draw: " + String(userSettings.drawPoints) +
        " Lose: " + String(userSettings.losePoints) +
        " Handicap: " + String(userSettings.handicapPoints)
    }
    
    var body: some View {
        NavigationStack {

            List {
                chartSection
                resultSection
                matchListSection
            }
            .navigationBarTitle("Tonight")
            .toolbar {
                Button(action: createNewMatch, label: {
                    Text("OneMoreMatch")
                })
                Button(action: deleteAllMatches, label: {
                    Text("DeleteAll")
                })
            }
            .sheet(isPresented: $isEditingMatch, content: {
                MatchDetailsView(match: matches[editingMatchIndex])
                    .presentationDetents([.medium, .large], selection: $settingsDetent)
            })
        }
    }
    
    @ViewBuilder
    var matchListSection: some View {
        Section(header: Text("Matches")) {
            ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                matchRowView(match)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingMatchIndex = index
                        isEditingMatch = true
                    }
            }
        }
    }
    
    @ViewBuilder
    var resultSection: some View {
        Section(header: Text("Results")) {
            HStack {
                Text("Player")
                    .font(.caption)
                Spacer()
                Text("Points earned")
                    .font(.caption)
                Spacer()
                Text("Match played")
                    .font(.caption)
            }
            ForEach(players) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Text(String(calcPoints(for:player)))
                    Spacer()
                    Text(String(calcMatchPlayed(for:player)))
                }
                
            }
        }
    }
    
    @ViewBuilder
    var chartSection: some View {
        Section(header: Text("Chart")) {
            Chart {
                ForEach(dataPoints) { point in
                    BarMark(x: .value("Player", point.player.name),
                            y: .value("Points", point.points))
                    .annotation (position: .overlay) {
                        Text(point.points > 0 ? String(point.points) : "")
                            .foregroundColor(.white)
                    }
                    .foregroundStyle(by: .value("Result", point.matchResult))
                    .position(by: .value("PointType", point.pointType))
                }
            }
            .frame(height: 200)
            Text(legend)
        }
    }
    
    @ViewBuilder
    func matchRowView(_ match: Match) -> some View {
        GeometryReader { geometry in
            HStack {
                HStack {
                    VStack {
                        HStack {
                            ForEach(match.homePlayers) { homePlayer in
                                Text(homePlayer.name)
                            }
                        }
                        Text(match.homeTeam!.name)
                    }
                    Spacer()
                    if let homeGoal = match.homeGoal,
                       let _ = match.visitGoal {
                        Text(String(homeGoal))
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.33)
                Spacer()
                Text("VS.")
                Spacer()
                HStack {
                    VStack {
                        HStack {
                            ForEach(match.visitPlayers) { visitPlayer in
                                Text(visitPlayer.name)
                            }
                        }
                        Text(match.visitTeam!.name)
                    }
                    Spacer()
                    if let _ = match.homeGoal,
                       let visitGoal = match.visitGoal {
                        Text(String(visitGoal))
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.33)
            }
        }
        .frame(height: 50)

    }

    
    private func calcPoints(for player: Player) -> Int {
        let homePoints = matches.filter{$0.homePlayers.contains(player)}.compactMap{$0.homeResult}.map{MatchUtil.mapMatchResultToPoints($0)}.reduce(0, +)
        
        
        let visitPoints = matches.filter{$0.visitPlayers.contains(player)}.compactMap{$0.visitResult}.map{MatchUtil.mapMatchResultToPoints($0)}.reduce(0, +)
        return homePoints + visitPoints
    }
    
    private func calcMatchPlayed(for player: Player) -> Int {
        let homePoints = matches.filter{$0.homePlayers.contains(player)}.count
        let visitPoints = matches.filter{$0.visitPlayers.contains(player)}.count
        return homePoints + visitPoints
    }
    
    private func generateDataPoints() -> [DataPoint] {
        var dataPoints: [DataPoint] = []

        for player in players {
            let homeResultArray = matches.filter{$0.homePlayers.contains(player)}.compactMap{$0.homeResult}
            
            let visitResultArray = matches.filter{$0.visitPlayers.contains(player)}.compactMap{$0.visitResult}
            
            let winCounts = homeResultArray.filter({$0 == .win}).count + visitResultArray.filter({$0 == .win}).count
            
            let drawCounts = homeResultArray.filter({$0 == .draw}).count + visitResultArray.filter({$0 == .draw}).count
            
            let loseCounts = homeResultArray.filter({$0 == .lose}).count + visitResultArray.filter({$0 == .lose}).count
            
            let totalPoints = winCounts * userSettings.winPoints + drawCounts * userSettings.drawPoints + loseCounts * userSettings.losePoints - player.handicapCount * userSettings.handicapPoints
            
            dataPoints.append(DataPoint(player: player, pointType: .pointsEarned, matchResult: .none, points: totalPoints))
                        
            dataPoints.append(DataPoint(player: player, pointType: .matchAttended, matchResult: .win, points: winCounts))
            
            dataPoints.append(DataPoint(player: player, pointType: .matchAttended, matchResult: .draw, points: drawCounts))
            
            dataPoints.append(DataPoint(player: player, pointType: .matchAttended, matchResult: .lose, points: loseCounts))

        }
        
        return dataPoints
    }
    
    
    private func createNewMatch() {
        
        let homeTeamScale = userSettings.homeTeamScale
        
        let lastMatch = matches.last
        
        let newMatch = Match()
        context.insert(newMatch)
        let (homePlayers, visitPlayers) = NewMatchUtil.choosePlayers(players: players, lastMatch: matches.last, homePlayerScale: homeTeamScale)
        newMatch.homePlayers = homePlayers
        newMatch.visitPlayers = visitPlayers
        
        for player in newMatch.visitPlayers {
            player.visitMatches.append(newMatch)
        }
        
        for player in newMatch.homePlayers {
            player.homeMatches.append(newMatch)
        }
        
        let (homeTeam, visitTeam) = NewMatchUtil.chooseTeams(teams: teams, lastMatch: lastMatch)
        newMatch.homeTeam = homeTeam
        newMatch.visitTeam = visitTeam
        
        newMatch.homeTeam?.homeMatches.append(newMatch)
        newMatch.visitTeam?.visitMatches.append(newMatch)
        
        try? context.save()
    }
    
    
    private func deleteAllMatches() {
        for match in matches {
            context.delete(match)
        }
    }
}

#Preview {
    CurrentGameView()
}
