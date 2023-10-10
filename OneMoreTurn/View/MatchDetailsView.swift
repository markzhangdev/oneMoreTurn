//
//  MatchDetailsView.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 3/10/2023.
//

import SwiftUI

struct MatchDetailsView: View {
    
    @Bindable var match: Match
    @Environment(\.modelContext) var context
    @Environment(\.presentationMode)
        var presentationMode
    
    @State var homeGoal: Int = 0
    @State var visitGoal: Int = 0
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    oneSideView(for: match.homePlayers, and: match.homeTeam!, isHomeSide: true)
                    Spacer()
                    Text("VS.")
                    Spacer()
                    oneSideView(for: match.visitPlayers, and: match.visitTeam!, isHomeSide: false)
                    Spacer()
                }
                Spacer()
                buttonsArea
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Edit Match")
            .toolbar {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
        }

    }
    
    @ViewBuilder
    func oneSideView(for players: [Player], and team: Team, isHomeSide: Bool) -> some View {
        VStack(alignment: .center) {
            HStack {
                ForEach(players) { player in
                    Text(player.name)
                }
            }
            Text(team.name)
                .font(.headline)
            if isHomeSide {
                Stepper(value: $homeGoal, in: 0...1000) {
                    Text("Goal: \(homeGoal)")
                }
                .onAppear{
                    guard let homeGoal = match.homeGoal else { return }
                    self.homeGoal = homeGoal
                }
                .frame(width: 160)
            } else {
                Stepper(value: $visitGoal, in: 0...1000) {
                    Text("Goal: \(visitGoal)")
                }
                .onAppear{
                    guard let visitGoal = match.visitGoal else { return }
                    self.visitGoal = visitGoal
                }
                .frame(width: 160)
            }

        }
    }
    
    @ViewBuilder
    var buttonsArea: some View {
        HStack {
            Spacer()
            Button("Delete") {
                deleteMatch()
            }.buttonStyle(.borderless)
            Spacer()
            Text("   ")
            Spacer()
            Button("Update") {
                updateMatch()
            }.buttonStyle(.borderedProminent)
            Spacer()
        }
    }
    
    private func deleteMatch() {
        context.delete(match)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func updateMatch() {
        match.homeGoal = self.homeGoal
        match.visitGoal = self.visitGoal
        presentationMode.wrappedValue.dismiss()
    }
}

