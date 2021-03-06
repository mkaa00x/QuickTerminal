//
//  AppDelegate.swift
//  QuickTerminal
//
//  Created by Mohammad Al-Ahdal on 2017-08-06.
//  Copyright © 2017 Mohammad Al-Ahdal. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var alted:Bool = false
    var theView:CustomWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // add global key listener for alt+space
        // Find some way to get system to default allow accessibility rights
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            self.spaceCheck(event: event)
        }
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
            self.altCheck(event: event)
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.spaceCheck(event: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.altCheck(event: $0)
            return $0
        }
        
        self.theView = NSStoryboard.main!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init(rawValue: "start")) as? CustomWindowController
        runAccessibilityCheck()
    }
    
    func runAccessibilityCheck(){
        
        if !AXIsProcessTrustedWithOptions(nil) {
            //notauthorized
            //make plea and then let app quit and restart
            let alert = NSAlert()
            alert.messageText = "We can't run yet!"
            alert.informativeText = "You have to trust us on this, once you press continue, the application will quit because it hasn't been granted the required permissions in the Accessibility pane. Run this application again once you have authorized it under System Preferences > Security & Privacy > Privacy > Accessibility"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Continue")
            alert.runModal()
            let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
            AXIsProcessTrustedWithOptions(options)
            NSApplication.shared.terminate(self)
        }
    }
    
    func altCheck(event:NSEvent){
        //check for .option
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case NSEvent.ModifierFlags.option:
            self.alted = true
            break
        default:
            self.alted = false
            break
        }
    }
    
    func spaceCheck(event:NSEvent){
        //check for Int16 0x31
        switch event.keyCode {
        case 0x31:
            if alted && !theView!.windowIsLoaded{
                //do show
                theView!.loadWindow()
                theView!.showWindow(self)
                theView!.windowIsLoaded = true
                NSApp.activate(ignoringOtherApps: true)
            }else if alted && theView!.windowIsLoaded{
                //do hide
                theView!.close()
                theView!.windowIsLoaded = false
            }else{
                //do nothing
            }
            break
        default:
            //do nothing
            break
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        //close
        if self.theView != nil {
            self.theView!.close()
            self.theView?.windowIsLoaded = false
        }else{
            //Do nothing
        }
        
    }
    
}

