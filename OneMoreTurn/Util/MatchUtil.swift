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
}
