import SwiftUI

struct ForgotPasswordScreen: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var emailError: Bool = false

    var body: some View {
        ZStack {
            
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 15) {
                
                Image("BusBuzz_Logo_Without_Slogan")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 300)

                
                Text("Forgot your password?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                
                Text("Enter your registered email, and we will send you a password reset email.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                
                TextField("Enter email address", text: $email, onEditingChanged: { _ in
                    emailError = false
                })
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(emailError ? Color.red : Color.clear, lineWidth: 2)
                    )
                    .padding(.horizontal, 20)

                
                Button(action: {
                    handleForgotPassword(email: email)
                }) {
                    Text("Send Verification Email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.buttonGreen)
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                }

            
                HStack(spacing: 5) {
                    Text("Remember your password?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    NavigationLink(destination: LaunchScreen().navigationBarBackButtonHidden(true)) {
                        Text("Sign in")
                            .font(.subheadline)
                            .foregroundColor(AppColors.buttonGreen)
                            .bold()
                    }
                }

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func handleForgotPassword(email: String) {
        emailError = email.isEmpty

        guard !email.isEmpty else {
            alertTitle = "Warning: Error"
            alertMessage = "Please enter your email address."
            showAlert = true
            return
        }

        guard isValidEmail(email) else {
            alertTitle = "Warning: Error"
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }

        let apiKey = "AIzaSyBBhpcPZ0Yd01NaBuqj6iVe4pbSeIjKRYU"
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "requestType": "PASSWORD_RESET",
            "email": email
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertTitle = "Warning: Error"
                    alertMessage = "Network error, please try again."
                    showAlert = true
                }
                return
            }

            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if jsonResponse?["email"] != nil {
                        DispatchQueue.main.async {
                            alertTitle = "✉️ Password Reset Email Sent"
                            alertMessage = """
                            A password reset link has been sent to your registered email address.
                            Please check your inbox (and spam/junk folder if necessary) and reset your password.
                            """
                            showAlert = true
                        }
                    } else if let errorResponse = jsonResponse?["error"] as? [String: Any],
                              let message = errorResponse["message"] as? String {
                        DispatchQueue.main.async {
                            alertTitle = "Warning: Error"
                            alertMessage = message
                            showAlert = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        alertTitle = "Warning: Error"
                        alertMessage = "Failed to parse response."
                        showAlert = true
                    }
                }
            }
        }.resume()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

struct ForgotPasswordScreen_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordScreen()
    }
}
