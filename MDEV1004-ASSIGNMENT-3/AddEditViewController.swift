import UIKit

protocol AddEditDelegate: AnyObject {
    func didSaveBook(_ book: Book)
}

class AddEditViewController: UIViewController {

    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var authorLabel: UITextField!
    @IBOutlet var ratingLabel: UITextField!
    @IBOutlet var ISBNLabel: UITextField!
    @IBOutlet var genresLabel: UITextField!
    // Add other fields as needed

    weak var delegate: AddEditDelegate?
    var selectedBook: Book?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFields()
    }

    func configureFields() {
        if let book = selectedBook {
            titleLabel.text = book.title
            authorLabel.text = book.author
            ratingLabel.text = String(book.rating)
            ISBNLabel.text = book.ISBN
            genresLabel.text = book.genres
            // Configure other fields
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let title = titleLabel.text,
              let author = authorLabel.text,
              let ISBN = ISBNLabel.text,
              let genres = genresLabel.text,
              let ratingString = ratingLabel.text,
              let rating = Double(ratingString) else {
            // Handle invalid input
            return
        }

        var book: Book
        if let existingBook = selectedBook {
            // Edit existing book
            book = existingBook
            book.title = title
            book.author = author
            book.rating = rating
            book.ISBN = ISBN
            book.genres = genres
            // Update other fields
        } else {
            // Create a new book
            book = Book(bookID: -1, title: title, author: author, ISBN: ISBN, rating: rating, genres: genres)



        }

        delegate?.didSaveBook(book)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
