//
//  SettingsView.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Query var teams: [Team] = []
    @Query var players: [Player] = []
    @Environment(\.modelContext) var context
    
    @Environment(UserSettings.self) private var userSettings: UserSettings

    
    @State
    var newPlayerName: String = ""
    
    @State
    var newTeamName: String = ""
    
    var body: some View {
        NavigationView {

            List {
                choicePlayerView
                choiceHomeTeamScale
                choiceResultPoints
                choiceTeamView
            }
            .navigationBarTitle("Settings")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: prefillData, label: {
                    Text("Prefill")
                })
                EditButton()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())



    }
    
    @ViewBuilder
    var choiceTeamView: some View {
            Section(header: Text("Choose Team")) {
                ForEach(teams) { team in
                    HStack {
                        Text(team.name)
                        Spacer()
                        Toggle("", isOn: Bindable(team).isInGame)
                    }
                }
                .onDelete(perform: deleteTeam)
                HStack {
                    
                    TextField("New team name", text: $newTeamName)
                    Button(action: addTeam) {
                        Image(systemName: "plus.circle")
                    }
                    .foregroundColor(.accentColor)
                }
            }
    }
    
    @ViewBuilder
    var choicePlayerView: some View {
            Section(header: Text("Choose Player")) {
                ForEach(players) { player in
                    HStack {
                        Text(player.name)
                        Stepper(value: Bindable(player).handicapCount, in: 0...100) {
                            Text("Handicap Count: \(player.handicapCount)")
                        }
                        Toggle("", isOn: Bindable(player).isInGame)
                    }
                }
                .onDelete(perform: deletePlayer)
                HStack {
                    
                    TextField("New player name", text: $newPlayerName)
                    Button(action: addPlayer) {
                        Image(systemName: "plus.circle")
                    }
                    .foregroundColor(.accentColor)
                }
            }
    }
    
    @ViewBuilder
    var choiceHomeTeamScale: some View {
        Section(header: Text("Choose Home Team Scale")) {
            Stepper(value: Bindable(userSettings).homeTeamScale, in: 0...players.filter{$0.isInGame}.count) {
                Text("Home Team Members: \(userSettings.homeTeamScale)")
            }
        }
    }
    
    @ViewBuilder
    var choiceResultPoints: some View {
        Section(header: Text("Choose Match Result Points")) {
            Stepper(value: Bindable(userSettings).winPoints, in: 0...1000) {
                Text("Win Points: \(userSettings.winPoints)")
            }
            Stepper(value: Bindable(userSettings).drawPoints, in: 0...1000) {
                Text("Draw Points: \(userSettings.drawPoints)")
            }
            Stepper(value: Bindable(userSettings).losePoints, in: 0...1000) {
                Text("Lose Points: \(userSettings.losePoints)")
            }
            Stepper(value: Bindable(userSettings).handicapPoints, in: 0...1000) {
                Text("Handicap Points: \(userSettings.handicapPoints)")
            }
        }
    }
    
    private func addTeam() {
        let newTeam = Team(name: newTeamName)
        context.insert(newTeam)
        newTeamName = ""
    }

    private func deleteTeam(at offsets: IndexSet) {
        for index in offsets {
            context.delete(teams[index])
        }
    }


    private func addPlayer() {
        let newPlayer = Player(name: newPlayerName)
        context.insert(newPlayer)
        newPlayerName = ""
    }

    private func deletePlayer(at offsets: IndexSet) {
        for index in offsets {
            context.delete(players[index])
        }
    }
    
    private func prefillData() {
        PrefillData.teams.forEach { team in
            if !teams.map(\.name).contains(team) {
                let newTeam = Team(name: team, isInGame: true)
                    context.insert(newTeam)
            }

        }
        
        PrefillData.players.forEach { player in
            if !players.map(\.name).contains(player) {
                let newPlayer = Player(name: player, isInGame: true)
                context.insert(newPlayer)
            }
        }
    }
}

#Preview {
    SettingsView()
}
