import Foundation
import SwiftData

@Model
final class SubscriptionSource {
    var name: String
    var url: String
    var type: String // rss, video, web
    var groupName: String?
    var enabled: Bool
    var isFavorite: Bool
    var lastUpdateTime: Date
    var customHeaders: [String: String]?
    
    init(name: String, url: String, type: String = "rss") {
        self.name = name
        self.url = url
        self.type = type
        self.enabled = true
        self.isFavorite = false
        self.lastUpdateTime = Date()
    }
}