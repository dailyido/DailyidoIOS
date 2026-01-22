import SwiftUI

struct PlacesAutocompleteField: View {
    let placeholder: String
    @Binding var selectedPlace: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    var autoFocus: Bool = false

    @StateObject private var locationService = LocationService.shared
    @State private var searchText = ""
    @State private var showSuggestions = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Input field
            HStack {
                TextField(placeholder, text: $searchText)
                    .font(.system(size: 17))
                    .focused($isFocused)
                    .onChange(of: searchText) { newValue in
                        if newValue != selectedPlace {
                            Task {
                                await locationService.searchPlaces(query: newValue)
                            }
                            showSuggestions = !newValue.isEmpty
                        }
                    }

                if locationService.isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        selectedPlace = ""
                        latitude = nil
                        longitude = nil
                        locationService.clearPredictions()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color(hex: Constants.Colors.accent) : Color.gray.opacity(0.3), lineWidth: 1.5)
            )

            // Suggestions dropdown
            if showSuggestions && !locationService.predictions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(locationService.predictions) { prediction in
                        Button(action: {
                            selectPlace(prediction)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(prediction.mainText)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: Constants.Colors.primaryText))

                                Text(prediction.secondaryText)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }

                        if prediction.id != locationService.predictions.last?.id {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: Constants.Colors.cardBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.top, 4)
            }
        }
        .onAppear {
            searchText = selectedPlace
            if autoFocus {
                // Small delay to ensure view is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
        }
    }

    private func selectPlace(_ prediction: PlacePrediction) {
        HapticManager.shared.buttonTap()

        // Extract state abbreviation from secondaryText (e.g., "MA, USA" -> "MA")
        let stateAbbreviation = extractStateAbbreviation(from: prediction.secondaryText)
        let displayName = stateAbbreviation.isEmpty
            ? prediction.mainText
            : "\(prediction.mainText), \(stateAbbreviation)"

        searchText = displayName
        selectedPlace = displayName
        showSuggestions = false
        isFocused = false
        locationService.clearPredictions()

        Task {
            if let details = await locationService.getPlaceDetails(placeId: prediction.placeId) {
                await MainActor.run {
                    latitude = details.latitude
                    longitude = details.longitude
                }
            }
        }
    }

    private func extractStateAbbreviation(from secondaryText: String) -> String {
        // secondaryText is typically "Massachusetts, USA" or "MA, USA" or "State, Country"
        let components = secondaryText.components(separatedBy: ", ")
        guard let firstComponent = components.first else { return "" }

        // If it's already a 2-letter abbreviation, use it
        if firstComponent.count == 2 && firstComponent == firstComponent.uppercased() {
            return firstComponent
        }

        // Map common US state names to abbreviations
        let stateAbbreviations: [String: String] = [
            "Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR",
            "California": "CA", "Colorado": "CO", "Connecticut": "CT", "Delaware": "DE",
            "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID",
            "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS",
            "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME", "Maryland": "MD",
            "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS",
            "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV",
            "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY",
            "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK",
            "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC",
            "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT",
            "Vermont": "VT", "Virginia": "VA", "Washington": "WA", "West Virginia": "WV",
            "Wisconsin": "WI", "Wyoming": "WY", "District of Columbia": "DC"
        ]

        return stateAbbreviations[firstComponent] ?? firstComponent
    }
}

#Preview {
    VStack {
        PlacesAutocompleteField(
            placeholder: "Search for a city...",
            selectedPlace: .constant(""),
            latitude: .constant(nil),
            longitude: .constant(nil)
        )
    }
    .padding()
}
