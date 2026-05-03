import Foundation

@Observable
final class HomeViewModel {
    var selectedDate = Calendar.current.startOfDay(for: Date())
    var showDayDetail = false

    let engine: LifeCalendarEngine
    let profile: UserProfile

    var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .full
        return f
    }

    init(profile: UserProfile) {
        self.profile = profile
        self.engine = LifeCalendarEngine(dateOfBirth: profile.dateOfBirth, lifeExpectancy: profile.lifeExpectancy)
    }

    func openToday() {
        selectedDate = Calendar.current.startOfDay(for: Date())
        showDayDetail = true
    }
}
