import Cocoa

// Simple encryption wrapper (no C++ dependency for demo)
class SimpleEncryption {
    static func encrypt(_ text: String) -> String {
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
        let key = "CRYPTOKEY"
        var result = ""
        let keyChars = Array(key)
        
        var i = 0
        while i < text.count {
            let start = text.index(text.startIndex, offsetBy: i)
            let end = text.index(text.startIndex, offsetBy: min(i+2, text.count))
            let hexPair = String(text[start..<end])
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

// App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var inputTextView: NSTextView?
    var outputTextView: NSTextView?
    var statusLabel: NSTextField?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window?.title = "🔐 CryptoApp - Text Encryption Demo"
        window?.center()
        window?.setFrameAutosaveName("CryptoApp")
        
        let vc = NSViewController()
        vc.view = NSView()
        
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 12
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
        title.stringValue = "Simple Text Encryption Demo"
        title.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        stack.addArrangedSubview(title)
        
        // Input label
        let inputLabel = NSTextField()
        inputLabel.stringValue = "Input Text:"
        inputLabel.isEditable = false
        inputLabel.isBordered = false
        inputLabel.backgroundColor = .clear
        stack.addArrangedSubview(inputLabel)
        
        // Input text view
        inputTextView = NSTextView()
        inputTextView?.font = NSFont.systemFont(ofSize: 12)
        let inputScroll = NSScrollView()
        inputScroll.documentView = inputTextView
        inputScroll.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stack.addArrangedSubview(inputScroll)
        
        // Output label
        let outputLabel = NSTextField()
        outputLabel.stringValue = "Output Text:"
        outputLabel.isEditable = false
        outputLabel.isBordered = false
        outputLabel.backgroundColor = .clear
        stack.addArrangedSubview(outputLabel)
        
        // Output text view
        outputTextView = NSTextView()
        outputTextView?.font = NSFont.systemFont(ofSize: 12)
        outputTextView?.isEditable = false
        let outputScroll = NSScrollView()
        outputScroll.documentView = outputTextView
        outputScroll.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stack.addArrangedSubview(outputScroll)
        
        // Buttons
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 8
        
        let encryptBtn = NSButton(title: "Encrypt", target: self, action: #selector(encrypt))
        encryptBtn.bezelStyle = .rounded
        
        let decryptBtn = NSButton(title: "Decrypt", target: self, action: #selector(decrypt))
        decryptBtn.bezelStyle = .rounded
        
        let clearBtn = NSButton(title: "Clear", target: self, action: #selector(clear))
        clearBtn.bezelStyle = .rounded
        
        buttonStack.addArrangedSubview(encryptBtn)
        buttonStack.addArrangedSubview(decryptBtn)
        buttonStack.addArrangedSubview(clearBtn)
        stack.addArrangedSubview(buttonStack)
        
        // Status label
        statusLabel = NSTextField()
        statusLabel?.stringValue = "Ready"
        statusLabel?.isEditable = false
        statusLabel?.isBordered = false
        statusLabel?.backgroundColor = .clear
        statusLabel?.textColor = .systemGreen
        if let status = statusLabel {
            stack.addArrangedSubview(status)
        }
        
        window?.contentViewController = vc
        window?.makeKeyAndOrderFront(nil)
    }
    
    @objc func encrypt() {
        guard let input = inputTextView?.string, !input.isEmpty else {
            statusLabel?.stringValue = "❌ No text to encrypt"
            statusLabel?.textColor = .systemRed
            return
        }
        
        let encrypted = SimpleEncryption.encrypt(input)
        outputTextView?.string = encrypted
        statusLabel?.stringValue = "✅ Encrypted"
        statusLabel?.textColor = .systemGreen
    }
    
    @objc func decrypt() {
        guard let input = inputTextView?.string, !input.isEmpty else {
            statusLabel?.stringValue = "❌ No text to decrypt"
            statusLabel?.textColor = .systemRed
            return
        }
        
        let decrypted = SimpleEncryption.decrypt(input)
        outputTextView?.string = decrypted
        statusLabel?.stringValue = "✅ Decrypted"
        statusLabel?.textColor = .systemGreen
    }
    
    @objc func clear() {
        inputTextView?.string = ""
        outputTextView?.string = ""
        statusLabel?.stringValue = "Cleared"
        statusLabel?.textColor = .systemGreen
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
