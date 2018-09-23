//
//  main.swift
//  Bird
//
//  Created by Yariv Nissim on 9/22/18.
//  Copyright © 2018 Bird. All rights reserved.
//

import Foundation

// Parse Event objects from "event.txt" file
let events = Event.parseEvents(fileName: "events", extension: "txt")

//
// 1. What is the total number of Bird vehicles dropped off in the simulation?
//

// Filter only drop events and print their count
let dropEvents = events.filter { $0.type == .drop }
print("1. What is the total number of Bird vehicles dropped off in the simulation? \(dropEvents.count)")

//
// 2. Which Bird ends up the farthest away from its drop location? What is the distance?
//

// Group all events for each bird in a dictionary of type `[BirdID: Events]`
// This is a new method is Swift 4. Amazing, right?!
let birds = Dictionary(grouping: events) { $0.birdID }

let maxDistanceBird = birds
    // For each Bird in the dictionary, calculate the distance between DROP and last END_RIDE
    .mapValues { events -> Double in
        // We're guaranteed the array is sorted, so we can assume the first and last events
        //  are DROP and END_RIDE (or we can use first(where:), last(where:) if we have to)
        guard let dropLocation = events.first?.coordinate,
            let lastLocation = events.last?.coordinate
            else { return 0 }
        return dropLocation.distance(to: lastLocation)
    }
    .max { $0.value < $1.value } // Then find the Bird with the maximum distance

if let bird = maxDistanceBird {
    print("""
          2. Which Bird ends up the farthest away from its drop location? \(bird.key)
             What is the distance? \(bird.value)
          """
    )
}

//
// 3. Which Bird has traveled the longest distance in total on all of its rides? How far is it?
//

let maxTotalDistanceBird = birds
    .mapValues { $0.calculateTotalDistance() } // For each Bird in the dictionary, calculate the total distance
    .max { $0.value < $1.value } // Then find the Bird with the maximum distance

if let bird = maxTotalDistanceBird {
    print("""
          3. Which Bird has traveled the longest distance in total on all of its rides? \(bird.key)
             How far is it? \(bird.value)
          """
    )
}
