import Foundation
import CoreLocation

struct PlacePrediction: Identifiable, Hashable {
    let id = UUID()
    let placeId: String
    let description: String
    let mainText: String
    let secondaryText: String
}

struct PlaceDetails {
    let name: String
    let latitude: Double
    let longitude: Double
    let formattedAddress: String
}

final class LocationService: ObservableObject {
    static let shared = LocationService()

    @Published var predictions: [PlacePrediction] = []
    @Published var isSearching = false

    private var sessionToken = UUID().uuidString

    private init() {}

    func searchPlaces(query: String) async {
        guard !query.isEmpty else {
            await MainActor.run {
                self.predictions = []
            }
            return
        }

        await MainActor.run {
            self.isSearching = true
        }

        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "types", value: "(cities)"),
            URLQueryItem(name: "key", value: Constants.googlePlacesAPIKey),
            URLQueryItem(name: "sessiontoken", value: sessionToken)
        ]

        guard let url = components.url else {
            await MainActor.run {
                self.isSearching = false
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlacesAutocompleteResponse.self, from: data)

            let predictions = response.predictions.map { prediction in
                PlacePrediction(
                    placeId: prediction.placeId,
                    description: prediction.description,
                    mainText: prediction.structuredFormatting.mainText,
                    secondaryText: prediction.structuredFormatting.secondaryText ?? ""
                )
            }

            await MainActor.run {
                self.predictions = predictions
                self.isSearching = false
            }
        } catch {
            print("Places search error: \(error)")
            await MainActor.run {
                self.isSearching = false
            }
        }
    }

    func getPlaceDetails(placeId: String) async -> PlaceDetails? {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: "name,geometry,formatted_address"),
            URLQueryItem(name: "key", value: Constants.googlePlacesAPIKey),
            URLQueryItem(name: "sessiontoken", value: sessionToken)
        ]

        // Generate new session token for next search
        sessionToken = UUID().uuidString

        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)

            guard let result = response.result else { return nil }

            return PlaceDetails(
                name: result.name,
                latitude: result.geometry.location.lat,
                longitude: result.geometry.location.lng,
                formattedAddress: result.formattedAddress ?? result.name
            )
        } catch {
            print("Place details error: \(error)")
            return nil
        }
    }

    func clearPredictions() {
        predictions = []
    }
}

// MARK: - API Response Models

private struct PlacesAutocompleteResponse: Decodable {
    let predictions: [AutocompletePrediction]
    let status: String
}

private struct AutocompletePrediction: Decodable {
    let placeId: String
    let description: String
    let structuredFormatting: StructuredFormatting

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case description
        case structuredFormatting = "structured_formatting"
    }
}

private struct StructuredFormatting: Decodable {
    let mainText: String
    let secondaryText: String?

    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case secondaryText = "secondary_text"
    }
}

private struct PlaceDetailsResponse: Decodable {
    let result: PlaceResult?
    let status: String
}

private struct PlaceResult: Decodable {
    let name: String
    let geometry: Geometry
    let formattedAddress: String?

    enum CodingKeys: String, CodingKey {
        case name
        case geometry
        case formattedAddress = "formatted_address"
    }
}

private struct Geometry: Decodable {
    let location: Location
}

private struct Location: Decodable {
    let lat: Double
    let lng: Double
}
