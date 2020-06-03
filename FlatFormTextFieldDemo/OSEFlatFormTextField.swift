//
//  OSEFlatFormTextField.swift
//  OneSecondEveryday
//
//  Created by Tyler Weidel on 6/1/20.
//

import UIKit

class OSEFlatFormTextField: UIView {
    enum AccessoryState {
        case loading
        case refresh
        case checkmark
        case clear
    }

    private var textField = UITextField()
    private var errorLabel = UILabel()
    private var _accessoryState: AccessoryState?
    private var lineView = UIView(frame: .zero)

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
        setupTextField()
        setupLineView()
        setupErrorLabel()
        
        bringSubviewToFront(textField)
    }
    
    @objc func test() {
        print("test")
    }
    
    private func setupTextField() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        textField.rightViewMode = .always
        textField.delegate = self
        font = UIFont(name: "Maax", size: 16)!
    }

    private func setupLineView() {
        addSubview(lineView)
        lineView.isUserInteractionEnabled = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        lineView.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true
        lineView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5).isActive = true

        lineView.backgroundColor = UIColor(named: "neutral-400")
    }

    private func setupErrorLabel() {
        addSubview(errorLabel)
        errorLabel.isUserInteractionEnabled = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true
        errorLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 5).isActive = true

        errorLabel.numberOfLines = 0
        errorFont = UIFont(name: "Maax", size: 12)!
        errorColor = UIColor(named: "red-500")
        
        let constraint = errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraint.priority = .defaultLow
        constraint.isActive = true
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

    var error: String? {
        get {
            return errorLabel.text
        }
        set {
            errorLabel.text = newValue
        }
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
