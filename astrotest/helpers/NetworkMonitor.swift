//
//  NetworkMonitor.swift
//  astrotest
//
//  Created by Abhilash Mishra on 23/03/23.
//

import Foundation
import Network
import Combine

/// Checks on network access
final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private(set) var isConnected = true
        
    static let shared = NetworkMonitor()
    
    private init() {
        monitor.pathUpdateHandler = {[weak self] path in
            if path.status == .satisfied {
                self?.isConnected = true
            } else {
                self?.isConnected = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
