//
//  BillboardView.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import SwiftUI
import SwiftData
import Charts

struct BillboardView: View {
    
    @Query() var matches: [Match] = []
    @Query() var teams: [Team] = []
    @Query() var players: [Player] = []
    @Environment(UserSettings.self) var userSettings

    @State private var settingsDetent = PresentationDetent.medium
    
    var dataPoints: [DataPoint] {
        MatchUtil.generateDataPoints(with: matches, and: players, withHandicap: false)
    }
    
    var legend: String {
        "Points -- Win: " + String(userSettings.winPoints) +
        " Draw: " + String(userSettings.drawPoints) +
        " Lose: " + String(userSettings.losePoints)
    }
    
    var body: some View {
        NavigationStack {

            List {
                chartSection
                resultSection
            }
            .navigationBarTitle("History")
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
}

#Preview {
    BillboardView()
}
