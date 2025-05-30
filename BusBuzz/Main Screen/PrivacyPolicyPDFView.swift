import SwiftUI
import PDFKit

struct PrivacyPolicyPDFView: View {
    var body: some View {
        PDFKitContainer()
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFKitContainer: View {
    let url: URL? = Bundle.main.url(forResource: "BussBuzz User Application Privacy Policy", withExtension: "pdf")
    
    var body: some View {
        if let pdfURL = url {
            PDFKitView(url: pdfURL)
                .edgesIgnoringSafeArea(.bottom) 
        } else {
            Text("PDF not found")
                .foregroundColor(.red)
                .bold()
        }
    }
}

struct PrivacyPolicyPDFView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyPDFView()
        }
    }
}
