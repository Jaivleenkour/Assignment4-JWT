import UIKit
import FirebaseAuth
import FirebaseFirestore

struct UserInfo {
    var username: String
    // Add any other fields you need
}

class FirebaseLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    static var shared: FirebaseLoginVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProtectedData()
        FirebaseLoginVC.shared = self
        usernameTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        usernameTextField.layer.borderWidth = 1
        passwordTextField.layer.borderWidth = 1
        let showPasswordButton = UIButton(type: .custom)
        showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showPasswordButton.tintColor = .systemBlue
        showPasswordButton.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        showPasswordButton.contentHorizontalAlignment = .left
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        containerView.addSubview(showPasswordButton)
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
    }

    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if let containerView = passwordTextField.rightView,
            let showPasswordButton = containerView.subviews.first as? UIButton {
            showPasswordButton.tintColor = passwordTextField.isSecureTextEntry ? .systemBlue : .systemRed
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blue.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.gray.cgColor
    }

    func ClearLoginTextFields() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        usernameTextField.becomeFirstResponder()
    }

    func fetchProtectedData() {
        let token = "test_token"
        guard let url = URL(string: "http://localhost:3000/protected") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle the response from the server
        }.resume()
    }

    @IBAction func createNowButton(_ sender: Any) {
        performSegue(withIdentifier: "RegisterSegue", sender: nil)
    }

    @IBAction func loginButton(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            print("Please enter both username and password.")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("usernames").document(username)

        docRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data(), let email = data["email"] as? String {
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print("Login failed: \(error.localizedDescription)")
                        self.displayErrorMessage(message: "Authentication Failed!")
                        return
                    }

                    print("User logged in successfully.")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                    }
                }
            } else {
                print("Username not found.")
                self.displayErrorMessage(message: "Authentication Failed!")
            }
        }
    }

    func displayErrorMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.ClearLoginTextFields()
        })

        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}
