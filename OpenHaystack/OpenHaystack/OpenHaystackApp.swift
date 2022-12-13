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
        print(arguments)
        if arguments.count < 2 {
            print("ERROR: PLEASE SPECIFY KEY FILE TO IMPORT")
            exit(-1)
        }
//        var batch = false
//        var verbose = false
        var outfile = ""
        var printout = true
        var decrypt = true
        var skip = false
        for (i, a) in arguments.enumerated() {
            if !skip && (i != 0) && (i != (arguments.count-1)) {
                switch a {
                case "-nd":
                    decrypt = false
                case "--no_decrypt":
                    decrypt = false
//                case "-b":
//                    batch = true
//                case "--batch":
//                    batch = true
//                case "-v":
//                    verbose = true
//                case "--verbose":
//                    verbose = true
                case "-o":
                    outfile = arguments[i+1]
                    printout = false
                    skip = true
                case "--output":
                    outfile = arguments[i+1]
                    printout = false
                    skip = true
                default:
                    print("ERROR: INVALID ARGUMENTS")
                }
            } else {
                skip = false
            }
        }
//        let options = [batch,printout,decrypt]
        let options = [printout,decrypt]
        do {
            let path = arguments.last!
//            if let unwrappedPath = path?.componentsSeparatedByString(","){
//                let path = unwrappedPath
//            }
            try accessoryController.importAccessories(path: path, options: options, outfile: outfile)
            accessoryController.downloadLocationReports(options: options, outfile: outfile) { result in }
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
