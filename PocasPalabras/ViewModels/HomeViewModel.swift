import Foundation

@Observable
final class HomeViewModel {
    var selectedDate = Calendar.current.startOfDay(for: Date())
    var showDayDetail = false
    
    let profile: UserProfile
    
    /// Keep as computed property to refresh updates on life expectancy
    var engine: LifeCalendarEngine {
        LifeCalendarEngine(dateOfBirth: profile.dateOfBirth, lifeExpectancy: profile.lifeExpectancy)
    }

    var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .full
        return f
    }

    init(profile: UserProfile) {
        self.profile = profile
    }

    func openToday() {
        selectedDate = Calendar.current.startOfDay(for: Date())
        showDayDetail = true
    }
}
