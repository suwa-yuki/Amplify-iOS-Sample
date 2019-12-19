//
//  ViewController.swift
//  AmplifySample
//
//  Created by Yuki Suwa on 2019/12/19.
//  Copyright © 2019 Yuki Suwa. All rights reserved.
//

import UIKit
import Amplify

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var list = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query()
        subscribe()
    }
    
    @IBAction func postButtonDidTouch(_ sender: Any) {
        let content = textField.text ?? ""
        let note = Note(content: content)
        _ = Amplify.API.mutate(of: note, type: .create) { (event) in
            switch event {
            case .completed(let result):
                switch result {
                case .success(let note):
                    print("API Mutate successful, created note: \(note)")
                    DispatchQueue.main.async {
                        self.textField.text = nil
                    }
                case .failure(let error):
                    print("Completed with error: \(error.errorDescription)")
                }
            case .failed(let error):
                print("Failed with error \(error.errorDescription)")
            default:
                print("Unexpected event")
            }
        }
    }
    
    func query() {
        _ = Amplify.API.query(from: Note.self, where: nil) { (event) in
            switch event {
            case .completed(let result):
                switch result {
                case .success(let notes):
                    print("Successfully retrieved list of notes: \(notes)")
                    self.list = notes
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failed(let error):
                print("Got failed event with error \(error)")
            default:
                print("Should never happen")
            }
        }
    }
    
    func subscribe() {
        _ = Amplify.API.subscribe(from: Note.self, type: .onCreate) { (event) in
            switch event {
            case .inProcess(let subscriptionEvent):
                switch subscriptionEvent {
                case .connection(let subscriptionConnectionState):
                    print("Subsription connect state is \(subscriptionConnectionState)")
                case .data(let result):
                    switch result {
                    case .success(let note):
                        print("Successfully got todo from subscription: \(note)")
                        self.list.append(note)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print("Got failed result with \(error.errorDescription)")
                    }
                }
            case .completed:
                print("Subscription has been closed")
            case .failed(let error):
                print("Got failed result with \(error.errorDescription)")
            default:
                print("Should never happen")
            }
        }
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let note = list[indexPath.row]
        cell.textLabel?.text = note.content
        return cell
    }
    
}

