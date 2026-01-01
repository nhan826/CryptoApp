import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔒 CryptoApp").font(.title).padding()
            
            VStack(alignment: .leading) {
                Text("Input").font(.headline)
                TextEditor(text: $inputText).frame(height: 100).border(Color.gray)
            }
            
            HStack(spacing: 10) {
                Button("Encrypt") {
                    outputText = "Encrypted: \(inputText)"
                }.padding().background(Color.green).foregroundColor(.white)
                
                Button("Decrypt") {
                    outputText = "Decrypted: \(inputText)"
                }.padding().background(Color.orange).foregroundColor(.white)
            }
            
            VStack(alignment: .leading) {
                Text("Output").font(.headline)
                TextEditor(text: .constant(outputText)).frame(height: 100).border(Color.gray).disabled(true)
            }
            
            HStack(spacing: 10) {
                Button("Copy") {
                    NSPasteboard.general.setString(outputText, forType: .string)
                }.padding().background(Color.blue).foregroundColor(.white)
                
                Button("Clear") {
                    inputText = ""
                    outputText = ""
                }.padding().background(Color.red).foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 600)
    }
}

struct CryptoApp_Unused {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
