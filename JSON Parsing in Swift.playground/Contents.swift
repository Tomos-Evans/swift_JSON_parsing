// TODO Document


///////////////////
// Custom Datatypes
///////////////////

/// The main `Movie` object.
struct M_Movie {
    /// The Title of the movie.         
    /// eg: 'Shooter'
    let title:     String
    
    /// The release year.               
    /// eg: 2007
    let year:      Int
    
    /// The movies age rating. 
    /// eg: 'R'
    let rated:     String
    
    /// The movies genres.  
    /// eg: [action, crime, drama]
    let genre:     [M_Genre]
    
    /// Extra Details about the movie.
    let details:   M_ExtraDetails
    
    var shortInfo: String {
        return title +  ", " + String(year)
    }
}

/// Holds extra details about the move that
/// may not need to be as accessable.
struct M_ExtraDetails{
    /// The runtime of the movie (mins). 
    /// eg: 124
    let runtime:   Int
    
    /// The name of the films writer.
    /// eg: 'Jonathan Lemkin (screenplay), Stephen Hunter (novel)'
    let writer:    String
    
    /// A list of the films ratings.
    /// eg: M_Rating("Rotten Tomatoes", 7)
    let ratings:   [M_Rating]
    
    /// Actors that were in the movie.
    /// eg: 'Mark Wahlberg, Michael Peña, Danny Glover, Kate Mara'
    let actors:    String
    
    /// The URL of the movies poster.
    /// eg: 'https://images-na.ssl-images-amazon.com/images/M/MV5BMjA1NTU0Mzk4OF5BMl5BanBnXkFtZTcwNTc4MTY0MQ@@._V1_SX300.jpg'
    let posterURL: String
}

/// A critics rating of the movie
struct M_Rating {
    /// The source of the review.  
    /// eg: 'Rotten Tomatoes'
    let source:    String
    
    /// The movies rating out of 10.    
    /// eg: 7
    let value:     Int
}

/// The different Film Genres
enum M_Genre: String {
    case action   = "action"
    case crime    = "crime"
    case thriller = "thriller"
    case drama    = "drama"
}




//////////////////
// Parse Errors //
//////////////////


/// Error when parsing a `M_Movie`
enum MovieJSONParseError: Error {
    case missingTitle
    case missingYear
    case missingAgeRating
    case missingGenre
    case missingReviews
    case noInfoString
}


/// Error when parsing a `M_EtraDetail`
enum ExtraDetailJSONParseError: Error {
    case missingRuntime
    case missingWriter
    case missingAgeRating
    case missingActors
    case missingPosterURL
}

/// Error when parsing a `Review`
enum RatingJSONParseError: Error {
    case missingSource
    case missingValue
}

/// Error when parsing a `Genre`
enum GenreJSONParseError: Error {
    case missingGenre
    case unknownGenre
}




/////////////////////
// JSON to M_Movie //
/////////////////////

extension M_Movie{
    private static func parseTitle(json: [String: Any]) throws -> String {
        guard let title = json["Title"] as? String else {
            throw MovieJSONParseError.missingTitle
        }
        return title
    }
    
    private static func parseYear(json: [String: Any]) throws -> Int {
        guard let year = json["Year"] as? String else {
            throw MovieJSONParseError.missingYear
        }
        return Int(year)!
    }
    private static func parseRated(json: [String: Any]) throws -> String {
        guard let rated = json["Rated"] as? String else {
            throw MovieJSONParseError.missingAgeRating
        }
        return rated
    }

    
    
    
    /// Parser a `Location` from the `json` dictinoary.
    init(json: [String: Any]) throws {
        let title       = try M_Movie.parseTitle(json: json)
        let year        = try M_Movie.parseYear(json: json)
        let rated       = try M_Movie.parseRated(json: json)
        let genre       = try M_Genre(json: json)
        let details     = try M_ExtraDetails(json: json)
        
        
        self.init(title:   title,
                  year:    year,
                  rated:   rated,
                  genre:   [genre],
                  details: details)
    }
}

extension M_ExtraDetails{
    private static func parseRuntime(json: [String: Any]) throws -> Int {
        guard let runtime = json["Runtime"] as? String else {
            throw ExtraDetailJSONParseError.missingRuntime
        }
        return Int(runtime)!
    }
    
    private static func parseWriter(json: [String: Any]) throws -> String {
        guard let writer = json["Writer"] as? String else {
            throw ExtraDetailJSONParseError.missingWriter
        }
        return writer
    }
    private static func parseActors(json: [String: Any]) throws -> String {
        guard let actor = json["Actors"] as? String else {
            throw ExtraDetailJSONParseError.missingActors
        }
        return actor
    }
    private static func parsePosterURL(json: [String: Any]) throws -> String {
        guard let posterURL = json["Poster"] as? String else {
            throw ExtraDetailJSONParseError.missingPosterURL
        }
        return posterURL
    }

    
    
    /// Parser a `Location` from the `json` dictinoary.
    init(json: [String: Any]) throws {
        let runtime     = try M_ExtraDetails.parseRuntime(json: json)
        let writer      = try M_ExtraDetails.parseWriter(json: json)
        let ratings     = try M_Rating(json: json)
        let actors      = try M_ExtraDetails.parseActors(json: json)
        let posterURL   = try M_ExtraDetails.parsePosterURL(json: json)
        
        
        self.init(runtime: runtime,
                  writer:  writer,
                  ratings: [ratings],
                  actors: actors,
                  posterURL: posterURL)
    }
}

extension M_Rating{
    private static func parseSource(json: [String: Any]) throws -> String {
        guard let title = json["Source"] as? String else {
            throw RatingJSONParseError.missingSource
        }
        return title
    }
    private static func parseValue(json: [String: Any]) throws -> Int {
        guard let year = json["Value"] as? String else {
            throw RatingJSONParseError.missingValue
        }
        return Int(year)!
    }
    
    
    /// Parser a `Location` from the `json` dictinoary.
    init(json: [String: Any]) throws {
        let source     = try M_Rating.parseSource(json: json)
        let value      = try M_Rating.parseValue(json: json)
        
        
        self.init(source: source,
                  value:  value)
    }
}

extension M_Genre{
    private static func parseGenre(json: [String: Any]) throws -> M_Genre {
        guard let genString = json["Genre"] as? String else {
            throw GenreJSONParseError.missingGenre
        }
        guard let genre = M_Genre(rawValue: genString) else {
            throw GenreJSONParseError.unknownGenre
        }
        
        return genre
    }
    
    /// Parser a `Location` from the `json` dictinoary.
    init(json: [String: Any]) throws {
        let genre      = try M_Genre.parseGenre(json: json)
        self = genre
    }
}






////////////////////////////
// Using Custom Datatypes //
////////////////////////////
func displayMovie(movie: M_Movie){
    print(movie.title)
}



