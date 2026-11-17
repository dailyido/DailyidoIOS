import XCTest
@testable import TimelineCore

private func t(_ hour: Int, _ minute: Int = 0) -> TimeOfDay { TimeOfDay(hour: hour, minute: minute) }

/// A bride (full hair & makeup track) and a groom (short track), same venue,
/// default vendors.
private func baseQuestionnaire(ceremony: TimeOfDay, firstLook: FirstLookChoice) -> TimelineQuestionnaire {
    var q = TimelineQuestionnaire()
    q.weddingDate = "2026-06-13"
    q.ceremonyVenue = "Chatham Bars Inn"
    q.ceremonyCity = "Chatham, MA"
    q.partners = [
        TimelinePartner(id: "p1", name: "Claire", role: .bride),
        TimelinePartner(id: "p2", name: "Justin", role: .groom),
    ]
    q.ceremonyStart = ceremony
    q.firstLook = firstLook
    q.cocktailMinutes = firstLook == .no ? 90 : 60
    q.receptionEnd = t(23)
    return q
}

/// The "Reception" worked example: cocktail hour ends at 6:00 PM.
/// 4:30 PM civil ceremony (30 min) → cocktail hour 5:00–6:00.
private func receptionExample() -> TimelineQuestionnaire {
    var q = baseQuestionnaire(ceremony: t(16, 30), firstLook: .yes)
    q.hasBlessing = true
    return q
}

private extension TimelineResult {
    func at(_ id: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        guard let item = item(id) else {
            XCTFail("Missing item \(id)", file: file, line: line)
            return "—"
        }
        return item.time.formatted
    }
}

final class TimeOfDayTests: XCTestCase {
    func testFormatting() {
        XCTAssertEqual(t(0).formatted, "12:00 AM")
        XCTAssertEqual(t(12).formatted, "12:00 PM")
        XCTAssertEqual(t(16, 30).formatted, "4:30 PM")
        XCTAssertEqual(TimeOfDay(minutes: 1500).formatted, "1:00 AM")
    }

    func testCodableAsInteger() throws {
        let data = try JSONEncoder().encode(t(14, 15))
        XCTAssertEqual(String(data: data, encoding: .utf8), "855")
        XCTAssertEqual(try JSONDecoder().decode(TimeOfDay.self, from: data), t(14, 15))
    }

    func testQuestionnaireRoundTrips() throws {
        var q = receptionExample()
        q.vendors = [.photographer, .band]
        q.peerToasts = ["Maid of honor", "Best man"]
        q.weekendEvents = [WeekendEventInput(title: "Welcome party", date: "2026-06-12", time: t(19), place: "The Squire")]
        let decoded = try JSONDecoder().decode(TimelineQuestionnaire.self, from: JSONEncoder().encode(q))
        XCTAssertEqual(decoded, q)
    }
}

final class HairAndMakeupTests: XCTestCase {
    /// Spec example: 6 hair + 6 makeup with 2 + 2 artists = 3 rounds = 3.5 hours.
    func testSpecExample() {
        XCTAssertEqual(TimelineEngine.hairAndMakeupRounds(hairCount: 6, makeupCount: 6, hairArtists: 2, makeupArtists: 2), 3)
        XCTAssertEqual(TimelineEngine.hairAndMakeupMinutes(hairCount: 6, makeupCount: 6, hairArtists: 2, makeupArtists: 2), 210)
    }

    func testRoundsUseTheSlowerTeam() {
        // Hair: 5 ÷ 2 → 3 rounds. Makeup: 3 ÷ 3 → 1 round.
        XCTAssertEqual(TimelineEngine.hairAndMakeupRounds(hairCount: 5, makeupCount: 3, hairArtists: 2, makeupArtists: 3), 3)
    }

    func testStartCountsBackFromEnd() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.partners[0].hairCount = 6
        q.partners[0].makeupCount = 6
        q.partners[0].hairArtists = 2
        q.partners[0].makeupArtists = 2
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("p1.hmuEnd"), "2:00 PM")
        XCTAssertEqual(result.at("p1.hmuStart"), "10:30 AM")   // 3.5 hrs earlier
    }

    func testStylistTimesWin() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.partners[0].hairMakeupStart = t(9)
        q.partners[0].hairMakeupEnd = t(13, 30)
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("p1.hmuStart"), "9:00 AM")
        XCTAssertEqual(result.at("p1.hmuEnd"), "1:30 PM")
    }
}

