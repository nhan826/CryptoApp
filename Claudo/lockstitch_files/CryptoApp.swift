import SwiftUI
import Foundation

class CryptoEngine: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var status: String = "Ready"
    @Published var statusColor: Color = .green
    
    func encrypt() {
        guard !inputText.isEmpty else {
            status = "No text"
            statusColor = .red
            return
        }
        let result = LockstitchBridge.encryptString(inputText) ?? ""
        outputText = result
        status = "Encrypted"
        statusColor = .green
    }
    
    func decrypt() {
        guard !inputText.isEmpty else {
            status = "No text"
            statusColor = .red
            return
        }
        let result = LockstitchBridge.decryptString(inputText) ?? ""
        outputText = result
        status = "Decrypted"
        statusColor = .green
    }
    
    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputText, forType: .string)
        status = "Copied"
        statusColor = .blue
    }
    
    func clear() {
        inputText = ""
        outputText = ""
        status = "Ready"
        statusColor = .green
    }
}

struct ContentView: View {
    @StateObject private var engine = CryptoEngine()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("🔒 CryptoApp").font(.title)
                Spacer()
            }
            .padding(20)
            .background(Color.blue.opacity(0.7))
            .foregroundColor(.white)
            
            VStack(spacing: 16) {
                Text("Input").font(.headline)
                TextEditor(text: $engine.inputText).frame(height: 100).border(Color.gray)
                
                HStack(spacing: 8) {
                    Button("Encrypt") { engine.encrypt() }.padding(8).background(Color.green).foregroundColor(.white)
                    Button("Decrypt") { engine.decrypt() }.padding(8).background(Color.orange).foregroundColor(.white)
                }
                
                Text("Output").font(.headline)
                TextEditor(text: .constant(engine.outputText)).frame(height: 100).border(Color.gray).disabled(true)
                
                HStack(spacing: 8) {
                    Button("Copy") { engine.copyToClipboard() }.padding(8).background(Color.blue).foregroundColor(.white)
                    Button("Clear") { engine.clear() }.padding(8).background(Color.red).foregroundColor(.white)
                }
                
                Text(engine.status).foregroundColor(engine.statusColor).frame(maxWidth: .infinity, alignment: .leading)
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
