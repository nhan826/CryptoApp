//
//  main.swift
//  CryptoApp - Standalone launcher
//
//  Simple app that you can build and run directly

import Cocoa

// Simple encryption wrapper (no C++ dependency for demo)
class SimpleEncryption {
    static func encrypt(_ text: String) -> String {
        // Simple XOR for demo (not for production!)
        let key = "CRYPTOKEY"
        var result = ""
        let chars = Array(text)
        let keyChars = Array(key)
        
        for (i, char) in chars.enumerated() {
            let keyChar = keyChars[i % keyChars.count]
            let xored = UInt32(char.asciiValue ?? 0) ^ UInt32(keyChar.asciiValue ?? 0)
            result.append(String(format: "%02x", xored))
        }
        return result
    }
    
    static func decrypt(_ text: String) -> String {
        // Reverse the XOR
        let key = "CRYPTOKEY"
        var result = ""
        let keyChars = Array(key)
        
        var i = 0
        while i < text.count {
            let hexPair = String(text[text.index(text.startIndex, offsetBy: i)..<text.index(text.startIndex, offsetBy: i+2)])
            if let byte = UInt32(hexPair, radix: 16) {
                let keyChar = keyChars[(i/2) % keyChars.count]
                let decrypted = UInt8(byte ^ UInt32(keyChar.asciiValue ?? 0))
                result.append(Character(UnicodeScalar(decrypted)))
            }
            i += 2
        }
        return result
    }
}

// Main App Delegate
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 900, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "CryptoApp - Text Encryption Demo"
        window.center()
        window.setFrameAutosaveName("CryptoApp")
        
        // Create main view controller
        let viewController = createMainViewController()
        window.contentViewController = viewController
        
        self.window = window
        window.makeKeyAndOrderFront(nil)
    }
    
    func createMainViewController() -> NSViewController {
        let vc = NSViewController()
        vc.view = NSView()
        vc.view.wantsLayer = true
        vc.view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        // Main stack
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 16
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: vc.view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            stack.leftAnchor.constraint(equalTo: vc.view.leftAnchor),
            stack.rightAnchor.constraint(equalTo: vc.view.rightAnchor)
        ])
        
        // Title
        let title = NSTextField()
        title.stringValue = "🔐 CryptoApp - Simple Text Encryption"
        title.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        stack.addArrangedSubview(title)
        
        // Input section
        let inputLabel = NSTextField()
        inputLabel.stringValue = "Input Text:"
        inputLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        inputLabel.isEditable = false
        inputLabel.isBordered = false
        inputLabel.backgroundColor = .clear
        stack.addArrangedSubview(inputLabel)
        
        let inputText = NSTextView()
        inputText.font = NSFont.systemFont(ofSize: 12)
        let inputScroll = NSScrollView()
        inputScroll.documentView = inputText
        inputScroll.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stack.addArrangedSubview(inputScroll)
        
        // Output section
        let outputLabel = NSTextField()
        outputLabel.stringValue = "Output Text:"
        outputLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        outputLabel.isEditable = false
        outputLabel.isBordered = false
        outputLabel.backgroundColor = .clear
        stack.addArrangedSubview(outputLabel)
        
        let outputText = NSTextView()
        outputText.font = NSFont.systemFont(ofSize: 12)
        outputText.isEditable = false
        let outputScroll = NSScrollView()
        outputScroll.documentView = outputText
        outputScroll.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stack.addArrangedSubview(outputScroll)
        
        // Buttons
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .equalSpacing
        
        let encryptBtn = NSButton(title: "🔒 Encrypt", target: nil, action: nil)
        encryptBtn.bezelStyle = .rounded
        encryptBtn.target = nil
        encryptBtn.action = #selector(NSApplication.shared.delegate as! AppDelegate).self
        
        encryptBtn.target = self
        encryptBtn.action = #selector(encryptAction(sender:))
        
        let decryptBtn = NSButton(title: "🔓 Decrypt", target: nil, action: nil)
        decryptBtn.bezelStyle = .rounded
        decryptBtn.target = self
        decryptBtn.action = #selector(decryptAction(sender:))
        
        let clearBtn = NSButton(title: "Clear", target: nil, action: nil)
        clearBtn.bezelStyle = .rounded
        clearBtn.target = self
        clearBtn.action = #selector(clearAction(sender:))
        
        // Store references
        encryptBtn.tag = 1
        decryptBtn.tag = 2
        clearBtn.tag = 3
        inputText.tag = 10
        outputText.tag = 11
        
        buttonStack.addArrangedSubview(encryptBtn)
        buttonStack.addArrangedSubview(decryptBtn)
        buttonStack.addArrangedSubview(clearBtn)
        
        stack.addArrangedSubview(buttonStack)
        
        // Status label
        let statusLabel = NSTextField()
        statusLabel.stringValue = "Ready"
        statusLabel.isEditable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.textColor = .systemGreen
        statusLabel.tag = 12
        stack.addArrangedSubview(statusLabel)
        
        // Info label
        let infoLabel = NSTextField()
        infoLabel.stringValue = "Note: This is a demo using simple XOR encryption. Production app will use the full Lockstitch library."
        infoLabel.font = NSFont.systemFont(ofSize: 11)
        infoLabel.isEditable = false
        infoLabel.isBordered = false
        infoLabel.backgroundColor = .clear
        infoLabel.textColor = .systemGray
        stack.addArrangedSubview(infoLabel)
        
        return vc
    }
    
    @objc func encryptAction(sender: NSButton) {
        guard let view = window?.contentViewController?.view else { return }
        guard let inputTextView = view.viewWithTag(10) as? NSTextView else { return }
        guard let outputTextView = view.viewWithTag(11) as? NSTextView else { return }
        guard let statusLabel = view.viewWithTag(12) as? NSTextField else { return }
        
        let text = inputTextView.string
        if text.isEmpty {
            statusLabel.stringValue = "❌ Error: No text to encrypt"
            statusLabel.textColor = .systemRed
            return
        }
        
        let encrypted = SimpleEncryption.encrypt(text)
        outputTextView.string = encrypted
        statusLabel.stringValue = "✅ Text encrypted successfully"
        statusLabel.textColor = .systemGreen
    }
    
    @objc func decryptAction(sender: NSButton) {
        guard let view = window?.contentViewController?.view else { return }
        guard let inputTextView = view.viewWithTag(10) as? NSTextView else { return }
        guard let outputTextView = view.viewWithTag(11) as? NSTextView else { return }
        guard let statusLabel = view.viewWithTag(12) as? NSTextField else { return }
        
        let text = inputTextView.string
        if text.isEmpty {
            statusLabel.stringValue = "❌ Error: No text to decrypt"
            statusLabel.textColor = .systemRed
            return
        }
        
        let decrypted = SimpleEncryption.decrypt(text)
        outputTextView.string = decrypted
        statusLabel.stringValue = "✅ Text decrypted successfully"
        statusLabel.textColor = .systemGreen
    }
    
    @objc func clearAction(sender: NSButton) {
        guard let view = window?.contentViewController?.view else { return }
        guard let inputTextView = view.viewWithTag(10) as? NSTextView else { return }
        guard let outputTextView = view.viewWithTag(11) as? NSTextView else { return }
        guard let statusLabel = view.viewWithTag(12) as? NSTextField else { return }
        
        inputTextView.string = ""
        outputTextView.string = ""
        statusLabel.stringValue = "Cleared"
        statusLabel.textColor = .systemGreen
    }
}

NSApplication.shared.delegate = AppDelegate()
NSApplication.shared.run()
