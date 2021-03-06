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
    
    enum Constant {
        static let rightViewSize: CGFloat = 16
        static let editImageSize = CGSize(width: 20, height: 20)
    }
    
    enum DisplayState {
        case inactive
        case editable
    }
    
    enum AccessoryState {
        case loading
        case refresh
        case checkmark
    }

    private let stackView = UIStackView()
    private let textField = NonScalingRightViewFlatFormTextField()
    private let lineView = UIView(frame: .zero)
    private let errorLabelWrapperView = UIView(frame: .zero)
    private let errorLabel = UILabel()
    private let waitingView = UIView(frame: .zero)
    private let waitingLabel = UILabel()

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
        setupWaitingView()
        // Once we fully support dark and light mode, this can be removed.
        // Right now this forces our textfield to display in dark mode
        // so you can see the clear button on a dark background
        overrideUserInterfaceStyle = .dark
        updateDisplayState()
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
        textField.returnKeyType = .done
        font = UIFont(name: "Maax", size: 16)!
        textField.rightViewMode = .unlessEditing
        textField.clearButtonMode = .whileEditing
        textColor = UIColor(named: "neutral-40")
        textField.tintColor = UIColor(named: "neutral-40")
        placeholderColor = UIColor(named: "neutral-100")
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
    
    private func setupWaitingView() {
        addSubview(waitingView)
        waitingView.translatesAutoresizingMaskIntoConstraints = false
        waitingView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        waitingView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        waitingView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        waitingView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        waitingView.addSubview(waitingLabel)
        waitingLabel.translatesAutoresizingMaskIntoConstraints = false
        waitingLabel.topAnchor.constraint(equalTo: waitingView.topAnchor).isActive = true
        waitingLabel.bottomAnchor.constraint(equalTo: waitingView.bottomAnchor).isActive = true
        waitingLabel.leadingAnchor.constraint(equalTo: waitingView.leadingAnchor).isActive = true
        waitingLabel.trailingAnchor.constraint(equalTo: waitingView.trailingAnchor).isActive = true
        waitingLabel.numberOfLines = 0
        waitingLabel.lineBreakMode = .byWordWrapping
        waitingLabel.textColor = textColor
        waitingLabel.textAlignment = .center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(waitingViewTapped))
        waitingView.addGestureRecognizer(tapGesture)
        
    }
    
    private func updateDisplayState() {
        UIView.transition(with: self, duration: 0.5, options: [.transitionFlipFromTop], animations: {
            switch self.displayState {
            case .inactive:
                self.error = nil
                self.stackView.isHidden = true
                self.waitingView.isHidden = false
                self.waitingLabel.attributedText = self.waitingLabelAttributedString(fromText: self.text ?? "")
                self.textField.resignFirstResponder()
            case .editable:
                self.stackView.isHidden = false
                self.waitingView.isHidden = true
                self.waitingLabel.text = nil
                self.textField.becomeFirstResponder()
            }
        }, completion: nil)
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
    
    private func waitingLabelAttributedString(fromText text: String) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: text)
        let spacer = NSAttributedString(string: "  ")

        let editImageAttachment = NSTextAttachment()
        editImageAttachment.bounds.size = Constant.editImageSize
        editImageAttachment.image = UIImage(named: "edit-image")

        let image1String = NSAttributedString(attachment: editImageAttachment)

        fullString.append(spacer)
        fullString.append(image1String)

        return fullString
    }

    private func setRightView(withImage image: UIImage?) {
        guard let accessoryImage = image else {
            self.textField.rightView = nil
            return
        }

        let imageView = UIImageView(image: accessoryImage)
        imageView.isUserInteractionEnabled = true
     
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        if accessoryState == .loading {
            imageView.startRotating(duration: 1)
        }

        self.textField.rightView = imageView
    }
    
    private func updatePlaceholderColor(withColor color: UIColor) {
        guard let placeholder = self.placeholder else { return }
        self.textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    @objc private func rightViewTapped() {
        guard let accessoryState = self.accessoryState else { return }
        delegate?.didTapTextFieldRightButton(ofKind: accessoryState)
    }
    
    @objc private func waitingViewTapped() {
        displayState = .editable
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
    
    var displayState: DisplayState = .inactive {
        didSet {
            updateDisplayState()
        }
    }

    /// The accessory state determines which image to show in the rightView of the textField
    var accessoryState: AccessoryState? {
        didSet {
            updateAccessoryStateView()
        }
    }

    var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
            guard let placeholderColor = self.placeholderColor else { return }
            updatePlaceholderColor(withColor: placeholderColor)
        }
    }
    
    var placeholderColor: UIColor? {
        didSet {
            guard let newColor = placeholderColor else { return }
            updatePlaceholderColor(withColor: newColor)
        }
    }

    var text: String? {
        get {
            return textField.text
        }

        set {
            textField.text = newValue
            waitingLabel.attributedText = waitingLabelAttributedString(fromText: text ?? "")
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

/// A textField that doesn't automatically scale it's rightView, but rather respects the originally set frame
class NonScalingRightViewFlatFormTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Override this method to prevent it from scaling our view
    // If we ever implemeneted a right-to-left user interface for another langugage
    // this would have to change.
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        // The size of our rightView for our accessoryState images
        let rightViewSideLength: CGFloat = 16
        // Padding puts our rightView in line with the built in clear button
        let padding: CGFloat = 8
        return CGRect(x: bounds.width - rightViewSideLength - padding,
                      y: (bounds.height - rightViewSideLength) / 2,
                      width: rightViewSideLength,
                      height: rightViewSideLength)
    }
}
