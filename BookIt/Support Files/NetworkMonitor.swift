//
//  NetworkMonitor.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-23.
//
import Network
import UIKit

extension Notification.Name {
    static let connectivityStatus = Notification.Name(rawValue: "connectivityStatusChanged")
}

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
    private let monitor: NWPathMonitor

    private(set) var isConnected = false
    private(set) var viewController: UIViewController?
    
    /// Checks if the path uses an NWInterface that is considered to
     /// be expensive
     ///
     /// Cellular interfaces are considered expensive. WiFi hotspots
     /// from an iOS device are considered expensive. Other
     /// interfaces may appear as expensive in the future.
     private(set) var isExpensive = false
     
     /// Interface types represent the underlying media for
     /// a network link
     ///
     /// This can either be `other`, `wifi`, `cellular`,
     /// `wiredEthernet`, or `loopback`
     private(set) var currentConnectionType: NWInterface.InterfaceType?

    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.isExpensive = path.isExpensive
            
            // Identifies the current connection type from the
            // list of potential network link types
            self?.currentConnectionType = NWInterface.InterfaceType.allCases.filter { path.usesInterfaceType($0) }.first
            
            NotificationCenter.default.post(name: .connectivityStatus, object: nil)
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
    
    func setObserve(viewController: UIViewController) {
        self.viewController = viewController
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
    }

    @objc func showOfflineDeviceUI(notification: Notification) {
        if NetworkMonitor.shared.isConnected {
            print("Connected")
        } else {
            print("Not connection")
            DispatchQueue.main.async {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:  "Not connected", okActionTitle: "OK", view: self.viewController ?? ViewController())
            }
        }
    }
}
