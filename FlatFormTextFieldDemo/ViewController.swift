//
//  ViewController.swift
//  FlatFormTextFieldDemo
//
//  Created by Tyler Weidel on 6/3/20.
//  Copyright © 2020 1SE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let ffTextField = OSEFlatFormTextField()
    var stateCycleCount = 1
    var errorLabelCount = 1
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(ffTextField)
        ffTextField.translatesAutoresizingMaskIntoConstraints = false
        ffTextField.widthAnchor.constraint(equalToConstant: 250).isActive = true
        ffTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ffTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true

        ffTextField.placeholder = "Group Name"
        ffTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(named: "neutral-700")
        
        ffTextField.text = "William"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    @objc func tapped() {
        print("tapped")
        view.endEditing(true)
    }
    
    @IBAction func cycleDisplayState(_ sender: Any) {
        stateCycleCount += 1
        switch stateCycleCount {
        case 1:
            ffTextField.displayState = .readOnly
        case 2:
            ffTextField.displayState = .editing
        case 3:
            ffTextField.displayState = .loading
        case 4:
            stateCycleCount = 0
            UIView.animate(withDuration: 0.25) {
                self.ffTextField.displayState = .error(error: "This is an error message because someone made a mistake. But it totally wasn't me, it was the other person who was at fault.")
            }
        default:
            break
        }
    }
}

extension ViewController: UITextFieldDelegate, OSEFlatFormTextFieldRightButtonDelegate {
    func didTapTextFieldRightButton(ofKind kind: OSEFlatFormTextField.State) {
        print("did tap \(kind)")
    }
}
