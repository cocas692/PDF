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
    var indexPDF = 0;
    
    var indexPage = 0
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var viewPDF: PDFView!
    @IBOutlet weak var holdsPDF: NSComboBox!
    @IBOutlet weak var nextPDF: NSButton!
    @IBOutlet weak var previousPDF: NSButton!
    @IBOutlet weak var openPDF: NSButton!
    @IBOutlet weak var minusZoom: NSButton!
    @IBOutlet weak var nextPage: NSButton!
    @IBOutlet weak var toPage: NSTextField!
    @IBOutlet weak var typeNotes: NSTextField!
    @IBOutlet weak var addNotes: NSButton!
    @IBOutlet weak var zoomIn: NSButton!
    @IBOutlet weak var zoomOut: NSButton!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(getter: openPDF), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    @IBAction func openPDF(_ sender: Any) {
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
            
            viewPDF.document = PDFDocument(url: docs[0])
            
        }

    }
    
    
    @IBAction func nextPDF(_ sender: Any) {
        if nextPDF.isHidden == false {
            if indexPDF != docs.count - 1 {
                indexPDF += 1
                viewPDF.document = PDFDocument(url: docs[indexPDF])
                holdsPDF.stringValue = docs[indexPDF].lastPathComponent
            }
        }
    }
    
    @IBAction func prevPDF(_ sender: Any) {
        if previousPDF.isHidden == false {
            if indexPDF > 0 {
                indexPDF -= 1
                viewPDF.document = PDFDocument(url: docs[indexPDF])
                holdsPDF.stringValue = docs[indexPDF].lastPathComponent
            }

        }
    }
    
    @IBAction func holdsPDF(_ sender: AnyObject) {
        if loaded {
            indexPDF = sender.indexOfSelectedItem
            viewPDF.document = PDFDocument(url: docs[indexPDF])
            holdsPDF.stringValue = docs[indexPDF].lastPathComponent
        }
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        if viewPDF.canZoomIn() {
            viewPDF.zoomIn(0.5)
        }
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        if viewPDF.canZoomOut() {
            viewPDF.zoomOut(0.5)
        }
    }
    
    @IBAction func prevPage(_ sender: Any) {
        if viewPDF.canGoToPreviousPage() {
            indexPage -= 1
            viewPDF.goToPreviousPage(window)
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        if viewPDF.canGoToNextPage() {
            indexPage += 1
            viewPDF.goToNextPage(window)
        }
    }
    
    @IBAction func toPage(_ sender: Any) {
        let numPages = (viewPDF.document?.pageCount)!
        let input = Int(toPage.stringValue)
        if input! < numPages && input! >= 0 {
            viewPDF.go(to: (viewPDF.document?.page(at: input!))!)
        }
    }
}


