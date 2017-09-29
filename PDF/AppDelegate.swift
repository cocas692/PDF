//
//  AppDelegate.swift
//  PDF
//
//  Created by Ashton Cochrane on 19/09/17.
//  Copyright © 2017 Ashton Cochrane. All rights reserved.
//

import Quartz
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var docs = [URL]()
    var loaded = false

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var viewPDF: PDFView!
    @IBOutlet weak var openPDF: NSButton!
    @IBOutlet weak var holdsPDF: NSComboBox!
    @IBOutlet weak var nextPDF: NSButton!
    @IBOutlet weak var previousPDF: NSButton!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(getter: openPDF), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openPDF(_ sender: NSToolbarItem) {
        let file = NSOpenPanel()
        file.title = "Choose a PDF file"
        file.allowedFileTypes = ["pdf"]
        file.showsHiddenFiles = false
        file.showsResizeIndicator = true
        file.allowsMultipleSelection = true
        file.canChooseFiles = true
        file.canChooseDirectories = false
        file.canCreateDirectories = true
        
        if (file.runModal() == NSModalResponseOK) {
            if holdsPDF.numberOfItems > 0 {
                holdsPDF.removeAllItems()
                docs = [URL]()
            }
            
            self.docs = file.urls
            loaded = true
            
            // Navigation between different PDFs
            if docs.count > 1 {
                nextPDF.isHidden = false
                previousPDF.isHidden = false
            } else {
                nextPDF.isHidden = true
                previousPDF.isHidden = true
            }
            
            // Set combo box to display the current PDF
            for url in docs {
                holdsPDF.addItem(withObjectValue: url.lastPathComponent)
            }
            holdsPDF.stringValue = docs[0].lastPathComponent
            holdsPDF.isHidden = false
            
            setPDF(docs[0])
            
        }
    }
    
    func setPDF(_ url: URL) {
        viewPDF.document = PDFDocument(url: url)
    }
}


