
import UIKit
import FirebaseAuth
import FirebaseFirestore

class FirebaseRegisterVC: UIViewController {
    
    @IBOutlet var firstNameTextField: UITextField!
    
    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProtectedData()

        // Do any additional setup after loading the view.
    }
    
    func fetchProtectedData() {
        // Replace 'your_access_token_here' with the actual token
        let token = "test_token"

        guard let url = URL(string: "http://localhost:3000/protected") else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle the response from the server
        }.resume()
    }

    
    
    @IBAction func registerButton(_ sender: Any) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              password == confirmPassword else {
            print("Please enter valid email and matching passwords.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Registration failed: \(error.localizedDescription)")
                return
            }

            // Store the username and email mapping in Firestore
            let db = Firestore.firestore()
            db.collection("usernames").document(username).setData(["email": email]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }

            print("User registered successfully.")
            DispatchQueue.main.async {
                FirebaseLoginVC.shared?.ClearLoginTextFields()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        
        FirebaseLoginVC.shared?.ClearLoginTextFields()
        dismiss(animated: true, completion: nil)
    }
    

}