final class FirstLookTests: XCTestCase {
    /// "Before the ceremony: first look", 5:00 PM ceremony — every line.
    func testWorkedExample() {
        let result = TimelineEngine.generate(baseQuestionnaire(ceremony: t(17), firstLook: .yes), branch: .firstLook)
        XCTAssertEqual(result.at("p2.start"), "1:30 PM")                    // groom & groomsmen start
        XCTAssertEqual(result.at("p1.flowers"), "1:30 PM")                  // bouquets delivered
        XCTAssertEqual(result.at("vendor.photographer.arrive"), "1:30 PM")
        XCTAssertEqual(result.at("p1.hmuEnd"), "2:00 PM")
        XCTAssertEqual(result.at("p1.photos"), "2:15 PM")                   // getting-ready photos
        XCTAssertEqual(result.at("p1.dressOn"), "2:30 PM")
        XCTAssertEqual(result.at("photos.firstLook"), "3:00 PM")
        XCTAssertEqual(result.at("photos.family"), "3:30 PM")
        XCTAssertEqual(result.at("photos.weddingParty"), "4:00 PM")
        XCTAssertEqual(result.at("photos.done"), "4:30 PM")
        XCTAssertEqual(result.at("ceremony.guestArrival"), "4:30 PM")
        XCTAssertEqual(result.at("ceremony.officiant"), "4:45 PM")
        XCTAssertEqual(result.at("ceremony.start"), "5:00 PM")
    }

    func testPreCeremonyMomentsPushGettingReadyEarlier() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.preCeremonyMoments = [.lettersOrGifts, .parentFirstLook]
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("photos.firstLook"), "3:00 PM")            // anchor unchanged
        XCTAssertEqual(result.at("moment.parentFirstLook"), "2:30 PM")
        XCTAssertEqual(result.at("moment.lettersOrGifts"), "2:45 PM")
        XCTAssertEqual(result.at("p1.dressOn"), "2:00 PM")                  // 30 min earlier
        XCTAssertEqual(result.at("p2.start"), "1:00 PM")
    }

    func testFamilyPhotoBlockSize() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.familyPhotoGroups = .overTwenty
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.item("photos.family")?.durationMinutes, 45)
        XCTAssertEqual(result.at("photos.weddingParty"), "4:15 PM")
    }
}

final class NoFirstLookTests: XCTestCase {
    /// "Before the ceremony: no first look", 4:00 PM ceremony — every line.
    ///
    /// The spec's table only reconciles if the bride's drive is 30 min and the
    /// groom's is 15: "Bride departs 3:15" with "Bride arrives 3:45" is 30 min,
    /// while the groom's lines use 15. Per-partner drive times model exactly that.
    func testWorkedExample() {
        var q = baseQuestionnaire(ceremony: t(16), firstLook: .no)
        q.partners[0].driveToCeremonyMinutes = 30
        q.partners[1].driveToCeremonyMinutes = 15
        let result = TimelineEngine.generate(q, branch: .noFirstLook)
        XCTAssertEqual(result.at("p2.start"), "1:30 PM")                    // groom's departure − 1.5 hrs
        XCTAssertEqual(result.at("p1.flowers"), "1:45 PM")
        XCTAssertEqual(result.at("vendor.photographer.arrive"), "1:45 PM")
        XCTAssertEqual(result.at("p1.hmuEnd"), "2:15 PM")
        XCTAssertEqual(result.at("p1.photos"), "2:30 PM")
        XCTAssertEqual(result.at("p1.dressOn"), "2:45 PM")
        XCTAssertEqual(result.at("p2.arrive"), "3:15 PM")                   // groom & groomsmen arrive
        XCTAssertEqual(result.at("p1.depart"), "3:15 PM")                   // bride departs
        XCTAssertEqual(result.at("ceremony.guestArrival"), "3:30 PM")
        XCTAssertEqual(result.at("p1.arrive"), "3:45 PM")                   // bride & bridesmaids arrive
    }

