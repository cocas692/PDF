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
    var notes: [String] = []
    var pdfDict = [String:[String]]()
    var indexPage = 0
    var firstRun = true
    var valsCount = 0
    
    
    var vals = [AnyObject]()
    var snum = 0;
    
    
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
    @IBOutlet weak var textSearch: NSSearchField!
    @IBOutlet weak var helpWindow: NSPanel!
    @IBOutlet weak var helpTitle: NSTextField!
    @IBOutlet weak var helpText: NSTextField!
    @IBOutlet weak var helpTop: NSTextField!
    @IBOutlet weak var pageNum: NSTextField!
    
    @IBOutlet weak var addBookmark: NSToolbarItem!
    @IBOutlet weak var addBookmarkPanel: NSPanel!
    @IBOutlet weak var holdBookmark: NSPopUpButton!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        holdBookmark.isHidden = true
        
        helpWindow.setIsVisible(false)
        addBookmarkPanel.setIsVisible(false)
        helpTop.stringValue = "PDF Viewer"
        helpTitle.stringValue = "Help Menu"
        helpTop.font = NSFont(name: (helpTop.font?.fontName)!, size: CGFloat(20.0))
        helpTop.font = NSFont.boldSystemFont(ofSize: 20.0)
        helpTitle.font = NSFont(name: (helpTitle.font?.fontName)!, size: CGFloat(20.0))
        helpTitle.font = NSFont.boldSystemFont(ofSize: 16.0)
        helpText.stringValue = "This is a PDF viewer designed by Ashton \n Cochrane and Tyler Baker.\n\n This is purely for the use of the assignment\n two of the COSC346 paper."
        NotificationCenter.default.addObserver(self, selector: #selector(getter: openPDF), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(typeNotes(notification:)), name: NSNotification.Name.PDFViewPageChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(typeNotes(notification:)), name: NSNotification.Name.NSControlTextDidChange, object: typeNotes)
        //NotificationCenter.default.addObserver(self, selector: #selector(search(notification:)), name: NSNotification.Name., object: textSearch)
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    @IBAction func openPDF(_ sender: Any) {
        //openPDF.layer!.backgroundColor = NSColor.white.cgColor
        
        
        
        let file = NSOpenPanel()
        file.title = "Select PDF file"
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
                
            }
            
            if !self.docs.contains(file.urls[0]) {
                docs += [URL]()
                self.docs += file.urls
            }
            
            
            loaded = true
            
            toPage.stringValue = ""
            
            // Navigation between different PDFs
            if docs.count > 1 {
                nextPDF.isHidden = false
                previousPDF.isHidden = false
                addBookmarkPanel.setIsVisible(true)
            } else {
                nextPDF.isHidden = true
                previousPDF.isHidden = true
            }
            
            // Set combo box to display the current PDF
            for url in docs {
                holdsPDF.addItem(withObjectValue: url.lastPathComponent)
            }
            holdsPDF.stringValue = docs[(docs.count-1)].lastPathComponent
            if pdfDict[docs[0].lastPathComponent] != nil {
                notes = pdfDict[docs[0].lastPathComponent]!
            }
            holdsPDF.isHidden = false
            
            viewPDF.document = PDFDocument(url: docs[(docs.count-1)])
            pageNum.stringValue = String(1)
            
            
        }

    }
    
    @IBAction func nextPDF(_ sender: Any) {
        if nextPDF.isHidden == false {
            if indexPDF < docs.count - 1 {
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
            //indexPDF = docs.index(of: (viewPDF.document?.documentURL)!)!        //-1 error crashes page jump
            indexPDF = holdsPDF.indexOfSelectedItem
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
    
    
    func typeNotes(notification:NSNotification) {
        var currPage:Int = 0
        
        if loaded && firstRun {
            
            for _ in 0...(viewPDF.document?.pageCount)! {
                notes.append("")
            }
            firstRun = false
        }
        
        if notification.name as Notification.Name == NSNotification.Name.PDFViewPageChanged {

            if loaded {
                for i in 0...(viewPDF.document?.pageCount)! {
                    if viewPDF.currentPage == viewPDF.document?.page(at: i) {
                        currPage = i
                        print("currPage" + String(i))
                        break
                    }
                }
                typeNotes.stringValue = notes[currPage]
                pageNum.stringValue = String(currPage+1)
            }
        }
        
        if notification.name as Notification.Name == NSNotification.Name.NSControlTextDidChange {
            if loaded {
                for i in 0...(viewPDF.document?.pageCount)! {
                    if viewPDF.currentPage == viewPDF.document?.page(at: i) {
                        currPage = i
                        print("currPage" + String(i))
                        break
                    }
                }
                notes[currPage] = typeNotes.stringValue
                pdfDict[docs[0].lastPathComponent] = notes
            }
        }
    }
    
    
    
    @IBAction func addNotes(_ sender: Any) {
        if typeNotes.stringValue != "" {
           // let newNote:NSte
        }
    }
    
    
    
    
    @IBAction func FitToScreen(_ sender: Any) {
        viewPDF.scaleFactor = CGFloat(1.0)
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
        let onlyIntFormatter = OnlyIntegerValueFormatter()
        toPage.formatter = onlyIntFormatter
        let numPages = (viewPDF.document?.pageCount)!
        if toPage.stringValue != "" {
            let input = Int(toPage.stringValue)
            
            if input! <= numPages && input! > 0 {
                viewPDF.go(to: (viewPDF.document?.page(at: input!-1))!)
            } else {
                //dialog box saying "page number doesnt exist"
                let popUp = NSAlert()
                popUp.messageText = "Invalid page number"
                popUp.addButton(withTitle: "OK")
                popUp.runModal()
            }
        }
    }
    
    
    @IBAction func helpButton(_ sender: Any) {
        helpWindow.setIsVisible(true)
    }
    
    @IBAction func textSearch(_ sender: Any) {
        if loaded == true {
            textSearch.sendsSearchStringImmediately = true
            let find = textSearch.stringValue
            if find != "" {
                vals = (viewPDF.document?.findString(find, withOptions: 2))!
                print("vals is \(vals)")
                if !vals.isEmpty {
                    valsCount = vals.count - 1
                    for i in 0...vals.count {
                        viewPDF.setCurrentSelection(vals[i] as! PDFSelection, animate: true)
                        viewPDF.scrollSelectionToVisible(vals[i])
                    }
                }
            }
        }
    }
    

    

    func createBookmark(_ sender: Any) {
        holdBookmark.isHidden = false
        addBookmarkPanel.setIsVisible(true)
        
        
        
        
    }

    
    @IBAction func holdBookmark(_ sender: Any) {
        
        
    }

}


class OnlyIntegerValueFormatter: NumberFormatter {
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        // Ability to reset your field (otherwise you can't delete the content)
        // You can check if the field is empty later
        if partialString.isEmpty {
            return true
        }
        
        // Optional: limit input length
        /*
         if partialString.characters.count>3 {
         return false
         }
         */
        
        // Actual check
        return Int(partialString) != nil
    }
}


