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
    
    @Query(filter: Match.tonightPredicate()) var matches: [Match] = []
    @Query(filter: #Predicate<Team> {$0.isInGame}) var teams: [Team] = []
    @Query(filter: #Predicate<Player> {$0.isInGame}) var players: [Player] = []
    @Environment(\.modelContext) var context
    @Environment(UserSettings.self) var userSettings

    @State private var editingMatch: Match?
    @State private var settingsDetent = PresentationDetent.medium
    
    var dataPoints: [DataPoint] {
        MatchUtil.generateDataPoints(with: matches, and: players, withHandicap: true)
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
//                Button(action: deleteAllMatches, label: {
//                    Text("DeleteAll")
//                })
            }
            .sheet(item: $editingMatch, content: { match in
                MatchDetailsView(match: match)
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
                        editingMatch = match
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
                    Text(String(MatchUtil.calcPoints(with: matches, for:player)))
                    Spacer()
                    Text(String(MatchUtil.calcMatchPlayed(with: matches, for:player)))
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
