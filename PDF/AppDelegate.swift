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

    //Variables for loading and keeping track of PDFs
    var docs = [URL]()
    var loaded = false
    var firstRun = true
    var indexPDF = 0;
    var indexPage = 0
    
    //Variables for bookmarks
    var bookmarks = [String]()
    var bookmarkDict = [String:[String]]()
    
    //Variables for the notes
    var lectureNotesDict = [Int:String]()
    var pageNotesDict = [Int:[String]]()
    var notes: [String] = []
    var prevIndex = 0;
    
    //Variables for the timer
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    
    //Variables for the counter
    var unchanged = 60
    var counterReachsEnd = 60
    var secondsCounter = 60
    var counter = Timer()
    var isCounterRunning = false
    
    //Variables for the date
    var date = Date()
    let dateFormatter = DateFormatter()

    //Variables for searching the PDF
    var vals = [AnyObject]()
    var valsIndex = 0
    
    //Outlets for opening and changing PDFs
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var viewPDF: PDFView!
    @IBOutlet weak var holdsPDF: NSComboBox!
    @IBOutlet weak var nextPDF: NSButton!
    @IBOutlet weak var previousPDF: NSButton!
    @IBOutlet weak var openPDF: NSButton!
    
    //Outlets for the help Panel
    @IBOutlet weak var helpWindow: NSPanel!
    @IBOutlet weak var helpTitle: NSTextField!
    @IBOutlet weak var helpText: NSTextField!
    @IBOutlet weak var helpTop: NSTextField!
    
    //Outlets for changing PDF pages
    @IBOutlet weak var pageNum: NSTextField!
    @IBOutlet weak var nextPage: NSButton!
    @IBOutlet weak var toPage: NSTextField!
    
    //Outlets for bookmarks
    @IBOutlet weak var addBookmark: NSToolbarItem!
    @IBOutlet weak var addBookmarkPanel: NSPanel!
    @IBOutlet weak var addBookmarkName: NSTextField!
    @IBOutlet weak var addBookmarkOK: NSButton!
    @IBOutlet weak var addBookmarkCancel: NSButton!
    @IBOutlet weak var addBookmarkDesc: NSTextField!
    @IBOutlet weak var holdBookmark: NSPopUpButton!
    
    //Outlets for searchbar and stepper
    @IBOutlet weak var textSearch: NSSearchField!
    @IBOutlet weak var searchStepper: NSStepper!
    @IBOutlet weak var searchOutput: NSTextField!
    @IBOutlet weak var lectureNotes: NSTextField!
    
    //Outlets for notes
    @IBOutlet weak var typeNotes: NSTextField!
    @IBOutlet weak var pageButton: NSButton!
    @IBOutlet weak var lectureButton: NSButton!
    
    //Outlets for the clock
    @IBOutlet weak var clockLabel: NSTextField!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    //Outlets for unattended mode
    @IBOutlet weak var countdownLabel: NSTextField!
    @IBOutlet weak var unattendedWindow: NSPanel!
    @IBOutlet weak var getCountdown: NSTextField!
    @IBOutlet weak var openUnattended: NSButton!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        holdBookmark.isHidden = true
        addBookmarkOK.isEnabled = false
        
        typeNotes.isEditable = false
        typeNotes.isHidden = true
        lectureNotes.isEditable = false
        lectureNotes.isHidden = true
        
        unattendedWindow.setIsVisible(false)
        
        pauseButton.isEnabled = false
        
        searchOutput.font = NSFont.boldSystemFont(ofSize: 8.0)
        
        clockLabel.stringValue = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        
        countdownLabel.font = NSFont(name: (timerLabel.font?.fontName)!, size: CGFloat(18.0))
        timerLabel.font = NSFont(name: (timerLabel.font?.fontName)!, size: CGFloat(18.0))
        
        helpPanel()
        
        //Checking for notifications sent
        NotificationCenter.default.addObserver(self, selector: #selector(getter: openPDF), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(typeNotes(notification:)), name: NSNotification.Name.PDFViewPageChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(typeNotes(notification:)), name: NSNotification.Name.NSControlTextDidChange, object: typeNotes)
        NotificationCenter.default.addObserver(self, selector: #selector(typeNotesLecture(notification:)), name: NSNotification.Name.PDFViewDocumentChanged, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(typeNotesLecture(notification:)), name: NSNotification.Name.NSControlTextDidChange, object: lectureNotes)
        NotificationCenter.default.addObserver(self, selector: #selector(enableBookmark(_sender:)), name: NSNotification.Name.NSControlTextDidChange, object: addBookmarkName)
        

        
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    @IBAction func openPDF(_ sender: Any) {
        //openPDF.layer!.backgroundColor = NSColor.white.cgColor
        
        
        //Open the PDF file
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
            
            print("\n\n\(docs)\n\n")
            
            // Set combo box to display the current PDF
            for url in docs {
                    holdsPDF.addItem(withObjectValue: url.lastPathComponent)
            }

            holdsPDF.stringValue = docs[(docs.count-1)].lastPathComponent
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
            
            
            indexPDF = holdsPDF.indexOfSelectedItem
            if indexPDF == -1 {
                indexPDF=0
            }
            viewPDF.document = PDFDocument(url: docs[indexPDF])
            holdsPDF.stringValue = docs[indexPDF].lastPathComponent
            
        }
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        if loaded {
            if viewPDF.canZoomIn() {
                viewPDF.zoomIn(0.5)
            }
        }
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        if loaded {
            if viewPDF.canZoomOut() {
                viewPDF.zoomOut(0.5)
            }
        }
    }
    
    
    func typeNotes(notification:NSNotification) {
        if loaded {
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
                }
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
                pageNotesDict[prevIndex] = notes
                
                if pageNotesDict[indexPDF] != nil {
                    notes = pageNotesDict[indexPDF]!
                    typeNotes.stringValue = notes[0]
                } else {
                    notes.removeAll()
                    for _ in 0...(viewPDF.document?.pageCount)! {
                        notes.append("")
                    }
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
    
    @IBAction func lectureNotes(_ sender: Any) {
        if loaded {
            lectureNotes.isHidden = false
            lectureNotes.isEditable = true
            typeNotes.isHidden = true
            lectureButton.highlight(true)
            pageButton.highlight(false)
            if lectureButton.isHighlighted {
                lectureButton.isEnabled = false
                pageButton.isEnabled = true
            }
        }
    }
    
    
    @IBAction func pageNotes(_ sender: Any) {
        if loaded {
            typeNotes.isHidden = false
            typeNotes.isEditable = true
            lectureNotes.isHidden = true
            pageButton.highlight(true)
            lectureButton.highlight(false)
            if pageButton.isHighlighted {
                pageButton.isEnabled = false
                lectureButton.isEnabled = true
            }
        }
    }
    
    func helpPanel() {
        helpTop.stringValue = "PDF Viewer"
        helpTitle.stringValue = "Help Menu"
        helpTop.font = NSFont(name: (helpTop.font?.fontName)!, size: CGFloat(20.0))
        helpTop.font = NSFont.boldSystemFont(ofSize: 20.0)
        helpTitle.font = NSFont(name: (helpTitle.font?.fontName)!, size: CGFloat(20.0))
        helpTitle.font = NSFont.boldSystemFont(ofSize: 16.0)
        helpText.stringValue = "This is a PDF viewer designed by Ashton \n Cochrane and Tyler Baker.\n\n This is purely for the use of the assignment\n two of the COSC346 paper."
    }
    
    
    
    @IBAction func FitToScreen(_ sender: Any) {
        if loaded {
            viewPDF.scaleFactor = CGFloat(1.0)
        }
    }
    
    @IBAction func prevPage(_ sender: Any) {
        if loaded{
            if viewPDF.canGoToPreviousPage() {
                indexPage -= 1
                viewPDF.goToPreviousPage(window)
            }
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        if loaded {
            if viewPDF.canGoToNextPage() {
                indexPage += 1
                viewPDF.goToNextPage(window)
            }
        }
    }
    
    @IBAction func toPage(_ sender: Any) {
        if loaded {
            let onlyIntFormatter = OnlyIntegerValueFormatter()
            toPage.formatter = onlyIntFormatter
            let numPages = (viewPDF.document?.pageCount)!
            if toPage.stringValue != "" {
                let input = Int(toPage.stringValue)
                if (input != nil) {
                    if input! <= numPages && input! > 0{
                        viewPDF.go(to: (viewPDF.document?.page(at: input!-1))!)
                    }
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
    
    // BOOKMARK COMMENTING BELOW
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
        addBookmarkOK.isEnabled = false
        addBookmarkPanel.close()
        
        
    }

    @IBAction func addBookmarkCancel(_ sender: Any) {
        addBookmarkName.stringValue = ""
        addBookmarkOK.isEnabled = false
        addBookmarkPanel.close()
        
    }

    @IBAction func holdBookmark(_ sender: Any) {
        let key = holdBookmark.titleOfSelectedItem!
        print(key)
        let bookmark = bookmarkDict[key]
        let documentIndex = Int(bookmark![1])
        let page = bookmark![0]
        viewPDF.document = PDFDocument(url: docs[documentIndex!])
        viewPDF.go(to: (viewPDF.document?.page(at: (Int(page)!)-1))!)
        indexPDF = documentIndex!
    }
    
    //TIMER CODE BELOW
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

    @IBAction func startButton(_ sender: NSButton) {
        if isTimerRunning == false {
            runTimer()
            startButton.isEnabled = false
            resumeTapped = false
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
        if (timer.isValid) {
            print("here \n\n\n\n")
            timer.invalidate()
            seconds = 0
            timerLabel.stringValue = timeString(time: TimeInterval(seconds))
            isTimerRunning = false
            pauseButton.isEnabled = true
            startButton.isEnabled = true

        } else {
            pauseButton.title = "Pause"
            seconds = 0
            timerLabel.stringValue = timeString(time: TimeInterval(seconds))
            isTimerRunning = false
            pauseButton.isEnabled = true
            startButton.isEnabled = true
        }
        
    }
    
    // USED IN BOTH TIMER AND COUNTER
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i",hours, minutes, seconds)
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
        unattendedWindow.close()
        //unattendedWindow.setIsVisible(false)
        
    }
    
    func updateCountdown() {
        if counterReachsEnd == 0 {
            if viewPDF.canGoToNextPage() {
                indexPage += 1
                viewPDF.goToNextPage(window)
                secondsCounter = unchanged
                counterReachsEnd = unchanged
                getCountdown.stringValue = ""
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


