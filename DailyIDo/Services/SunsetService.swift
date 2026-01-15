import Foundation
import Solar

final class SunsetService {
    static let shared = SunsetService()

    private init() {}

    func calculateSunset(for date: Date, latitude: Double, longitude: Double) -> Date? {
        let solar = Solar(for: date, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        return solar?.sunset
    }

    func formattedSunsetTime(for date: Date, latitude: Double, longitude: Double) -> String? {
        guard let sunset = calculateSunset(for: date, latitude: latitude, longitude: longitude) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: sunset)
    }

    func goldenHourStart(for date: Date, latitude: Double, longitude: Double) -> Date? {
        guard let sunset = calculateSunset(for: date, latitude: latitude, longitude: longitude) else {
            return nil
        }

        // Golden hour typically starts about 1 hour before sunset
        return Calendar.current.date(byAdding: .hour, value: -1, to: sunset)
    }

    func formattedGoldenHour(for date: Date, latitude: Double, longitude: Double) -> String? {
        guard let goldenHourStart = goldenHourStart(for: date, latitude: latitude, longitude: longitude),
              let sunset = calculateSunset(for: date, latitude: latitude, longitude: longitude) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let startTime = formatter.string(from: goldenHourStart)
        let endTime = formatter.string(from: sunset)

        return "\(startTime) - \(endTime)"
    }
}

// CLLocationCoordinate2D is used by Solar package
import CoreLocation
