//
//  ViewController.swift
//  CryptoApp macOS
//
//  Simple macOS encryption UI

import Cocoa

class ViewController: NSViewController {
    
    // MARK: - UI Elements
    private let scrollView = NSScrollView()
    private let inputTextView = NSTextView()
    private let outputTextView = NSTextView()
    private let encryptButton = NSButton()
    private let decryptButton = NSButton()
    private let clearButton = NSButton()
    private let statusLabel = NSTextField()
    
    // MARK: - Properties
    let lockstitchWrapper = LockstitchWrapper.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        // Main container
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 12
        mainStack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainStack.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        // Title
        let titleLabel = NSTextField()
        titleLabel.stringValue = "CryptoApp - File Encryption"
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        mainStack.addArrangedSubview(titleLabel)
        
        // Input section
        mainStack.addArrangedSubview(createLabel("Input Text:"))
        
        inputTextView.isRichText = false
        inputTextView.font = NSFont.systemFont(ofSize: 12)
        let inputScroll = NSScrollView()
        inputScroll.documentView = inputTextView
        inputScroll.heightAnchor.constraint(equalToConstant: 100).isActive = true
        mainStack.addArrangedSubview(inputScroll)
        
        // Output section
        mainStack.addArrangedSubview(createLabel("Output Text:"))
        
        outputTextView.isRichText = false
        outputTextView.font = NSFont.systemFont(ofSize: 12)
        outputTextView.isEditable = false
        let outputScroll = NSScrollView()
        outputScroll.documentView = outputTextView
        outputScroll.heightAnchor.constraint(equalToConstant: 100).isActive = true
        mainStack.addArrangedSubview(outputScroll)
        
        // Button section
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .equalSpacing
        
        setupButton(encryptButton, title: "Encrypt", action: #selector(encryptButtonClicked(_:)))
        setupButton(decryptButton, title: "Decrypt", action: #selector(decryptButtonClicked(_:)))
        setupButton(clearButton, title: "Clear", action: #selector(clearButtonClicked(_:)))
        
        buttonStack.addArrangedSubview(encryptButton)
        buttonStack.addArrangedSubview(decryptButton)
        buttonStack.addArrangedSubview(clearButton)
        
        mainStack.addArrangedSubview(buttonStack)
        
        // Status label
        statusLabel.stringValue = "Ready"
        statusLabel.isEditable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.textColor = .systemGreen
        mainStack.addArrangedSubview(statusLabel)
    }
    
    private func createLabel(_ text: String) -> NSTextField {
        let label = NSTextField()
        label.stringValue = text
        label.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        return label
    }
    
    private func setupButton(_ button: NSButton, title: String, action: Selector) {
        button.title = title
        button.bezelStyle = .rounded
        button.target = self
        button.action = action
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
    }
    
    // MARK: - Actions
    
    @objc func encryptButtonClicked(_ sender: NSButton) {
        let inputText = inputTextView.string
        
        if inputText.isEmpty {
            updateStatus("Error: No text to encrypt", isError: true)
            return
        }
        
        if let encryptedText = lockstitchWrapper.encryptString(inputText) {
            outputTextView.string = encryptedText
            updateStatus("✅ Text encrypted successfully", isError: false)
        } else {
            let error = lockstitchWrapper.lastError() ?? "Unknown error"
            updateStatus("❌ Encryption failed: \(error)", isError: true)
        }
    }
    
    @objc func decryptButtonClicked(_ sender: NSButton) {
        let inputText = inputTextView.string
        
        if inputText.isEmpty {
            updateStatus("Error: No text to decrypt", isError: true)
            return
        }
        
        if let decryptedText = lockstitchWrapper.decryptString(inputText) {
            outputTextView.string = decryptedText
            updateStatus("✅ Text decrypted successfully", isError: false)
        } else {
            let error = lockstitchWrapper.lastError() ?? "Unknown error"
            updateStatus("❌ Decryption failed: \(error)", isError: true)
        }
    }
    
    @objc func clearButtonClicked(_ sender: NSButton) {
        inputTextView.string = ""
        outputTextView.string = ""
        updateStatus("Cleared", isError: false)
    }
    
    // MARK: - Utilities
    
    private func updateStatus(_ message: String, isError: Bool) {
        statusLabel.stringValue = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen
    }
}

