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
    var bookmarks = [String]()
    var bookmarkDict = [String:[String]]()
    var indexPage = 0
    var firstRun = true
    var valsCount = 0
    var valsIndex = 0
    var first = true
    var lectureNotesDict = [Int:String]()
    var pageNotesDict = [Int:[String]]()
    var prevIndex = 0;
    
    //timer
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    
    //Counter
    var unchanged = 60
    var counterReachsEnd = 60
    var secondsCounter = 60
    var counter = Timer()
    var isCounterRunning = false
    
    var date = Date()
    let dateFormatter = DateFormatter()

    
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
    @IBOutlet weak var addBookmarkName: NSTextField!
    @IBOutlet weak var addBookmarkOK: NSButton!
    @IBOutlet weak var addBookmarkCancel: NSButton!
    @IBOutlet weak var addBookmarkDesc: NSTextField!
    @IBOutlet weak var holdBookmark: NSPopUpButton!
    @IBOutlet weak var searchStepper: NSStepper!
    @IBOutlet weak var searchOutput: NSTextField!
    @IBOutlet weak var lectureNotes: NSTextField!
    
    @IBOutlet weak var pageButton: NSButton!
    @IBOutlet weak var lectureButton: NSButton!
    
    @IBOutlet weak var clockLabel: NSTextField!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    //UNATTENDED MODE CODE
    @IBOutlet weak var countdownLabel: NSTextField!
    @IBOutlet weak var unattendedWindow: NSPanel!
    @IBOutlet weak var getCountdown: NSTextField!
    @IBOutlet weak var openUnattended: NSButton!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        holdBookmark.isHidden = true
        addBookmarkOK.isEnabled = false
        typeNotes.isEditable = false
        lectureNotes.isEditable = false
        lectureNotes.isHidden = true
        typeNotes.isHidden = true
        
        unattendedWindow.setIsVisible(false)
        
        pauseButton.isEnabled = false
        
        searchOutput.font = NSFont.boldSystemFont(ofSize: 8.0)
        
        clockLabel.stringValue = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        
        countdownLabel.font = NSFont(name: (timerLabel.font?.fontName)!, size: CGFloat(18.0))
        timerLabel.font = NSFont(name: (timerLabel.font?.fontName)!, size: CGFloat(18.0))
        
        helpTop.stringValue = "PDF Viewer"
        helpTitle.stringValue = "Help Menu"
        helpTop.font = NSFont(name: (helpTop.font?.fontName)!, size: CGFloat(20.0))
        helpTop.font = NSFont.boldSystemFont(ofSize: 20.0)
        helpTitle.font = NSFont(name: (helpTitle.font?.fontName)!, size: CGFloat(20.0))
        helpTitle.font = NSFont.boldSystemFont(ofSize: 16.0)
        helpText.stringValue = "This is a PDF viewer designed by Ashton \n Cochrane and Tyler Baker.\n\n This is purely for the use of the assignment\n two of the COSC346 paper."
        NotificationCenter.default.addObserver(self, selector: #selector(getter: openPDF), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pageNotes(notification:)), name: NSNotification.Name.PDFViewPageChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pageNotes(notification:)), name: NSNotification.Name.NSControlTextDidChange, object: typeNotes)
        NotificationCenter.default.addObserver(self, selector: #selector(pageNotes(notification:)), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(typeNotesLecture(notification:)), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(typeNotesLecture(notification:)), name: NSNotification.Name.NSControlTextDidChange, object: lectureNotes)
        NotificationCenter.default.addObserver(self, selector: #selector(enableBookmark(_sender:)), name: NSNotification.Name.NSControlTextDidChange, object: addBookmarkName)
        

        
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
                //addBookmarkPanel.setIsVisible(true)
            } else {
                nextPDF.isHidden = true
                previousPDF.isHidden = true
            }
            
            // Set combo box to display the current PDF
            for url in docs {
                holdsPDF.addItem(withObjectValue: url.lastPathComponent)
            }
            holdsPDF.stringValue = docs[(docs.count-1)].lastPathComponent
            indexPDF = docs.count-1
            holdsPDF.isHidden = false
            
            viewPDF.document = PDFDocument(url: docs[(docs.count-1)])
            pageNum.stringValue = String(1)
            
            loadNotes()
            
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
            if indexPDF == -1 {
                indexPDF=0
            }
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
    
    @IBAction func saveNotes(_ sender: Any) {
        NSKeyedArchiver.archiveRootObject(notes, toFile: Bundle.main.resourcePath!+"/saveNotes")
    }

    func loadNotes(){
        if let savedNotes = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.resourcePath!+"/saveNotes") as? [String] {
            
            notes = savedNotes
        }
    }
    
    func pageNotes(notification:NSNotification) {
        
        if loaded {
        
            if notes.count == 0 {
                loadNotes()
                
                if notes.count == 0 {
                    for _ in 0...(viewPDF.document?.pageCount)! {
                        notes.append("")
                    }
                }
            }
            
            if notification.name as Notification.Name == NSNotification.Name.NSControlTextDidChange {
                notes[Int(pageNum.stringValue)!-1] = typeNotes.stringValue
                pageNotesDict[indexPDF] = notes
            }
            
            if notification.name as Notification.Name == NSNotification.Name.PDFViewDocumentChanged {
                if !(pageNotesDict[holdsPDF.indexOfSelectedItem] != nil) {
                    loadNotes()
                }
                if !(pageNotesDict[holdsPDF.indexOfSelectedItem] != nil) {
                    notes.removeAll()
                    typeNotes.stringValue = ""
                } else {
                    notes = pageNotesDict[holdsPDF.indexOfSelectedItem]!
                }
                
            }
            if notification.name as Notification.Name == NSNotification.Name.PDFViewPageChanged {
                pageNum.stringValue = (viewPDF.currentPage?.label!)!
                typeNotes.stringValue = notes[Int(pageNum.stringValue)!-1]
            }
        }
        
    }
    
    func typeNotesLecture(notification:NSNotification) {
        if loaded {
            
            if notification.name as Notification.Name == NSNotification.Name.NSControlTextDidChange {
                if indexPDF == prevIndex {
                    lectureNotesDict[indexPDF] = lectureNotes.stringValue
                }
            }
            
            if indexPDF != prevIndex {
                if lectureNotesDict[indexPDF] == nil {
                    lectureNotes.stringValue = ""
                    prevIndex = indexPDF
                } else {
                    lectureNotes.stringValue = lectureNotesDict[indexPDF]!
                    prevIndex = indexPDF
                }
            }

        }
    }
    
    @IBAction func lectureButton(_ sender: Any) {
        lectureNotes.isHidden = false
        lectureNotes.isEditable = true
        typeNotes.isHidden = true
        lectureButton.highlight(true)
        pageButton.highlight(false)
//        lectureButton.setButtonType(NSPushOnPushOffButton)
//        if pageButton.state == 1 {
//            pageButton.setNextState()
//        }
        if lectureButton.isHighlighted {
            lectureButton.isEnabled = false
            pageButton.isEnabled = true
        }
    }
    
    
    @IBAction func pageButton(_ sender: Any) {
        typeNotes.isHidden = false
        typeNotes.isEditable = true
        lectureNotes.isHidden = true
        pageButton.highlight(true)
        lectureButton.highlight(false)
//        pageButton.setButtonType(NSPushOnPushOffButton)
//        if lectureButton.state == 2 {
//            lectureButton.setNextState()
//        }
        if pageButton.isHighlighted {
            pageButton.isEnabled = false
            lectureButton.isEnabled = true
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
        if loaded {
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
    }
    
    
    @IBAction func helpButton(_ sender: NSSearchField) {
        helpWindow.setIsVisible(true)
    }
    
    @IBAction func textSearch(_ sender: Any) {
        let yellow = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
        let blue = NSColor(red: 0, green: 0, blue: 1, alpha: 1)
        if loaded == true {
            textSearch.sendsSearchStringImmediately = true
            let find = textSearch.stringValue
            if find != "" {
                vals = (viewPDF.document?.findString(find, withOptions: 1))!
                if !vals.isEmpty {
                    searchStepper.isHidden = false;
                    valsCount = vals.count - 1
                    vals[0].setColor(yellow)
                    viewPDF.setCurrentSelection(vals[0] as! PDFSelection, animate: true)
                    viewPDF.scrollSelectionToVisible(vals[0])
                    if vals.count > 1 {
                        for i in 0...vals.count {
                            viewPDF.setCurrentSelection(vals[i] as! PDFSelection, animate: true)
                            vals[i].setColor(yellow)
                        }
                    }
                }
            }
        }
    }

    @IBAction func searchStepper(_ sender: NSStepper) {
        if loaded {
            var currVal = searchStepper.integerValue
            let maxSteps = vals.count-1
            print("top curr val \(currVal)")
            print("vals index \(valsIndex)")
            if (vals.count > 0) {
                searchOutput.stringValue = "Selection \(currVal) out of \(maxSteps)"
            }
            if currVal < valsIndex && currVal >= maxSteps {
                viewPDF.setCurrentSelection(vals[currVal] as! PDFSelection, animate: true)
                viewPDF.scrollSelectionToVisible(vals[currVal])
                print("bottom curVal\(currVal)")
            } else if currVal > valsIndex && currVal > 0 && currVal < vals.count{
                currVal -= 1
                viewPDF.setCurrentSelection(vals[currVal] as! PDFSelection, animate: true)
                viewPDF.scrollSelectionToVisible(vals[currVal])
                print(valsIndex)
            }
        }
        
        
    }
    
    @IBAction func addBookmark(_ sender: Any) {
        if loaded {
            addBookmarkPanel.setIsVisible(true)
        }
    }
    
    func enableBookmark(_sender: Any) {
        if addBookmarkName.stringValue != "" {
            addBookmarkOK.isEnabled = true
        } else {
            addBookmarkOK.isEnabled = false
        }
    }
    
    @IBAction func addBookmarkOK(_ sender: Any) {
        
        bookmarkDict[addBookmarkName.stringValue] = [pageNum.stringValue, String(indexPDF)]
        holdBookmark.isHidden = false
        holdBookmark.removeAllItems()
        holdBookmark.addItems(withTitles: Array(bookmarkDict.keys))
        bookmarks.append(addBookmarkName.stringValue)
        addBookmarkName.stringValue = ""
        addBookmarkDesc.stringValue = ""
        addBookmarkOK.isEnabled = false
        addBookmarkPanel.close()
        
        
    }

    @IBAction func addBookmarkCancel(_ sender: Any) {
        addBookmarkName.stringValue = ""
        addBookmarkDesc.stringValue = ""
        addBookmarkOK.isEnabled = false
        addBookmarkPanel.close()
        
    }

    @IBAction func holdBookmark(_ sender: Any) {
        let key = holdBookmark.titleOfSelectedItem!
        print(key)
        let bookmark = bookmarkDict[key]
        let page = bookmark![0]
        
        viewPDF.go(to: (viewPDF.document?.page(at: (Int(page)!)-1))!)
        
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        
        isTimerRunning = true
        pauseButton.isEnabled = true
    }
    
    func updateTimer() {
        if seconds < 0 {
            timer.invalidate()
        } else {
            seconds += 1
            timerLabel.stringValue = timeString(time: TimeInterval(seconds))
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i",hours, minutes, seconds)
    }

    @IBAction func startButton(_ sender: NSButton) {
        if isTimerRunning == false {
            runTimer()
            startButton.isEnabled = false
        }
    }
    
    @IBAction func pauseButton(_ sender: NSButton) {
        if resumeTapped  == false {
            timer.invalidate()
            resumeTapped = true
            pauseButton.title = "Resume"
        } else {
            runTimer()
            resumeTapped = false
            pauseButton.title = "Pause"
        }
    }
    
    @IBAction func resetButton(_ sender: NSButton) {
        timer.invalidate()
        seconds = 0
        timerLabel.stringValue = timeString(time: TimeInterval(seconds))
        isTimerRunning = false
        pauseButton.isEnabled = true
        startButton.isEnabled = true
        pauseButton.title = "Pause"
    }
    
    
    
    //UNATTENDED LECTURE PAUSING CODE
    @IBAction func openUnattended(_ sender: NSButton) {
        if loaded {
            unattendedWindow.setIsVisible(true)
        }
    }
    
    @IBAction func okayButton(_ sender: NSButton) {
        if isCounterRunning == false {
            secondsCounter = Int(getCountdown.stringValue)!
            counterReachsEnd = Int(getCountdown.stringValue)!
            unchanged = Int(getCountdown.stringValue)!
            runCounter()
        }
    }
    
    @IBAction func cancelButton(_ sender: NSButton) {
        counter.invalidate()
        secondsCounter = 0
        countdownLabel.stringValue = timeString(time: TimeInterval(secondsCounter))
        isCounterRunning = false
        unattendedWindow.setIsVisible(false)
    }
    
    func updateCountdown() {
        if counterReachsEnd == 0 {
            if viewPDF.canGoToNextPage() {
                indexPage += 1
                viewPDF.goToNextPage(window)
                secondsCounter = unchanged
                counterReachsEnd = unchanged
            }
        }
        if secondsCounter <= 0 {
            timer.invalidate()
        } else {
            secondsCounter -= 1
            counterReachsEnd -= 1
            countdownLabel.stringValue = timeString(time: TimeInterval(secondsCounter))
        }
    }
    
    func runCounter() {
        counter = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateCountdown)), userInfo: nil, repeats: true)
        
        isCounterRunning = true
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


