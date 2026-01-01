//
//  ViewController.swift
//  CryptoApp macOS
//
//  Example macOS UI that uses the Lockstitch library

import Cocoa

class ViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var inputTextView: NSTextView!
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var encryptButton: NSButton!
    @IBOutlet weak var decryptButton: NSButton!
    @IBOutlet weak var selectFileButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    // MARK: - Properties
    let lockstitchWrapper = LockstitchWrapper.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        encryptButton.target = self
        encryptButton.action = #selector(encryptButtonClicked(_:))
        
        decryptButton.target = self
        decryptButton.action = #selector(decryptButtonClicked(_:))
        
        selectFileButton.target = self
        selectFileButton.action = #selector(selectFileButtonClicked(_:))
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
            updateStatus("Text encrypted successfully", isError: false)
        } else {
            let error = lockstitchWrapper.lastError() ?? "Unknown error"
            updateStatus("Encryption failed: \(error)", isError: true)
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
            updateStatus("Text decrypted successfully", isError: false)
        } else {
            let error = lockstitchWrapper.lastError() ?? "Unknown error"
            updateStatus("Decryption failed: \(error)", isError: true)
        }
    }
    
    @objc func selectFileButtonClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Select a file to encrypt/decrypt"
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                self.handleFileSelection(url)
            }
        }
    }
    
    private func handleFileSelection(_ url: URL) {
        let filePath = url.path
        let password = passwordField.stringValue
        
        // Show action dialog
        let alert = NSAlert()
        alert.messageText = "File Operations"
        alert.informativeText = "Select an operation for: \(url.lastPathComponent)"
        alert.addButton(withTitle: "Encrypt")
        alert.addButton(withTitle: "Decrypt")
        alert.addButton(withTitle: "Cancel")
        
        alert.beginSheetModal(for: self.view.window!) { response in
            switch response {
            case .alertFirstButtonReturn:
                self.encryptFileAtPath(filePath, password: password)
            case .alertSecondButtonReturn:
                self.decryptFileAtPath(filePath, password: password)
            default:
                break
            }
        }
    }
    
    private func encryptFileAtPath(_ filePath: String, password: String) {
        if let result = lockstitchWrapper.encryptFile(filePath, password: password, headSize: 0) {
            outputTextView.string = result
            updateStatus("File encrypted successfully to: \(result)", isError: false)
        } else {
            let error = lockstitchWrapper.lastError() ?? "Unknown error"
            updateStatus("File encryption failed: \(error)", isError: true)
        }
    }
    
    private func decryptFileAtPath(_ filePath: String, password: String) {
        if let result = lockstitchWrapper.decryptFile(filePath, password: password) {
            outputTextView.string = result
            updateStatus("File decrypted successfully", isError: false)
        } else {
            let error = lockstitchWrapper.lastError() ?? "Unknown error"
            updateStatus("File decryption failed: \(error)", isError: true)
        }
    }
    
    // MARK: - Utilities
    
    private func updateStatus(_ message: String, isError: Bool) {
        statusLabel.stringValue = message
        statusLabel.textColor = isError ? .systemRed : .systemGreen
    }
}
