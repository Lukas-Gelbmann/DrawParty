//
//  WordTableViewController.swift
//  DrawParty
//
//  Created by Lukas on 12.01.20.
//  Copyright © 2020 Lukas Gelbmann. All rights reserved.
//

import UIKit
import CoreData

class WordTableViewController:UITableViewController{
    var data:[WordClass] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<WordClass>(entityName: "Word")
        if let listentries = try? context.fetch(request){
            data = listentries
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell")!
        cell.textLabel?.text = self.data[indexPath.row].entry
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //if delet gesture
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //deleting in core data
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<WordClass>(entityName: "Word")
            if let listentries = try? context.fetch(request){
                context.delete(listentries[indexPath.row])
            }
            appDelegate.saveContext()
            tableView.reloadData()
            //removing from list
            self.data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

