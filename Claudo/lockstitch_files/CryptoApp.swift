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
            let encrypted = LockstitchBridge.encryptString(self.inputText) ?? ""
            DispatchQueue.main.async {
                self.outputText = encrypted
                self.updateStatus("✅ Encrypted", color: .green)
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
            let decrypted = LockstitchBridge.decryptString(self.inputText) ?? ""
            DispatchQueue.main.async {
                self.outputText = decrypted
                self.updateStatus("✅ Decrypted", color: .green)
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
        updateStatus("📋 Copied", color: .blue)
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
                    Text("CryptoApp")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Text("Lockstitch Encryption")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.9), Color(red: 0.2, green: 0.5, blue: 1.0)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Input")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(crypto.inputText.count) chars")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                TextEditor(text: $crypto.inputText)
                    .font(.system(size: 13))
                    .frame(height: 120)
                    .padding(12)
                    .background(Color(.white))
                    .border(Color(.lightGray), width: 1)
                    .cornerRadius(6)
                
                HStack(spacing: 10) {
                    Button(action: { crypto.encrypt() }) {
                        Text("Encrypt")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { crypto.decrypt() }) {
                        Text("Decrypt")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack {
                    Text("Output")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(crypto.outputText.count) chars")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                TextEditor(text: .constant(crypto.outputText))
                    .font(.system(size: 13))
                    .frame(height: 120)
                    .padding(12)
                    .background(Color(.white))
                    .border(Color(.lightGray), width: 1)
                    .cornerRadius(6)
                    .disabled(true)
                
                HStack(spacing: 10) {
                    Button(action: { crypto.copyToClipboard() }) {
                        Text("Copy")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { crypto.clear() }) {
                        Text("Clear")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text(crypto.status)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(crypto.statusColor)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.lightGray).opacity(0.2))
                        .cornerRadius(4)
                }
                
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