    func testGroomFartherAwayStillGetsFullTime() {
        var q = baseQuestionnaire(ceremony: t(16), firstLook: .no)
        q.partners[1].driveToCeremonyMinutes = 45
        let result = TimelineEngine.generate(q, branch: .noFirstLook)
        XCTAssertEqual(result.at("p2.depart"), "2:30 PM")
        XCTAssertEqual(result.at("p2.start"), "1:00 PM")                    // still 1.5 hrs before his own departure
    }

    func testOnSiteMeansNoDeparture() {
        var q = baseQuestionnaire(ceremony: t(16), firstLook: .no)
        q.partners[0].driveToCeremonyMinutes = 0
        let result = TimelineEngine.generate(q, branch: .noFirstLook)
        XCTAssertNil(result.item("p1.depart"))
        XCTAssertEqual(result.at("p1.dressOn"), "3:15 PM")                  // arrival (3:45) − 30
    }

    func testPhotosMoveAfterTheCeremony() {
        let result = TimelineEngine.generate(baseQuestionnaire(ceremony: t(16), firstLook: .no), branch: .noFirstLook)
        XCTAssertNil(result.item("photos.firstLook"))
        XCTAssertEqual(result.at("ceremony.end"), "4:30 PM")
        XCTAssertEqual(result.at("photos.family"), "4:30 PM")
        XCTAssertEqual(result.at("cocktail.start"), "4:30 PM")
        XCTAssertEqual(result.at("couple.joinsCocktail"), "5:15 PM")       // CH + 45
        XCTAssertEqual(result.at("reception.start"), "6:00 PM")            // 90-min default cocktail hour
    }
}

final class CeremonyAndCocktailTests: XCTestCase {
    func testCeremonyLengths() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.ceremonyType = .fullService
        XCTAssertEqual(TimelineEngine.generate(q, branch: .firstLook).at("ceremony.end"), "6:00 PM")
        q.ceremonyType = .religious
        q.traditions = [.unityCandle, .readings, .signing]
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("ceremony.end"), "6:00 PM")                // 45 + 5 + 10
        XCTAssertEqual(result.at("ceremony.signing"), "4:15 PM")
    }

    func testDifferentVenueAddsTravel() {
        var q = baseQuestionnaire(ceremony: t(15), firstLook: .yes)
        q.receptionSameVenue = false
        q.receptionDriveMinutes = 30
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("travel.toReception"), "3:30 PM")
        XCTAssertEqual(result.at("cocktail.start"), "4:00 PM")
        XCTAssertEqual(result.at("reception.start"), "5:00 PM")
    }

    func testSetupLines() {
        var q = receptionExample()
        q.vendors = [.band, .florist, .ceremonyMusicians]
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("vendor.band.setup"), "3:00 PM")          // CH − 2 hrs
        XCTAssertEqual(result.at("vendor.setup"), "2:00 PM")               // CH − 3 hrs default
        XCTAssertEqual(result.at("ceremony.musicians"), "3:45 PM")         // C − 45
        XCTAssertEqual(result.at("vendor.florist.move"), "5:00 PM")        // bouquets moved at CH
        XCTAssertEqual(result.at("reception.roomReveal"), "5:50 PM")       // R − 10
        XCTAssertNil(result.item("vendor.photographer.arrive"))            // not booked
    }
}

