import UIKit
import Alamofire
import Kingfisher

class FirebaseCRUDVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var books: [Book] = []

    var selectedBook: Book?

    override func viewDidLoad() {
        super.viewDidLoad()

        KingfisherManager.shared.defaultOptions = [.fromMemoryCacheOrRefresh]
        fetchBooksFromMongoDB()
    }

    func fetchBooksFromMongoDB() {
        let url = "http://localhost:3000/books"

        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Received JSON: \(value)")
                if let booksData = try? JSONSerialization.data(withJSONObject: value),
                   let fetchedBooks = try? JSONDecoder().decode([Book].self, from: booksData) {
                    DispatchQueue.main.async {
                        self.books = fetchedBooks
                        self.tableView.reloadData()
                    }
                } else {
                    print("Error decoding books data")
                }
            case .failure(let error):
                print("Error fetching books: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell

        let book = books[indexPath.row]

        let bookRating: Double = book.rating
        let ratingString = String(bookRating)

        cell.titleLabel?.text = book.title
        cell.authorLabel?.text = book.author
        cell.ratingLabel?.text = ratingString

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = books[indexPath.row]
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let book = books[indexPath.row]
            showDeleteConfirmationAlert(for: book) { confirmed in
                if confirmed {
                    self.deleteBook(at: indexPath)
                }
            }
        }
    }

    func showDeleteConfirmationAlert(for book: Book, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete this book?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteBook(at indexPath: IndexPath) {
        guard let bookID = books[indexPath.row].bookID else {
            print("Invalid book ID")
            return
        }

        let deleteURL = "http://localhost:3000/books/\(bookID)"

        AF.request(deleteURL, method: .delete).response { [weak self] response in
            switch response.result {
            case .success:
                self?.books.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .fade)
                print("Book deleted successfully")
            case .failure(let error):
                print("Error deleting book: \(error)")
            }
        }
    }


    @IBAction func addButton(_ sender: Any) {
        selectedBook = nil
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEditSegue" {
            guard let addEditVC = segue.destination as? AddEditViewController else {
                return
            }

            addEditVC.delegate = self
            addEditVC.selectedBook = selectedBook
        }
    }
}

extension FirebaseCRUDVC: AddEditDelegate {
    func didSaveBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.bookID == book.bookID }) {
            // Update existing book
            books[index] = book
        } else {
            // Add new book
            books.append(book)
        }

        tableView.reloadData()
    }
}
