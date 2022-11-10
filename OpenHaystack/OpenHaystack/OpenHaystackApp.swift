//
//  OpenHaystack – Tracking personal Bluetooth devices via Apple's Find My network
//
//  Copyright © 2021 Secure Mobile Networking Lab (SEEMOO)
//  Copyright © 2021 The Open Wireless Link Project
//
//  SPDX-License-Identifier: AGPL-3.0-only
//

import SwiftUI
import Foundation

@main
struct OpenHaystackApp: App {
    @StateObject var accessoryController: AccessoryController
    var accessoryNearbyMonitor: AccessoryNearbyMonitor?
    var frameWidth: CGFloat? = 0
    var frameHeight: CGFloat? = 0
    
    @State var checkedForUpdates = false

    init() {
        let accessoryController: AccessoryController
        if ProcessInfo().arguments.contains("-preview") {
            accessoryController = AccessoryControllerPreview(accessories: PreviewData.accessories, findMyController: FindMyController())
            self.accessoryNearbyMonitor = nil
            //            self.frameWidth = 1920
            //            self.frameHeight = 1080
        } else {
            accessoryController = AccessoryController()
            self.accessoryNearbyMonitor = AccessoryNearbyMonitor(accessoryController: accessoryController)
        }
        self._accessoryController = StateObject(wrappedValue: accessoryController)
        let arguments = CommandLine.arguments
        if arguments.count != 2 {
            print("ERROR: PLEASE SPECIFY KEY FILE TO IMPORT")
            exit(-1)
        }
        do {
            let path = arguments[1]
            try accessoryController.importAccessories(path: path)
            accessoryController.downloadLocationReports { result in }
//            print("Finished getting reports. Exiting.")
//            exit(0)
        } catch {
            if let importError = error as? AccessoryController.ImportError,
               importError == .cancelled
            {
                //User cancelled the import. No error
                return
            }
            
            print("ERROR: IMPORT FAILED")
            exit(-1)
        }
    }

    var body: some Scene {
        WindowGroup {
            OpenHaystackMainView()
                .environmentObject(self.accessoryController)
                .frame(width: self.frameWidth, height: self.frameHeight)
                .hidden()
        }
    }
}