final class ReceptionTests: XCTestCase {
    /// "Reception (both versions)", cocktail hour ends 6:00 — every line.
    func testWorkedExample() {
        var q = receptionExample()
        q.dancingMoments = [.bouquetToss]
        q.secondLook = true
        q.lateNightSnack = true
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("reception.start"), "6:00 PM")
        XCTAssertEqual(result.at("reception.introductions"), "6:20 PM")
        XCTAssertEqual(result.at("reception.firstDance"), "6:25 PM")
        XCTAssertEqual(result.at("reception.welcomeToast"), "6:30 PM")
        XCTAssertEqual(result.at("reception.toast1"), "6:35 PM")
        XCTAssertEqual(result.at("reception.toast2"), "6:40 PM")
        XCTAssertEqual(result.at("reception.blessing"), "6:45 PM")
        XCTAssertEqual(result.at("reception.salad"), "6:50 PM")
        XCTAssertEqual(result.at("vendor.meals"), "6:50 PM")
        XCTAssertEqual(result.at("reception.dinner"), "7:20 PM")
        XCTAssertEqual(result.at("reception.cake"), "7:50 PM")
        XCTAssertEqual(result.at("reception.parentDance1"), "8:00 PM")
        XCTAssertEqual(result.at("reception.parentDance2"), "8:05 PM")
        XCTAssertEqual(result.at("reception.openFloor"), "8:10 PM")
        XCTAssertEqual(result.at("reception.dessert"), "8:25 PM")
        XCTAssertEqual(result.at("reception.bouquetToss"), "8:40 PM")
        XCTAssertEqual(result.at("reception.secondLook"), "8:55 PM")
        XCTAssertEqual(result.at("reception.lateNightSnack"), "10:00 PM")  // E − 60
        XCTAssertEqual(result.at("reception.lastDance"), "10:50 PM")
        XCTAssertEqual(result.at("reception.end"), "11:00 PM")
    }

    func testSkippedItemsMoveUp() {
        var q = receptionExample()
        q.hasBlessing = false
        q.cakeCutting = CakeCutting.none
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("reception.salad"), "6:45 PM")             // salad takes the blessing's slot
        XCTAssertEqual(result.at("reception.dinner"), "7:15 PM")
        XCTAssertNil(result.item("reception.cake"))
        XCTAssertEqual(result.at("reception.parentDance1"), "7:45 PM")      // takes the cake's slot (dinner + 30)
        XCTAssertEqual(result.at("reception.openFloor"), "7:55 PM")
    }

    func testNoGrandEntrance() {
        var q = receptionExample()
        q.grandEntrance = GrandEntrance.none
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.item("reception.introductions")?.label, "Couple is seated")
        XCTAssertEqual(result.at("reception.introductions"), "6:20 PM")
        XCTAssertEqual(result.at("reception.firstDance"), "6:25 PM")
    }

    func testToastsDuringDinner() {
        var q = receptionExample()
        q.hasBlessing = false
        q.toastTiming = .duringDinner
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("reception.welcomeToast"), "6:30 PM")      // welcome toast stays before dinner
        XCTAssertEqual(result.at("reception.salad"), "6:35 PM")
        XCTAssertEqual(result.at("reception.toast1"), "6:50 PM")            // salad + 15
        XCTAssertEqual(result.at("reception.toast2"), "6:55 PM")
        XCTAssertEqual(result.at("reception.dinner"), "7:05 PM")            // still salad + 30
    }

    func testToastsAfterDinner() {
        var q = receptionExample()
        q.hasBlessing = false
        q.toastTiming = .afterDinner
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("reception.dinner"), "7:05 PM")
        XCTAssertEqual(result.at("reception.toast1"), "7:25 PM")
        XCTAssertEqual(result.at("reception.toast2"), "7:30 PM")
        XCTAssertEqual(result.at("reception.cake"), "7:35 PM")              // dinner + 30 with two toasts
    }

    func testFirstDanceAfterDinnerGoesBeforeParentDances() {
        var q = receptionExample()
        q.firstDance = .afterDinner
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("reception.cake"), "7:45 PM")
        XCTAssertEqual(result.at("reception.firstDance"), "7:55 PM")
        XCTAssertEqual(result.at("reception.parentDance1"), "8:00 PM")
    }

    func testBuffet() {
        var q = receptionExample()
        q.hasBlessing = false
        q.dinnerService = .buffet
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.item("reception.salad")?.label, "Buffet opens")
        XCTAssertEqual(result.at("reception.salad"), "6:45 PM")
        XCTAssertNil(result.item("reception.dinner"))
        XCTAssertEqual(result.at("reception.cake"), "7:45 PM")              // same overall pace as plated
    }

    func testReceptionEndingAtMidnightAndAfterParty() {
        var q = receptionExample()
        q.receptionEnd = t(0)
        q.hasAfterParty = true
        q.afterPartyPlace = "Hotel bar"
        q.afterPartyEnd = t(1)
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.item("reception.end")?.time.minutes, 1440)
        XCTAssertEqual(result.item("after.end")?.time.minutes, 1500)
        if let after = result.item("after.start") {
            XCTAssertEqual(result.phase(of: after), .afterReception)
        } else {
            XCTFail("Missing after party")
        }
        XCTAssertEqual(result.items.last?.id, "after.end")
    }
}

