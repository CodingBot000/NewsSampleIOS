//
//  NetworkMonitor.swift
//  News
//
//  Created by switchMac on 7/21/24.
//


import Network
import Foundation


class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
//                self.isConnected = false
            }
        }
        monitor.start(queue: queue)
    }
}
