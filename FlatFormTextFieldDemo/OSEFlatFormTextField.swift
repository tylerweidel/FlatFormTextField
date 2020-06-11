//
//  OSEFlatFormTextField.swift
//  OneSecondEveryday
//
//  Created by Tyler Weidel on 6/1/20.
//

import UIKit

protocol OSEFlatFormTextFieldRightButtonDelegate {
    func didTapTextFieldRightButton(ofKind kind: OSEFlatFormTextField.AccessoryState)
}

class OSEFlatFormTextField: UIControl {
    
    enum Constants {
        static let rightViewSize: CGFloat = 16
    }
    enum AccessoryState {
        case loading
        case refresh
        case checkmark
    }

    private var stackView = UIStackView()
    private var textField = UITextField()
    private var lineView = UIView(frame: .zero)
    private var errorLabelWrapperView = UIView(frame: .zero)
    private var errorLabel = UILabel()

    weak var delegate: (UITextFieldDelegate & OSEFlatFormTextFieldRightButtonDelegate)?

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
        textField.rightViewMode = .unlessEditing
        textField.clearButtonMode = .whileEditing
        textColor = UIColor(named: "neutral-40")
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
        switch accessoryState {
        case .loading:
            setRightView(withImage: UIImage(named: "Loading"))
        case .refresh:
            setRightView(withImage: UIImage(named: "refresh"))
        case .checkmark:
            setRightView(withImage: UIImage(named: "checkmark"))
        case .none:
            setRightView(withImage: nil)
        }
    }

    private func setRightView(withImage image: UIImage?) {
        guard let accessoryImage = image else {
            self.textField.rightView = nil
            return
        }

        let imageView = UIImageView(image: accessoryImage)
        // For some reason adding the subview first sets the view correctly on the right of the text field
        // Or else it puts it on the left side
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        if accessoryState == .loading {
            imageView.startRotating(duration: 1)
        }
        
        self.textField.rightView = imageView
    }
    
    @objc private func rightViewTapped() {
        guard let accessoryState = self.accessoryState else { return }
        delegate?.didTapTextFieldRightButton(ofKind: accessoryState)
    }

    /**
     Sets or gets the error string which is displayed below the textField when it is not nil.

     To animate this, simply wrap the setter call in an animation block:

     ````
     UIView.animate(withDuration: 0.5) {
     flatFormTextField.error = "Error message."
     }
     ````
     */
    var error: String? {
        get {
            return errorLabel.text
        }
        set {
            if let errorText = newValue {
                errorLabel.text = errorText
                // This can be animated externally by wrapping the setter call `error`
                UIView.animate(withDuration: 0) {
                    self.errorLabelWrapperView.isHidden = false
                }
            }
            else {
                // This can be animated externally by changing the duration when setting `error`
                UIView.animate(withDuration: 0, animations: {
                    self.errorLabelWrapperView.isHidden = true
                }) { _ in
                    self.errorLabel.text = nil
                }
            }
        }
    }

    /// The accessory state determines which image to show in the rightView of the textField
    var accessoryState: AccessoryState? {
        didSet {
//            oldAccessoryState = accessoryState
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

    var separatorColor: UIColor? {
        get {
            return lineView.backgroundColor
        }
        set {
            lineView.backgroundColor = newValue
        }
    }

    var isEditing: Bool = false {
        didSet {
            updateAccessoryStateView()
        }
    }
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

private let rotateKey = "OSERotate"

extension UIView {
    func startRotating(duration: TimeInterval = 3) {
        guard layer.animation(forKey: rotateKey) == nil else {
            return
        }
        let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnim.toValue = NSNumber(value: 2 * Double.pi)
        rotateAnim.duration = duration
        rotateAnim.repeatDuration = Double.infinity
        rotateAnim.isRemovedOnCompletion = false
        rotateAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(rotateAnim, forKey: rotateKey)
    }

    func stopRotating() {
        layer.removeAnimation(forKey: rotateKey)
    }
}

