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
        ffTextField.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
        switch errorLabelCount {
        case 1:
            ffTextField.error = "This is an error message because someone made a mistake. But it totally wasn't me, it was the other person who was at fault."
            errorLabelCount += 1
        case 2:
            ffTextField.error = nil
            errorLabelCount += 1
        case 3:
            ffTextField.error = "This is an error message because someone made a mistake. But it totally wasn't me."
            errorLabelCount += 1
        case 4:
            ffTextField.error = nil
            errorLabelCount += 1
        case 5:
            ffTextField.error = "The error message would go here."
            errorLabelCount = 1
        default:
            break
        }
                
        UIView.animate(withDuration: 0.25) {
            self.ffTextField.layoutIfNeeded()
        }
    }

}

