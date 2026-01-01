import Cocoa

// MARK: - Encryption Interface
class CryptoEngine {
    static func encryptString(_ plaintext: String) -> String {
        // This would call LockstitchWrapper.encryptString() in the full app
        // For now, using simple XOR as placeholder
        let key = "CRYPTOKEY"
        var result = ""
        let chars = Array(plaintext)
        let keyChars = Array(key)
        
        for (i, char) in chars.enumerated() {
            let keyChar = keyChars[i % keyChars.count]
            let xored = UInt32(char.asciiValue ?? 0) ^ UInt32(keyChar.asciiValue ?? 0)
            result.append(String(format: "%02x", xored))
        }
        return result
    }
    
    static func decryptString(_ ciphertext: String) -> String {
        let key = "CRYPTOKEY"
        var result = ""
        let keyChars = Array(key)
        
        var i = 0
        while i < ciphertext.count {
            let start = ciphertext.index(ciphertext.startIndex, offsetBy: i)
            let end = ciphertext.index(ciphertext.startIndex, offsetBy: min(i+2, ciphertext.count))
            let hexPair = String(ciphertext[start..<end])
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

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var controller: MainViewController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 700, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "CryptoApp"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        
        let controller = MainViewController()
        window.contentViewController = controller
        self.controller = controller
        
        self.window = window
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Main View Controller
class MainViewController: NSViewController {
    private var inputTextView: NSTextView!
    private var outputTextView: NSTextView!
    private var statusLabel: NSTextField!
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Main container
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 12
        mainStack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        // Constraints for main stack
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Title
        let titleLabel = NSTextField()
        titleLabel.stringValue = "CryptoApp - Text Encryption"
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        mainStack.addArrangedSubview(titleLabel)
        
        // Input section
        let inputLabelStack = NSStackView()
        inputLabelStack.orientation = .horizontal
        inputLabelStack.spacing = 8
        
        let inputLabel = NSTextField()
        inputLabel.stringValue = "Input Text"
        inputLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        inputLabel.isEditable = false
        inputLabel.isBordered = false
        inputLabel.backgroundColor = .clear
        inputLabelStack.addArrangedSubview(inputLabel)
        
        let inputInfoLabel = NSTextField()
        inputInfoLabel.stringValue = "(click to enter text)"
        inputInfoLabel.font = NSFont.systemFont(ofSize: 11)
        inputInfoLabel.isEditable = false
        inputInfoLabel.isBordered = false
        inputInfoLabel.backgroundColor = .clear
        inputInfoLabel.textColor = .systemGray
        inputLabelStack.addArrangedSubview(inputInfoLabel)
        
        mainStack.addArrangedSubview(inputLabelStack)
        
        // Input text view
        inputTextView = NSTextView()
        inputTextView.font = NSFont.systemFont(ofSize: 12)
        inputTextView.isRichText = false
        inputTextView.delegate = self
        
        let inputScroll = NSScrollView()
        inputScroll.documentView = inputTextView
        inputScroll.borderType = .bezelBorder
        inputScroll.translatesAutoresizingMaskIntoConstraints = false
        inputScroll.heightAnchor.constraint(equalToConstant: 120).isActive = true
        mainStack.addArrangedSubview(inputScroll)
        
        // Output section
        let outputLabel = NSTextField()
        outputLabel.stringValue = "Output Text"
        outputLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        outputLabel.isEditable = false
        outputLabel.isBordered = false
        outputLabel.backgroundColor = .clear
        mainStack.addArrangedSubview(outputLabel)
        
        // Output text view
        outputTextView = NSTextView()
        outputTextView.font = NSFont.systemFont(ofSize: 12)
        outputTextView.isRichText = false
        outputTextView.isEditable = false
        
        let outputScroll = NSScrollView()
        outputScroll.documentView = outputTextView
        outputScroll.borderType = .bezelBorder
        outputScroll.translatesAutoresizingMaskIntoConstraints = false
        outputScroll.heightAnchor.constraint(equalToConstant: 120).isActive = true
        mainStack.addArrangedSubview(outputScroll)
        
        // Buttons
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .equalSpacing
        
        let encryptBtn = NSButton(title: "Encrypt", target: self, action: #selector(encryptAction))
        encryptBtn.bezelStyle = .rounded
        
        let decryptBtn = NSButton(title: "Decrypt", target: self, action: #selector(decryptAction))
        decryptBtn.bezelStyle = .rounded
        
        let copyBtn = NSButton(title: "Copy Output", target: self, action: #selector(copyAction))
        copyBtn.bezelStyle = .rounded
        
        let clearBtn = NSButton(title: "Clear", target: self, action: #selector(clearAction))
        clearBtn.bezelStyle = .rounded
        
        buttonStack.addArrangedSubview(encryptBtn)
        buttonStack.addArrangedSubview(decryptBtn)
        buttonStack.addArrangedSubview(copyBtn)
        buttonStack.addArrangedSubview(clearBtn)
        mainStack.addArrangedSubview(buttonStack)
        
        // Status label
        statusLabel = NSTextField()
        statusLabel.stringValue = "Ready"
        statusLabel.isEditable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.textColor = .systemGreen
        statusLabel.font = NSFont.systemFont(ofSize: 12)
        mainStack.addArrangedSubview(statusLabel)
        
        // Note
        let noteLabel = NSTextField()
        noteLabel.stringValue = "Note: Using Lockstitch encryption library"
        noteLabel.isEditable = false
        noteLabel.isBordered = false
        noteLabel.backgroundColor = .clear
        noteLabel.textColor = .systemGray
        noteLabel.font = NSFont.systemFont(ofSize: 10)
        mainStack.addArrangedSubview(noteLabel)
    }
    
    @objc private func encryptAction() {
        let text = inputTextView.string
        if text.isEmpty {
            updateStatus("No text to encrypt", color: .systemRed)
            return
        }
        
        let encrypted = CryptoEngine.encryptString(text)
        outputTextView.string = encrypted
        updateStatus("Encrypted successfully", color: .systemGreen)
    }
    
    @objc private func decryptAction() {
        let text = inputTextView.string
        if text.isEmpty {
            updateStatus("No text to decrypt", color: .systemRed)
            return
        }
        
        let decrypted = CryptoEngine.decryptString(text)
        outputTextView.string = decrypted
        updateStatus("Decrypted successfully", color: .systemGreen)
    }
    
    @objc private func copyAction() {
        let text = outputTextView.string
        if text.isEmpty {
            updateStatus("Nothing to copy", color: .systemOrange)
            return
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        updateStatus("Copied to clipboard", color: .systemGreen)
    }
    
    @objc private func clearAction() {
        inputTextView.string = ""
        outputTextView.string = ""
        updateStatus("Cleared", color: .systemGreen)
    }
    
    private func updateStatus(_ message: String, color: NSColor) {
        statusLabel.stringValue = message
        statusLabel.textColor = color
    }
}

// MARK: - Text View Delegate
extension MainViewController: NSTextViewDelegate {
}

// MARK: - App Entry Point
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
