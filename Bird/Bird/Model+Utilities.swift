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
    ///              For better performance - use this method only if the actual distance is not important,
    ///              for example when finding max/min distance or for comparisons.
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
    func distance(to: Point) -> Distance {
        // round to 2 decimal points
        return (sqrt(distanceSquared(to: to)) * 100).rounded() / 100
    }
}

extension Event {
    /// Calculate the time difference between the events
    ///
    /// - parameters:
    ///     - to: The event to calculate to time difference to
    ///
    /// - returns: Seconds between this event and `to`. This will always be positive.
    ///
    func time(to: Event) -> Seconds {
        return abs(to.timestamp - timestamp) // time has to be positive, use abs make sure.
    }
}

extension Ride {
    /// Distance between start and end points.
    var distance: Distance {
        return startEvent.coordinate.distance(to: endEvent.coordinate)
    }

    /// Duration is seconds between start event and end event.
    var durationInSeconds: Seconds {
        return startEvent.time(to: endEvent)
    }

    /// Duration is minutes between start event and end event.
    /// - note: This value is rounded up to include partial ride minutes.
    var durationInMinutes: Minutes {
        return Int(ceil(Double(startEvent.time(to: endEvent)) / 60.0))
    }

    /// Calculate the cost for a single ride
    ///
    /// - parameters:
    ///     - initialCost: This cost is always added to any ride. Default is 1.
    ///     - costPerMinute: The cost per each minute of the duration of the ride. Default is 0.15.
    ///     - minimumDuration: The minimum duration a ride has to have to be charged. Otherwise there's no cost. Default is 1.
    ///
    /// - returns: The total cost of the ride, including `initialCost`.
    ///            If the duration was less than `minimumDuration, return 0.
    ///
    func calculateCost(initialCost: Cost = 1.0, costPerMinute: Cost = 0.15, minimumDuration: Minutes = 1) -> Double {
        guard durationInMinutes > 1 else { return 0 }
        // round to 2 decimal points
        return ((initialCost + Double(durationInMinutes) * costPerMinute) * 100).rounded() / 100
    }

    /// Calculate the time difference between the current EndRide event, and the to StartRide event.
    ///
    /// - parameters:
    ///     - to: The ride to calculate to time difference to
    ///
    /// - returns: Seconds between this ride and `to`. This will always be positive.
    ///
    func time(to: Ride) -> Seconds {
        return to.startEvent.time(to: self.endEvent)
    }
}

// A utility extension on [Event]
extension Collection where Element == Event {
    /// Create an array of concrete Ride objects with start and end ride events.
    /// Match each start event with the next end event to create a ride. Extra events that can't be paired will be dropped.
    ///
    /// - returns: Array of Rides.
    ///
    /// - note: We're going to assume the events are already sorted since it was guaranteed in README:
    ///
    ///     _"The list is ordered by time starting with the first event that happened."_
    ///
    /// - complexity: O(n)
    ///
    func getRides() -> [Ride] {
        /// Match each start event with the next end event to create a ride. Extra events that can't be paired will be dropped.
        return zip(filter { $0.type == .startRide }, filter { $0.type == .endRide })
            .compactMap(Ride.init)
    }

    /// Calculate the total distance of all rides.
    ///
    /// - returns: Total distance for all the rides in the collection.
    ///
    /// - note: This method isn't the most efficient since we're using functional programming
    ///     to get the rides, map and then calculate the distances. I tend to avoid pre-optimizing
    ///     until we did some profiling or if we know in advance there's a good reason to.
    ///
    func calculateTotalDistance() -> Double {
        return getRides()
            .map { $0.distance }
            .reduce(0.0) { $0 + $1 } // Sum the results
    }

    /// Calculate the total cost of all rides.
    ///
    /// - returns: Total cost for all the rides in the collection.
    ///
    func calculateTotalCost() -> Double {
        return getRides()
            .map { $0.calculateCost() } // Calculate the cost for each ride
            .reduce(0.0) { $0 + $1 } // Sum the results
    }

    /// Calculate the longest wait time between of all rides.
    ///
    /// - returns: Longest wait time for all the rides in the collection.
    ///
    func findLongestWaitTime() -> Seconds {
        let rides = getRides()

        return zip(rides, rides.dropFirst()) // Match every ride with next ride after it.
            .map { previous, next in previous.time(to: next) } // Calculate the wait time between the rides
            .max() ?? 0 // Find the ride with the longest wait time
    }

    /// Calculate the average speed for all rides.
    ///
    /// __Use the following formulas:__
    ///
    /// Speed = Distance/Time.
    ///
    /// Average Speed = Total Distance/Total Time.
    ///
    /// - returns: Average speed in Miles per Hour for all the rides in the collection.
    ///
    /// - note: Assume distance is in __meters__ when performing calculation
    ///
    func calculateAverageSpeed() -> Double {
        let rides = getRides()
        let totalDistance = rides.reduce(0.0) { $0 + $1.distance }
        let totalDurationInSeconds = rides.map { $0.durationInSeconds }.reduce(0) { $0 + $1 }
        let averageSpeed = totalDistance / Double(totalDurationInSeconds)

        // Convert from meters per second to miles per hour
        let metersPerSecond = Measurement(value: averageSpeed, unit: UnitSpeed.metersPerSecond)
        let mph = metersPerSecond.converted(to: UnitSpeed.milesPerHour)

        // round to 2 decimal points
        return (mph.value * 100).rounded() / 100
    }
}
