//
//  UserAccessUtils.swift
//  Runner
//
//  Created by Rubens Pischedda on 31/05/23.
//

import Foundation

protocol UserAccessApi {
    // Fetch any entries on the server that are more recent than the start date.
    @discardableResult
    func access(since startDate: Date, completion: @escaping (Result<[ServerEntry], Error>) -> Void) -> DownloadTask
}

// A cancellable download task.
protocol DownloadTask {
    func cancel()
    var isCancelled: Bool { get }
}

// A struct representing the response from the server for a single feed entry.
struct ServerEntry: Codable {
    struct Color: Codable {
        var red: Double
        var blue: Double
        var green: Double
    }

    let timestamp: Date
    let firstColor: Color
    let secondColor: Color
    let gradientDirection: Double
}

