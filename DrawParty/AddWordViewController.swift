//
//  AddWordViewController.swift
//  DrawParty
//
//  Created by Lukas on 12.01.20.
//  Copyright © 2020 Lukas Gelbmann. All rights reserved.
//

import UIKit
import CoreData

class AddWordViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func save(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let listentry = WordClass(context: context)
            listentry.entry = inputField.text!
            appDelegate.saveContext()
            navigationController?.popViewController(animated: true)
        }
    }

