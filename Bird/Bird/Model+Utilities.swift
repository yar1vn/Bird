//
//  Model+Utilities.swift
//  Bird
//
//  Created by Yariv Nissim on 9/22/18.
//  Copyright © 2018 Bird. All rights reserved.
//

import Foundation

extension Point {
    /// Calculate the square distance to point
    ///
    /// - parameters:
    ///     - to: points to calculate square distance to
    ///
    /// - important: This method is more efficient since it's not doin square root.
    ///         Use this if the actual distance is not important, for example when finding max/min distance.
    ///
    private func distanceSquared(to: Point) -> Double {
        return (x - to.x) * (x - to.x) + (y - to.y) * (y - to.y)
    }

    /// Calculate the actual distance to point
    ///
    /// - parameters:
    ///     - to: points to calculate square distance to
    ///
    /// - note: This method is more a bit slower than `distanceSquared(to:)`.
    ///         Use this if the actual distance is important.
    ///
    func distance(to: Point) -> Double {
        return sqrt(distanceSquared(to: to))
    }
}

// A utility extension on [Event] to calculate distances between coordinates
extension Collection where Element == Event {
    /// Calculate the total distance of Event objects, from each start event to the next end event.
    ///
    /// - returns: total distance for all the events in the collection.
    ///
    /// - note: This method isn't the most efficient since we're using functional programming
    ///     to filter and then calculate the distances. I tend to avoid pre-optimizing
    ///     until we did some profiling or if we know in advance there's a good reason to.
    ///
    ///     Also, we're going to assume the events are already sorted since it was guaranteed in README:
    ///
    ///       "The list is ordered by time starting with the first event that happened."
    ///
    func calculateTotalDistance() -> Double {
        // Create an sequence of tuples with start and end ride coordinates: [(start, end)]
        let events = zip(filter { $0.type == .startRide }, filter { $0.type == .endRide })

        // Calculate the distance for each pair of events then sum the results
        return events
            .map { start, end in start.coordinate.distance(to: end.coordinate) }
            .reduce(0.0) { (sum, distance) in
                return sum + distance
            }
    }
}
