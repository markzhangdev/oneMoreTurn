//
//  UserSettings.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 2/10/2023.
//

import Foundation

@Observable
class UserSettings {
    
    static let shared = UserSettings()
    var homeTeamScale: Int {
        didSet {
            UserDefaults.standard.set(homeTeamScale, forKey: UserSettings.homeTeamScaleKey)
        }
    }
    var winPoints: Int {
        didSet {
            UserDefaults.standard.set(winPoints, forKey: UserSettings.winPointsKey)
        }
    }
    var drawPoints: Int {
        didSet {
            UserDefaults.standard.set(drawPoints, forKey: UserSettings.drawPointsKey)
        }
    }
    var losePoints: Int {
        didSet {
            UserDefaults.standard.set(losePoints, forKey: UserSettings.losePointsKey)
        }
    }
    
    var handicapPoints: Int {
        didSet {
            UserDefaults.standard.set(losePoints, forKey: UserSettings.handicapPointsKey)
        }
    }
    
    init() {
        UserDefaults.standard.register(defaults: [
            UserSettings.homeTeamScaleKey: 2,
            UserSettings.winPointsKey: 3,
            UserSettings.drawPointsKey: 1,
            UserSettings.losePointsKey: 0,
            UserSettings.handicapPointsKey: 3
                    ]
                )
        self.homeTeamScale = UserDefaults.standard.integer(forKey: UserSettings.homeTeamScaleKey)
        self.winPoints = UserDefaults.standard.integer(forKey: UserSettings.winPointsKey)
        self.drawPoints = UserDefaults.standard.integer(forKey: UserSettings.drawPointsKey)
        self.losePoints = UserDefaults.standard.integer(forKey: UserSettings.losePointsKey)
        self.handicapPoints = UserDefaults.standard.integer(forKey: UserSettings.handicapPointsKey)
    }
}

extension UserSettings {
    static let homeTeamScaleKey = "HomeTeamScaleKey"
    static let winPointsKey = "WinPointsKey"
    static let drawPointsKey = "DrawPointsKey"
    static let losePointsKey = "LosePointsKey"
    static let handicapPointsKey = "HandicapPointsKey"
}

struct UserSettingsUseCase {
    let shared = UserSettings.shared
}
