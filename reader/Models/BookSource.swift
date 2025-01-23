import Foundation
import SwiftData

@Model
final class BookSource {
    var name: String
    var url: String
    var enabled: Bool
    var searchUrl: String?
    var hasDiscovery: Bool
    var discoveryUrl: String?
    var weight: Int
    var lastUpdateTime: Date
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
        self.enabled = true
        self.hasDiscovery = false
        self.weight = 0
        self.lastUpdateTime = Date()
    }
}