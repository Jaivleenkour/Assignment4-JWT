import Foundation

struct Book: Codable {
    var bookID: Int?
    var title: String
    var author: String
    var ISBN: String
    var rating: Double
    var genres: String

    enum CodingKeys: String, CodingKey {
        case bookID = "bookID"
        case title = "Title"
        case author = "Author"
        case ISBN = "ISBN"
        case rating = "Rating"
        case genres = "Genres"
    }

    init(bookID: Int, title: String, author: String, ISBN: String, rating: Double, genres: String) {
        self.bookID = bookID
        self.title = title
        self.author = author
        self.ISBN = ISBN
        self.rating = rating
        self.genres = genres
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        bookID = try container.decode(Int.self, forKey: .bookID)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        ISBN = try container.decode(String.self, forKey: .ISBN)
        rating = try container.decode(Double.self, forKey: .rating)
        genres = try container.decode(String.self, forKey: .genres)
    }

    // Encoding method if needed
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(bookID, forKey: .bookID)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(ISBN, forKey: .ISBN)
        try container.encode(rating, forKey: .rating)
        try container.encode(genres, forKey: .genres)
    }
}
