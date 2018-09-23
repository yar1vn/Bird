import Foundation

/// Bird events are events which happen in our system, e.g. when a ride is started or ended.
/// A drop event is when a Bird is initially put into the simulation.
///
/// - note: Conforming to hashable is auto synthesized in latest swift and gives us Equatable as well.
public struct Event: Hashable {

    /// The type of the event is one of START_RIDE, END_RIDE, DROP
    enum EventType: String, Hashable {
        case startRide = "START_RIDE"
        case endRide = "END_RIDE"
        case drop = "DROP"
    }

    /// The time in seconds since the start of the simulation.
    let timestamp: Int

    /// The ID of the associated Bird vehicle, e.g. JK5T.
    let birdID: String

    /// The type of the event.
    let type: EventType

    /// The coordinate of the location of where the event happened in the simulation.
    let coordinate: Point

    /// The ID of the associated user, if the event has one.
    let userID: String?
}

/// The coordinate of the location of where the event happened in the simulation.
public struct Point: Hashable {
    let x, y: Double
}

// MARK:- Parsing

// Put this in an extension to separate the parsing logic from the model object
// This will also keep the default initializer for Event which we'll be using inside.
public extension Event {

    /// Initialize an Event object by parsing a comma separated string
    ///
    /// - parameters:
    ///     - eventData: Comma separated string containing event data
    ///
    /// - returns: A new Event object if data was valid, otherwise `nil`
    ///
    /// - note: json would be nicer because we could use Codable.
    ///         Thought about creating my own Encoder object but that's just too much work
    ///         and way more code than this custom initializer.
    ///
    init?(eventData: Substring) {
        let properties = eventData.split(separator: ",")
        guard properties.count >= 6,
            let timestamp = Int(properties[0]),
            let eventType = EventType(rawValue: String(properties[2])),
            let x = Double(properties[3]),
            let y = Double(properties[4])
            else { return nil }

        let birdID = String(properties[1])
        let userID = properties[5].compactNULL()
        let coordinate = Point(x: x, y: y)

        self.init(timestamp: timestamp, birdID: birdID, type: eventType, coordinate: coordinate, userID: userID)
    }

    /// Factory method to create Event objects by parsing a comma separated string from a url
    ///
    /// - parameters:
    ///     - url: URL for a file contaning rows of comma separated string with event data
    ///
    /// - returns: Array of Event objects, or an empty array in case of an error.
    ///
    static func parseEvents(from url: URL) -> [Event] {
        guard let data = try? String(contentsOf: url) else { return [] }
        return data
            .split(separator: "\n") // split by new lines
            .compactMap(Event.init(eventData:))
    }

    /// Factory method to create Event objects by parsing a comma separated string from a file
    ///
    /// - parameters:
    ///     - fileName: Local file name without extension contaning rows of
    ///                 comma separated string with event data
    ///     - extension: Local File extension
    ///
    /// - returns: Array of Event objects, or an empty array in case of an error.
    ///
    /// - note: this is useful if the file is a resource within this prject.
    ///
    static func parseEvents(fileName: String, `extension`: String) -> [Event] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: `extension`)
            else { return [] }
        return parseEvents(from: url) // if we got a valid url, forward this to parseEvents(from url:)
    }
}

private extension StringProtocol {
    /// Replace "NULL" string with nil
    func compactNULL() -> String? {
        return self == "NULL" ? nil : String(self)
    }
}
