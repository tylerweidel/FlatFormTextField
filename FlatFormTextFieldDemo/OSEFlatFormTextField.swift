//
//  OSEFlatFormTextField.swift
//  FlatFormTextFieldDemo
//
//  Created by Tyler Weidel on 6/4/20.
//  Copyright © 2020 1SE. All rights reserved.
//

import UIKit

class OSEFlatFormTextField: UIControl {
    enum AccessoryState {
        case loading
        case refresh
        case checkmark
        case clear
    }

    private var stackView = UIStackView()
    private var textField = UITextField()
    private var _accessoryState: AccessoryState?
    private var lineView = UIView(frame: .zero)
    private var errorLabelWrapperView = UIView(frame: .zero)
    private var errorLabel = UILabel()
    
    weak var delegate: UITextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupStackView()
        setupTextField()
        setupLineView()
        setupErrorLabel()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
    }

    private func setupTextField() {
        stackView.addArrangedSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textField.rightViewMode = .always
        textField.delegate = self
        font = UIFont(name: "Maax", size: 16)!
    }

    private func setupLineView() {
        stackView.addArrangedSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        lineView.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true

        lineView.backgroundColor = UIColor(named: "neutral-400")
    }

    private func setupErrorLabel() {
        stackView.addArrangedSubview(errorLabelWrapperView)
        errorLabelWrapperView.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.leadingAnchor.constraint(equalTo: errorLabelWrapperView.leadingAnchor).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: errorLabelWrapperView.trailingAnchor).isActive = true
        errorLabel.topAnchor.constraint(equalTo: errorLabelWrapperView.topAnchor, constant: 10).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: errorLabelWrapperView.bottomAnchor).isActive = true

        errorLabel.numberOfLines = 0
        errorFont = UIFont(name: "Maax", size: 12)!
        errorColor = UIColor(named: "red-500")
        
        errorLabelWrapperView.isHidden = true
    }

    private func updateAccessoryStateView() {
        var image: UIImage?
        switch _accessoryState {
        case .loading:
            // This will be our custom loading animation/icon
            // temporary is a activity indicator for now
            let activityIndicator = UIActivityIndicatorView(frame: .zero)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.heightAnchor.constraint(equalToConstant: 25).isActive = true
            activityIndicator.widthAnchor.constraint(equalToConstant: 25).isActive = true
            activityIndicator.startAnimating()
            // For some reason adding the subview first sets the view correctly on the right of the text field
            // Or else it puts it on the left side
            addSubview(activityIndicator)

            UIView.transition(
                with: textField,
                duration: 0.15,
                options: .transitionCrossDissolve,
                animations: { self.textField.rightView = activityIndicator },
                completion: nil
            )

            return
        case .refresh:
            image = UIImage(named: "refresh")
        case .checkmark:
            image = UIImage(named: "checkmark")
        case .clear:
            image = UIImage()
        case .none:
            break
        }

        setRightView(withImage: image)
    }

    private func setRightView(withImage image: UIImage?) {
        guard let accessoryImage = image else {
            UIView.transition(
                with: textField,
                duration: 0.15,
                options: .transitionCrossDissolve,
                animations: { self.textField.rightView = nil },
                completion: nil
            )
            return
        }

        let imageView = UIImageView(image: accessoryImage)
        let rightView = UIView(frame: .zero)
        rightView.addSubview(imageView)

        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        rightView.widthAnchor.constraint(equalToConstant: 20).isActive = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: rightView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: rightView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit

        // For some reason adding the subview first sets the view correctly on the right of the text field
        // Or else it puts it on the left side
        addSubview(rightView)
        UIView.transition(
            with: textField,
            duration: 0.15,
            options: .transitionCrossDissolve,
            animations: { self.textField.rightView = rightView },
            completion: nil
        )
    }
    
    func setError(errorText: String?, animated: Bool, duration: TimeInterval = 0.25) {
        if let error = errorText {
            self.errorLabel.text = error
            if animated {
                UIView.animate(withDuration: duration) {
                    self.errorLabelWrapperView.isHidden = false
                }
            } else {
                self.errorLabelWrapperView.isHidden = false
            }
        } else {
            if animated {
                UIView.animate(withDuration: duration, animations: {
                    self.errorLabelWrapperView.isHidden = true
                }) { (_) in
                    self.errorLabel.text = nil
                }
            } else {
                self.errorLabelWrapperView.isHidden = true
                self.errorLabel.text = nil
            }
        }
    }

    var error: String? {
        return errorLabel.text
    }

    var accessoryState: AccessoryState? {
        get {
            return _accessoryState
        }
        set {
            _accessoryState = newValue
            updateAccessoryStateView()
        }
    }

    var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }

    var text: String? {
        get {
            return textField.text
        }

        set {
            textField.text = newValue
        }
    }

    var font: UIFont? {
        get {
            return textField.font
        }

        set {
            textField.font = newValue
        }
    }

    var textColor: UIColor? {
        get {
            return textField.textColor
        }

        set {
            textField.textColor = newValue
        }
    }

    var errorFont: UIFont? {
        get {
            return errorLabel.font
        }

        set {
            errorLabel.font = newValue
        }
    }

    var errorColor: UIColor? {
        get {
            return errorLabel.textColor
        }

        set {
            errorLabel.textColor = newValue
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            textField.backgroundColor = backgroundColor
        }
    }

    var separatorColor: UIColor? {
        get {
            return lineView.backgroundColor
        }
        set {
            lineView.backgroundColor = newValue
        }
    }

    var isEditing: Bool = false
}

extension OSEFlatFormTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditing = true
        delegate?.textFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
        delegate?.textFieldDidEndEditing?(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.textFieldDidChangeSelection?(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
}
