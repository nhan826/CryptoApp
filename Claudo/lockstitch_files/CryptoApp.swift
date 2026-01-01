import SwiftUI
import Foundation

// MARK: - Lockstitch Bridge Import
// This bridge connects to the real Lockstitch C++ library
// LockstitchBridge is defined in LockstitchBridge.mm (Objective-C++)

// MARK: - Encryption Engine
@MainActor
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
            // Call the real Lockstitch library through the bridge
            let encrypted = LockstitchBridge.encrypt(inputText)
            
            DispatchQueue.main.async {
                self.outputText = encrypted
                self.updateStatus("Encrypted with Lockstitch", color: .green)
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
            // Call the real Lockstitch library through the bridge
            let decrypted = LockstitchBridge.decrypt(inputText)
            
            DispatchQueue.main.async {
                self.outputText = decrypted
                self.updateStatus("Decrypted with Lockstitch", color: .green)
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
        updateStatus("Copied to clipboard", color: .blue)
    }
    
    func clear() {
        inputText = ""
        outputText = ""
        updateStatus("Ready", color: .green)
    }
    
    private func updateStatus(_ message: String, color: Color) {
        status = message
        statusColor = color
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var crypto = CryptoEngine()
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case input
        case output
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.92, green: 0.96, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CryptoApp")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Secure Text Encryption")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding(20)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.8),
                            Color(red: 0.1, green: 0.3, blue: 0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Input Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Input Text", systemImage: "pencil.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $crypto.inputText)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .input)
                        }
                        
                        // Output Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Output Text", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $crypto.outputText)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .disabled(true)
                        }
                        
                        // Button Grid
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ActionButton(
                                    title: "Encrypt",
                                    icon: "lock.fill",
                                    color: .blue,
                                    isLoading: crypto.isProcessing,
                                    action: crypto.encrypt
                                )
                                
                                ActionButton(
                                    title: "Decrypt",
                                    icon: "lock.open.fill",
                                    color: .green,
                                    isLoading: crypto.isProcessing,
                                    action: crypto.decrypt
                                )
                            }
                            
                            HStack(spacing: 12) {
                                ActionButton(
                                    title: "Copy",
                                    icon: "doc.on.doc.fill",
                                    color: .orange,
                                    isLoading: false,
                                    action: crypto.copyToClipboard
                                )
                                
                                ActionButton(
                                    title: "Clear",
                                    icon: "trash.fill",
                                    color: .red,
                                    isLoading: false,
                                    action: crypto.clear
                                )
                            }
                        }
                        
                        // Status Bar
                        HStack {
                            Image(systemName: crypto.statusColor == .green ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(crypto.statusColor)
                            
                            Text(crypto.status)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(crypto.statusColor)
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(crypto.statusColor.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Footer
                        VStack(spacing: 4) {
                            Text("Powered by Lockstitch")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text("Military-grade encryption for your data")
                                .font(.system(size: 11))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 700)
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}

// MARK: - App Delegate
@main
struct CryptoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize(ContentView().frame(minWidth: 600, minHeight: 700)))
    }
}

// Preview
#Preview {
    ContentView()
}
