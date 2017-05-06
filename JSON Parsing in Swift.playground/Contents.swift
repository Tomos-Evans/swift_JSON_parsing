// TODO Document

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

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
    
    /// The movies plot
    let plot:      String
    
    /// The title and the year
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
    

    let value:     String
}

/// The different Film Genres
enum M_Genre: String {
    case action      = "Action"
    case crime       = "Crime"
    case thriller    = "Thriller"
    case drama       = "Drama"
    case short       = "Short"
    case scifi       = "Sci-fi"
    case comedy      = "Comedy"
    case horror      = "Horror"
    case documentary = "Documentary"
    case history     = "History"
    case war         = "War"
    case mystery     = "Mystery"
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
    case missingPlot
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
    private static func parsePlot(json: [String: Any]) throws -> String {
        guard let plot = json["Plot"] as? String else {
            throw MovieJSONParseError.missingPlot
        }
        return plot
    }
    

    
    
    
    /// Parser a `Location` from the `json` dictinoary.
    init(json: [String: Any]) throws {
        guard let combinedGenres = json["Genre"] as? String else {
            throw MovieJSONParseError.missingGenre
        }
        
        let title       = try M_Movie.parseTitle(json: json)
        let year        = try M_Movie.parseYear(json: json)
        let rated       = try M_Movie.parseRated(json: json)
        let genre       = combinedGenres.components(separatedBy: ", ").flatMap(M_Genre.init)
        let plot        = try M_Movie.parsePlot(json: json)
        let details     = try M_ExtraDetails(json: json)
        

        
        
        self.init(title:   title,
                  year:    year,
                  rated:   rated,
                  genre:   genre,
                  details: details,
                  plot:    plot)
    }
}

extension M_ExtraDetails{
    private static func parseRuntime(json: [String: Any]) throws -> Int {
        guard let runtime = json["Runtime"] as? String else {
            throw ExtraDetailJSONParseError.missingRuntime
        }
        return Int(runtime.components(separatedBy: " ")[0])!
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


// TODO These are not correct
extension M_Rating{
    private static func parseSource(json: [String: Any]) throws -> String {
        guard let ratings = json["Ratings"] as? [[String: Any]],
              let first = ratings.first,
              let source = first["Source"] as? String else {
            throw RatingJSONParseError.missingSource
        }
        return source
    }
    private static func parseValue(json: [String: Any]) throws -> String {
        guard let ratings = json["Ratings"] as? [[String: Any]],
            let first = ratings.first,
            let value = first["Value"] as? String else {
            throw RatingJSONParseError.missingValue
        }
        return value
    }
    
    
    /// Parser a `Location` from the `json` dictinoary.
    init(json: [String: Any]) throws {
        let source     = try M_Rating.parseSource(json: json)
        let value      = try M_Rating.parseValue(json: json)
        
        
        self.init(source: source,
                  value:  value)
    }
}
//
//extension M_Genre{
//    private static func parseGenre(raw: String) throws -> M_Genre {
//        guard let genre = M_Genre(rawValue: raw) else {
//            throw GenreJSONParseError.unknownGenre
//        }
//        
//        return genre
//    }
//    
//    /// Parser a `Location` from the `json` dictinoary.
//    init(json: [String: Any]) throws {
//        print(json)
//        let genre      = try M_Genre.parseGenre(json: json)
//        self = genre
//        
//    }
//}














struct APIFetcher {
    /// Fetches the JSON from `url`. When done the JSON is made available in
    /// `completion`.
    private static func fetch(from url: String, with completion: @escaping ([String: Any]) -> ()) {
        let stringUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let myUrl = URL(string: stringUrl!)
        
        // Creaste URL Request
        var request = URLRequest(url: myUrl!)
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        

        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for error
            if error != nil {
                print("error=\(error)")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        completion(dict)
                    }
                } catch let error as NSError {
                    print("JSON Error : \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
        
    }
    
    /// Fetches the restaurants near the `postcode` in `category`.
    static func fetchMovie(title: String, with completion: @escaping (M_Movie) -> ()){
        // TODO Account for spaces in the title, and fill with `+`
        let url = "http://www.omdbapi.com/?t=\(title)"
        fetch(from: url) { json in
            let movie = json
            

            let parsedMovie = try! M_Movie(json: movie)
            completion(parsedMovie)
        }
    }
}



extension M_Movie: CustomStringConvertible{
    var description: String{
        
        return "Movie Information : \n" +
        "   Title    : \(self.title           ) \n" +
        "   Year     : \(self.year            ) \n" +
        "   Rated    : \(self.rated           ) \n" +
        "   Runtime  : \(self.details.runtime ) mins \n" +
        "   Actors   : \(self.details.actors  ) \n" +
        "   Writer   : \(self.details.writer  ) \n" +
        "   Plot     : \(self.plot            ) \n" +
        "\n"
    }
}



APIFetcher.fetchMovie(title: "black hawk down"     ) { print($0) }
APIFetcher.fetchMovie(title: "Shooter"             ) { print($0) }
APIFetcher.fetchMovie(title: "Saving  private Ryan") { print($0) }
APIFetcher.fetchMovie(title: "enemy at the gates"  ) { print($0) }






