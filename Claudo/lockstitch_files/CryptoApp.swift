import SwiftUI
import Foundation

class CryptoEngine: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var status: String = "Ready"
    @Published var statusColor: Color = .green
    @Published var isProcessing: Bool = false
    
    func encrypt() {
        guard !inputText.isEmpty else {
            updateStatus("No text to encrypt", color: .red)
            return
        }
        
        isProcessing = true
        DispatchQueue.global().async {
            let encrypted = LockstitchBridge.encryptString(self.inputText)
            
            DispatchQueue.main.async {
                self.outputText = encrypted
                self.updateStatus("✅ Encrypted with Lockstitch", color: .green)
                self.isProcessing = false
            }
        }
    }
    
    func decrypt() {
        guard !inputText.isEmpty else {
            updateStatus("No text to decrypt", color: .red)
            return
        }
        
        isProcessing = true
        DispatchQueue.global().async {
            let decrypted = LockstitchBridge.decryptString(self.inputText)
            
            DispatchQueue.main.async {
                self.outputText = decrypted
                self.updateStatus("✅ Decrypted with Lockstitch", color: .green)
                self.isProcessing = false
            }
        }
    }
    
    func copyToClipboard() {
        guard !outputText.isEmpty else {
            updateStatus("Nothing to copy", color: .orange)
            return
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputText, forType: .string)
        updateStatus("📋 Copied to clipboard", color: .blue)
    }
    
    func clear() {
        inputText = ""
        outputText = ""
        updateStatus("Cleared", color: .gray)
    }
    
    private func updateStatus(_ message: String, color: Color) {
        DispatchQueue.main.async {
            self.status = message
            self.statusColor = color
        }
    }
}

struct ContentView: View {
    @StateObject private var crypto = CryptoEngine()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("🔒")
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CryptoApp")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Lockstitch Encryption")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
            }
            
            Divider()
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Input Text")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $crypto.inputText)
                        .font(.body)
                        .frame(minHeight: 100)
                        .padding(8)
                        .border(Color.gray.opacity(0.3))
                        .background(Color.white)
                }
                
                HStack(spacing: 12) {
                    Button(action: crypto.encrypt) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Encrypt")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    
                    Button(action: crypto.decrypt) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Decrypt")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Output Text")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $crypto.outputText)
                        .font(.body)
                        .frame(minHeight: 100)
                        .padding(8)
                        .border(Color.gray.opacity(0.3))
                        .background(Color(.lightGray).opacity(0.1))
                        .disabled(true)
                }
                
                HStack(spacing: 12) {
                    Button(action: crypto.copyToClipboard) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    
                    Button(action: crypto.clear) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }
                
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(crypto.statusColor)
                    Text(crypto.status)
                        .foregroundColor(crypto.statusColor)
                    Spacer()
                    
                    if crypto.isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .font(.caption)
                .padding(10)
                .background(Color(.lightGray).opacity(0.2))
                .cornerRadius(4)
                
                Spacer()
            }
            .padding(20)
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

@main
struct CryptoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
