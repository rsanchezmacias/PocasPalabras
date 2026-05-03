import OSLog

enum AppLogger {
    static let dataAccess = Logger(subsystem: "com.pocaspalabras", category: "DataAccess")
    static let notifications = Logger(subsystem: "com.pocaspalabras", category: "Notifications")
}
