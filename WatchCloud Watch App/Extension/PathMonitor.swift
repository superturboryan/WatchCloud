//
//  PathMonitor.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-26.
//

import Network

final class PathMonitor {

    static let shared = PathMonitor()
    
    var currentPath = Path.other
    
    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "PathMonitor")
    
    init() {
        listenForUpdates()
    }
    
    func listenForUpdates() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            if path.usesInterfaceType(.wifi) {
                self?.currentPath = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.currentPath = .cellular
            } else {
                self?.currentPath = .other
            }
        }
        pathMonitor.start(queue: queue)
    }
}

extension PathMonitor {
    enum Path {
        case cellular, wifi, other
        
        var isCellular: Bool {
            self == .cellular
        }
    }
}
