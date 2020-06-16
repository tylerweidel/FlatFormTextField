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
    var accessoryCycleCount = 1
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
        if ffTextField.displayState == .inactive {
            ffTextField.displayState = .editable
        } else {
            ffTextField.displayState = .inactive
        }
    }
    
    @IBAction func cycleAccessoryState(_ sender: Any) {
        switch accessoryCycleCount {
        case 1:
            ffTextField.accessoryState = .checkmark
            accessoryCycleCount += 1
        case 2:
            ffTextField.accessoryState = .loading
            accessoryCycleCount += 1
        case 3:
            ffTextField.accessoryState = .refresh
            accessoryCycleCount += 1
        case 4:
            ffTextField.accessoryState = nil
            accessoryCycleCount = 1
        default:
            break
        }
    }
    
    @IBAction func cycleErrorLabel(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            switch self.errorLabelCount {
            case 1:
                let string = "This is an error message because someone made a mistake. But it totally wasn't me, it was the other person who was at fault."
                self.ffTextField.error = string
                self.errorLabelCount += 1
            case 2:
                self.ffTextField.error = nil
                self.errorLabelCount += 1
            case 3:
                let string = "This is an error message because someone made a mistake. But it totally wasn't me."
                self.ffTextField.error = string
                self.errorLabelCount += 1
            case 4:
                self.ffTextField.error = nil
                self.errorLabelCount += 1
            case 5:
                let string = "The error message would go here."
                self.ffTextField.error = string
                self.errorLabelCount = 1
            default:
                break
            }
        }
    }
}

extension ViewController: UITextFieldDelegate, OSEFlatFormTextFieldRightButtonDelegate {
    func didTapTextFieldRightButton(ofKind kind: OSEFlatFormTextField.AccessoryState) {
        print("did tap \(kind)")
    }
}
