//
//  DrawViewController.swift
//  DrawParty
//
//  Created by Lukas on 07.12.19.
//  Copyright © 2019 Lukas Gelbmann. All rights reserved.
//

import UIKit
import CoreData
import PencilKit

class DrawViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIScreenshotServiceDelegate{
    
    private static let timeCountKey = "timeCountKey"
    var hide = false
    var words = [String]()
    var randomNumber = 0
    var dataModelController = DataModelController()
    var drawingIndex: Int = 0
    var signatureGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var pencilFingerBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var showHideButton: UIBarButtonItem!
    
    @IBAction func ShowHide(_ sender: Any) {
        hide.toggle()
        if hide == false {
            showHideButton.title = "Hide"
            title = words[randomNumber]
        } else {
            showHideButton.title = "Show"
            title = ""
        }
    }
    
    @IBAction func next(_ sender: Any) {
        remainingTime.text = "0"
    }
    
    // Action method: Turn finger drawing on or off.
    @IBAction func toggleFingerPencilDrawing(_ sender: Any) {
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerBarButtonItem.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    var remainingTime: UILabel = {
        let time = UILabel()
        time.text = "0"
        time.textAlignment = .center
        time.font = time.font.withSize(40)
        return time
    }()
    
    var spaceLabel: UILabel = {
        let time = UILabel()
        time.text = " "
        time.textAlignment = .center
        time.textColor = .black
        time.font = time.font.withSize(20)
        return time
    }()
    
    //setup 
    override func viewDidLoad() {
        super.viewDidLoad()
        //check if darkmode
        if self.traitCollection.userInterfaceStyle == .dark {
            remainingTime.textColor = .white
        } else {
            remainingTime.textColor = .black
        }
        dataModelController = DataModelController()
        createStackView()
        if(fetchWords()){
            timingLogic()
        } else {
            showAlert()
        }
    }
    
    func createStackView(){
        let stackView = UIStackView(arrangedSubviews: [remainingTime,spaceLabel])
        view.addSubview(stackView)
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = false
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func fetchWords() -> Bool {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<WordClass>(entityName: "Word")
        if let listentries = try? context.fetch(request){
            for entry in listentries {
                words.append(entry.entry!)
            }
        }
        if words.count == 0 {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            return false
        }
        return true
    }
    
    func timingLogic(){
        //timing logic / reset of the canvas / change of word ...
        let allTime = UserDefaults.standard.integer(forKey: DrawViewController.timeCountKey) * 10 - 1
        
        // init state
        randomNumber = Int.random(in: 0..<words.count)
        var timeUntilChange = allTime
        hide = true
        self.title = ""
        self.showHideButton.title = "Show"
        remainingTime.text = "\(allTime)"
        
        //timer: every second this gets called
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            if self.remainingTime.text == "0" { //new round started
                self.newRound()
                timeUntilChange = allTime
            } else {
                timeUntilChange = timeUntilChange - 1 // 1 second less
            }
            // set new time
            self.remainingTime.text = "\(timeUntilChange)"
        })
    }
    
    func newRound(){
        print("new round")
        canvasView.drawing = PKDrawing() //create new drawing
        randomNumber = Int.random(in: 0 ..< self.words.count) //new random word
        hide = true //hide the word
        title = ""
        showHideButton.title = "Show"
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "You have to add words first", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    // Set up the drawing initially.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set up the canvas view with the first drawing from the data model.
        canvasView.delegate = self
        canvasView.drawing = PKDrawing()
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = false
        // Set up the tool picker, using the window of our parent because our view has not
        // been added to a window yet.
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(self)
            updateLayout(for: toolPicker)
            canvasView.becomeFirstResponder()
        }
    }
       
    // Hide the home indicator, as it will affect latency.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
       
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
       
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
       
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
        } else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
        }
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
}
