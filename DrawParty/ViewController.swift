//
//  ViewController.swift
//  DrawParty
//
//  Created by Lukas on 07.12.19.
//  Copyright © 2019 Lukas Gelbmann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private static let notificationKey = "notificationKey"
    private static let timeCountKey = "timeCountKey"

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timelabel: UILabel!
    
    @IBAction func slider(_ sender: Any) {
        UserDefaults.standard.set(Int(slider.value), forKey: ViewController.timeCountKey)
        timelabel.text = "Time: \(Int(slider.value)*10) s"
        print("Time set to: \(slider.value) ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var time = UserDefaults.standard.integer(forKey:  ViewController.timeCountKey)
        if time > 0 {
            slider.setValue(Float(time), animated: true)
        } else {
            time = 4
            UserDefaults.standard.set(time, forKey: ViewController.timeCountKey)
            slider.setValue(Float(time), animated: true)
        }
        print("Time set to: \(slider.value) ")
        timelabel.text = "Time: \(Int(slider.value)*10) s"
    }
}