final class EditingTests: XCTestCase {
    func testPinnedTimeShiftsEverythingAfterIt() {
        let overrides: TimelineOverrides = ["reception.dinner": TimelineOverride(time: t(19, 30))]
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, overrides: overrides)
        XCTAssertEqual(result.at("reception.dinner"), "7:30 PM")
        XCTAssertTrue(result.item("reception.dinner")?.isEdited == true)
        XCTAssertEqual(result.at("reception.cake"), "8:00 PM")
        XCTAssertEqual(result.at("reception.parentDance1"), "8:10 PM")
        XCTAssertEqual(result.at("reception.salad"), "6:50 PM")             // earlier lines unaffected
    }

    func testAnchorsIgnoreOverrides() {
        let overrides: TimelineOverrides = ["ceremony.start": TimelineOverride(time: t(12))]
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, overrides: overrides)
        XCTAssertEqual(result.at("ceremony.start"), "4:30 PM")
        XCTAssertFalse(result.item("ceremony.start")?.isEditable ?? true)
    }

    func testHiddenMomentIsSkipped() {
        let overrides: TimelineOverrides = ["reception.blessing": TimelineOverride(isHidden: true)]
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, overrides: overrides)
        XCTAssertTrue(result.item("reception.blessing")?.isHidden == true)
        XCTAssertFalse(result.visibleItems.contains { $0.id == "reception.blessing" })
        XCTAssertEqual(result.at("reception.salad"), "6:45 PM")
    }

    func testHiddenNonSequenceLineStillAnchorsOthers() {
        let overrides: TimelineOverrides = ["p1.dressOn": TimelineOverride(isHidden: true)]
        let result = TimelineEngine.generate(baseQuestionnaire(ceremony: t(17), firstLook: .yes), branch: .firstLook, overrides: overrides)
        XCTAssertEqual(result.at("p1.photos"), "2:15 PM")
        XCTAssertEqual(result.hiddenItems.map(\.id), ["p1.dressOn"])
    }

    func testReorder() {
        let order = ["reception.introductions", "reception.cake", "reception.firstDance", "reception.welcomeToast",
                     "reception.toast1", "reception.toast2", "reception.blessing", "reception.salad",
                     "reception.dinner", "reception.parentDance1", "reception.parentDance2", "reception.openFloor"]
        var overrides: TimelineOverrides = [:]
        for (index, id) in order.enumerated() { overrides[id] = TimelineOverride(order: index) }
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, overrides: overrides)
        XCTAssertEqual(result.at("reception.cake"), "6:25 PM")
        XCTAssertEqual(result.at("reception.firstDance"), "6:35 PM")        // after the cake's 10-min slot
        let sequence = result.sequences.first { $0.id == "seq.reception" }
        XCTAssertEqual(sequence?.entries.map(\.id), order)
    }

    func testNewMomentKeepsItsDefaultNeighbor() {
        // Order stored before a 2nd toast existed: the new toast lands after toast 1.
        let order = ["reception.introductions", "reception.firstDance", "reception.welcomeToast", "reception.toast1",
                     "reception.blessing", "reception.salad", "reception.dinner", "reception.cake",
                     "reception.parentDance1", "reception.parentDance2", "reception.openFloor"]
        var overrides: TimelineOverrides = [:]
        for (index, id) in order.enumerated() { overrides[id] = TimelineOverride(order: index) }
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, overrides: overrides)
        XCTAssertEqual(result.at("reception.toast2"), "6:40 PM")
        XCTAssertEqual(result.at("reception.blessing"), "6:45 PM")
    }

    func testOverridesForMissingItemsAreIgnored() {
        let overrides: TimelineOverrides = ["reception.garterToss": TimelineOverride(time: t(21))]
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, overrides: overrides)
        XCTAssertNil(result.item("reception.garterToss"))
        XCTAssertEqual(result.at("reception.openFloor"), "8:10 PM")
    }
}

