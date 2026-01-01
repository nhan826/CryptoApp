import SwiftUI
import AppKit

class CryptoEngine: ObservableObject {
    @Published var inputText = ""
    @Published var outputText = ""
    @Published var selectedFilePath: String?
    @Published var isProcessing = false
    
    func encryptString(_ text: String) {
        if text.isEmpty {
            outputText = "Please enter text to encrypt"
            return
        }
        isProcessing = true
        DispatchQueue.global().async {
            let result = LockstitchBridge.encryptString(text)
            DispatchQueue.main.async {
                self.outputText = result ?? "Encryption failed"
                self.isProcessing = false
            }
        }
    }
    
    func decryptString(_ text: String) {
        if text.isEmpty {
            outputText = "Please enter text to decrypt"
            return
        }
        isProcessing = true
        DispatchQueue.global().async {
            let result = LockstitchBridge.decryptString(text)
            DispatchQueue.main.async {
                self.outputText = result ?? "Decryption failed"
                self.isProcessing = false
            }
        }
    }
    
    func encryptFile(at inputPath: String) {
        let openPanel = NSOpenSavePanel()
        openPanel.prompt = "Save Encrypted File"
        openPanel.title = "Select Output Location"
        openPanel.canCreateDirectories = true
        
        if openPanel.runModal() == .OK, let outputURL = openPanel.url {
            isProcessing = true
            DispatchQueue.global().async {
                do {
                    let fileData = try Data(contentsOf: URL(fileURLWithPath: inputPath))
                    let fileString = String(data: fileData, encoding: .utf8) ?? 
                                    fileData.map { String(format: "%02x", $0) }.joined()
                    
                    let encryptedHex = LockstitchBridge.encryptString(fileString) ?? ""
                    
                    if let encryptedData = encryptedHex.data(using: .utf8) {
                        try encryptedData.write(to: outputURL)
                        DispatchQueue.main.async {
                            self.outputText = "File encrypted successfully: \(outputURL.lastPathComponent)"
                            self.isProcessing = false
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.outputText = "File encryption failed: \(error.localizedDescription)"
                        self.isProcessing = false
                    }
                }
            }
        }
    }
    
    func decryptFile(at inputPath: String) {
        let openPanel = NSOpenSavePanel()
        openPanel.prompt = "Save Decrypted File"
        openPanel.title = "Select Output Location"
        openPanel.canCreateDirectories = true
        
        if openPanel.runModal() == .OK, let outputURL = openPanel.url {
            isProcessing = true
            DispatchQueue.global().async {
                do {
                    let fileData = try Data(contentsOf: URL(fileURLWithPath: inputPath))
                    let fileString = String(data: fileData, encoding: .utf8) ?? ""
                    
                    let decryptedStr = LockstitchBridge.decryptString(fileString) ?? ""
                    
                    if let decryptedData = decryptedStr.data(using: .utf8) {
                        try decryptedData.write(to: outputURL)
                        DispatchQueue.main.async {
                            self.outputText = "File decrypted successfully: \(outputURL.lastPathComponent)"
                            self.isProcessing = false
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.outputText = "File decryption failed: \(error.localizedDescription)"
                        self.isProcessing = false
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var engine = CryptoEngine()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 0) {
                Text("🔒 CryptoApp").font(.title2).fontWeight(.bold)
                Text("Encrypt & Decrypt Text & Files").font(.caption).foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(8)
            
            // Text Encryption Section
            VStack(alignment: .leading, spacing: 8) {
                Text("TEXT ENCRYPTION").font(.caption).fontWeight(.semibold).foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text("Input").font(.subheadline).fontWeight(.semibold)
                    TextEditor(text: $engine.inputText)
                        .frame(height: 80)
                        .border(Color.gray.opacity(0.3))
                        .cornerRadius(4)
                }
                
                HStack(spacing: 10) {
                    Button(action: { engine.encryptString(engine.inputText) }) {
                        Text("Encrypt").frame(maxWidth: .infinity)
                    }
                    .padding(10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    
                    Button(action: { engine.decryptString(engine.inputText) }) {
                        Text("Decrypt").frame(maxWidth: .infinity)
                    }
                    .padding(10)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                }
                
                VStack(alignment: .leading) {
                    Text("Output").font(.subheadline).fontWeight(.semibold)
                    TextEditor(text: .constant(engine.outputText))
                        .frame(height: 80)
                        .border(Color.gray.opacity(0.3))
                        .cornerRadius(4)
                        .disabled(true)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(6)
            
            // File Encryption Section
            VStack(alignment: .leading, spacing: 8) {
                Text("FILE ENCRYPTION").font(.caption).fontWeight(.semibold).foregroundColor(.gray)
                
                HStack(spacing: 10) {
                    Button(action: { selectAndEncryptFile() }) {
                        Text("📁 Encrypt File").frame(maxWidth: .infinity)
                    }
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    
                    Button(action: { selectAndDecryptFile() }) {
                        Text("📁 Decrypt File").frame(maxWidth: .infinity)
                    }
                    .padding(10)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                }
                
                if let filePath = engine.selectedFilePath {
                    Text("Selected: \(URL(fileURLWithPath: filePath).lastPathComponent)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(6)
            
            // Utility Buttons
            HStack(spacing: 10) {
                Button(action: {
                    NSPasteboard.general.setString(engine.outputText, forType: .string)
                }) {
                    Text("📋 Copy").frame(maxWidth: .infinity)
                }
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(4)
                
                Button(action: {
                    engine.inputText = ""
                    engine.outputText = ""
                    engine.selectedFilePath = nil
                }) {
                    Text("🗑 Clear").frame(maxWidth: .infinity)
                }
                .padding(10)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(4)
            }
            
            if engine.isProcessing {
                HStack {
                    ProgressView()
                    Text("Processing...")
                }.padding()
            }
            
            Spacer()
        }
        .padding(20)
        .frame(minWidth: 600, minHeight: 700)
    }
    
    private func selectAndEncryptFile() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select File to Encrypt"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            engine.selectedFilePath = url.path
            engine.encryptFile(at: url.path)
        }
    }
    
    private func selectAndDecryptFile() {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select File to Decrypt"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            engine.selectedFilePath = url.path
            engine.decryptFile(at: url.path)
        }
    }
}

struct CryptoApp_Unused {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
