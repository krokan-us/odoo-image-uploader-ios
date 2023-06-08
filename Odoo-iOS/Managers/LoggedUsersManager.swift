//
//  LoggedUsersManager.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 8.06.2023.
//

import Foundation
import UIKit

struct LoggedUser: Codable {
    let id: Int
    let username: String
    var URL: URL
    var database: String
    var userName: String
    var profileImageData: String
    var lastLoginDate: Date
}

class LoggedUsersManager {
    static let shared = LoggedUsersManager()
    
    func addLoggedUser(user: LoggedUser) {
        var loggedUsers = getLoggedUsers()
        
        if let existingUserIndex = loggedUsers.firstIndex(where: { $0.id == user.id }) {
            // Remove the existing user from the array
            loggedUsers.remove(at: existingUserIndex)
        }
        
        loggedUsers.append(user)
        loggedUsers.sort { $0.lastLoginDate > $1.lastLoginDate }
        removeOldestUserIfNeeded(&loggedUsers)
        saveLoggedUsers(loggedUsers)
    }
    
    func getLoggedUsers() -> [LoggedUser] {
        if let data = UserDefaults.standard.data(forKey: "LoggedUsers"),
           let loggedUsers = try? JSONDecoder().decode([LoggedUser].self, from: data) {
            return loggedUsers
        }
        return []
    }
    
    private func saveLoggedUsers(_ loggedUsers: [LoggedUser]) {
        if let data = try? JSONEncoder().encode(loggedUsers) {
            UserDefaults.standard.set(data, forKey: "LoggedUsers")
        }
    }
    
    private func removeOldestUserIfNeeded(_ loggedUsers: inout [LoggedUser]) {
        if loggedUsers.count > 5 {
            loggedUsers.removeLast()
        }
    }
    
    func getLastlyLoggedUser() -> LoggedUser? {
        let loggedUsers = getLoggedUsers()
        return loggedUsers.first
    }
}