final class TracksTests: XCTestCase {
    func testTwoHairAndMakeupTracks() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.partners = [TimelinePartner(id: "p1", name: "Mallory", role: .bride),
                      TimelinePartner(id: "p2", name: "Morgan", role: .bride)]
        q.partners[0].hairCount = 4; q.partners[0].makeupCount = 4
        q.partners[1].hairCount = 3; q.partners[1].makeupCount = 3
        q.partners[1].hairArtists = 1; q.partners[1].makeupArtists = 1
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("p1.hmuStart"), "11:15 AM")               // 2 rounds = 2 hr 45
        XCTAssertEqual(result.at("p2.hmuStart"), "10:30 AM")               // 3 rounds = 3 hr 30
        XCTAssertEqual(result.item("p2.hmuStart")?.trackName, "Morgan")
        XCTAssertNil(result.item("p1.start"))
        XCTAssertNil(result.item("p2.start"))
    }

    func testPartnerWithNoHairOrMakeupGetsShortTrack() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.partners[0].hairCount = 0
        q.partners[0].makeupCount = 0
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertNil(result.item("p1.hmuStart"))
        XCTAssertEqual(result.at("p1.start"), "1:30 PM")
    }
}

final class SunsetTests: XCTestCase {
    func testSunsetPhotosMoveOffIntroductions() {
        // Sunset 7:00 → target 6:30, inside introductions–salad. Nearest open
        // gap is right after dinner is served (7:25) rather than cocktail hour (5:30).
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, sunset: t(19))
        XCTAssertEqual(result.at("sunset"), "7:00 PM")
        XCTAssertEqual(result.at("couple.sunsetPhotos"), "7:25 PM")
        XCTAssertTrue(result.item("couple.sunsetPhotos")?.detail?.contains("moved") == true)
    }

    func testSunsetPhotosStayWhenFree() {
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, sunset: t(20))
        XCTAssertEqual(result.at("couple.sunsetPhotos"), "7:30 PM")
    }

    func testNoSunsetPhotosBeforeCeremonyEnds() {
        let result = TimelineEngine.generate(receptionExample(), branch: .firstLook, sunset: t(16, 45))
        XCTAssertNil(result.item("couple.sunsetPhotos"))
        XCTAssertTrue(result.warnings.contains { $0.kind == .sunsetBeforeCeremonyEnds })
    }

    func testSunsetPhotosCanBeTurnedOff() {
        var q = receptionExample()
        q.wantsSunsetPhotos = false
        let result = TimelineEngine.generate(q, branch: .firstLook, sunset: t(19))
        XCTAssertNil(result.item("couple.sunsetPhotos"))
        XCTAssertNotNil(result.item("sunset"))
    }
}

final class WarningTests: XCTestCase {
    func testEarlyHairAndMakeup() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.partners[0].hairCount = 8
        q.partners[0].makeupCount = 8
        q.partners[0].hairArtists = 1
        q.partners[0].makeupArtists = 1
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("p1.hmuStart"), "6:45 AM")
        XCTAssertTrue(result.warnings.contains { $0.kind == .earlyHairAndMakeup })
    }

    func testNoFirstLookWarnings() {
        var q = baseQuestionnaire(ceremony: t(16), firstLook: .no)
        q.cocktailMinutes = 60
        q.familyPhotoGroups = .overTwenty
        let kinds = Set(TimelineEngine.generate(q, branch: .noFirstLook).warnings.map(\.kind))
        XCTAssertTrue(kinds.contains(.shortCocktailHour))
        XCTAssertTrue(kinds.contains(.tightFamilyPhotos))
    }

    func testFirstLookHasNoCocktailWarning() {
        let kinds = Set(TimelineEngine.generate(receptionExample(), branch: .firstLook).warnings.map(\.kind))
        XCTAssertFalse(kinds.contains(.shortCocktailHour))
    }

    func testPhotographerLeavesBeforeCake() {
        var q = receptionExample()
        q.photographerHours = 4
        let result = TimelineEngine.generate(q, branch: .firstLook)
        XCTAssertEqual(result.at("vendor.photographer.depart"), "5:00 PM")
        let warning = result.warnings.first { $0.kind == .photographerLeavesEarly }
        XCTAssertNotNil(warning)
        XCTAssertEqual(warning?.relatedItemIds.last, "reception.cake")
    }

    func testFullCoverageHasNoPhotographerWarning() {
        var q = receptionExample()
        q.photographerHours = 10
        XCTAssertFalse(TimelineEngine.generate(q, branch: .firstLook).warnings.contains { $0.kind == .photographerLeavesEarly })
    }

    func testFirstLookAfterSunset() {
        let result = TimelineEngine.generate(baseQuestionnaire(ceremony: t(17), firstLook: .yes), branch: .firstLook, sunset: t(14, 30))
        XCTAssertTrue(result.warnings.contains { $0.kind == .firstLookAfterSunset })
    }
}

final class BranchesAndWeekendTests: XCTestCase {
    func testShowMeBoth() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .both)
        XCTAssertEqual(q.branches, [.firstLook, .noFirstLook])
        q.cocktailMinutes = nil
        let firstLook = TimelineEngine.generate(q, branch: .firstLook)
        let noFirstLook = TimelineEngine.generate(q, branch: .noFirstLook)
        XCTAssertNotNil(firstLook.item("photos.firstLook"))
        XCTAssertNil(noFirstLook.item("photos.firstLook"))
        // Cocktail hour defaults: 60 with a first look, 90 without.
        XCTAssertEqual(firstLook.at("reception.start"), "6:30 PM")
        XCTAssertEqual(noFirstLook.at("reception.start"), "7:00 PM")
    }

    func testRequiredQuestions() {
        var q = TimelineQuestionnaire()
        XCTAssertEqual(q.missingRequired.count, 6)
        q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        XCTAssertTrue(q.isReadyToBuild)
        q.receptionEnd = nil
        XCTAssertEqual(q.missingRequired, [.receptionEnd])
    }

    func testWeekendDefaults() {
        var q = baseQuestionnaire(ceremony: t(17), firstLook: .yes)
        q.hasBrunch = true
        q.vendors = [.rentals]
        q.weekendEvents = [WeekendEventInput(title: "Rehearsal dinner", date: "2026-06-12", time: t(18, 30), place: "The Wequassett")]
        let weekend = TimelineEngine.generate(q, branch: .firstLook).weekend
        let rehearsal = weekend.first { $0.id == "weekend.rehearsal" }
        XCTAssertEqual(rehearsal?.date, "2026-06-12")
        XCTAssertEqual(rehearsal?.time, t(16))
        XCTAssertEqual(weekend.first { $0.id == "weekend.brunch" }?.date, "2026-06-14")
        XCTAssertEqual(weekend.first { $0.id == "weekend.brunch" }?.time, t(10))
        XCTAssertEqual(weekend.map(\.id).first, "weekend.rentalsIn")        // day before, no time sorts first
        XCTAssertEqual(weekend.map(\.title), ["Rentals & tent delivered", "Ceremony rehearsal", "Rehearsal dinner",
                                              "Rentals & tent picked up (morning)", "Farewell brunch"])
    }

    func testTimelineIsChronological() {
        let items = TimelineEngine.generate(receptionExample(), branch: .firstLook, sunset: t(19, 40)).items
        XCTAssertEqual(items.map(\.time), items.map(\.time).sorted())
        XCTAssertEqual(Set(items.map(\.id)).count, items.count)
    }
}

/// The six real 2026 timelines (Caroline & Chris, Claire & Justin, Laura &
/// Jonathan, Mallory & Morgan, Megan & Jeff, Scott & Courtney) are the target
/// validation set. Their answers and finished timelines aren't in the repo yet,
/// so each fixture is a placeholder until Jamie supplies them.
final class RealWeddingFixtureTests: XCTestCase {
    func testRealWeddings() throws {
        throw XCTSkip("Add the six 2026 weddings' answers + expected key times here once Jamie shares the timelines.")
    }
}
