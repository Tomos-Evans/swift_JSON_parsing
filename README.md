# Parsing JSON to CustomDatatypes in Swift 3

## Motivation
On your quest to develop your perfect iOS app, it will soon become apparent that there is only so much you can do with good UX. It is at this point that the three golden letters on convienient and usefull information will cross your path, API. APIs are used to provide extra data and information, whih comre almost exclusivly in JSON format, which is the center of this centre of this project.

This tutorial will discuss methods and implement a way of asynchronously parsing JSON that was returned from an API call into custom datatypes for further use in your app. The project will be based around the [OMDb API](http://www.omdbapi.com/), and create a small project that displays information about any specified movie. Although the project is simple, the techniques are highly scalable, and common place in large software development projects. 

### What is JSON?
JavaScript Object Notation (JSON), is a human readable format for structuring data. An exmple of JSON that we will be using can be found [here](https://gist.github.com/Tomos-Evans/584b96f4cad889e6c4ad6a7520d2e87f). It is used primarily to transmit data between a server and web application. The main structure behind JSON is **key : value** pairs. These pairs are simular to a dictionary in Java or Python, and consist of a **key**, which is the identifier, and a **value** which is the data that will be returned when the corresdponding value is requested. The **Value** component can be one of several types  to aid structure. types include Booleans, Numbers (Integers and Floats) and Strings. JSON also supports types that are a little less obvious:
1. Arrays
    Arrays containing any of the allowed types can be used to return list items. This is usefull for nested structures.
2. Objects
    An object is indicated by curly brackets `{...}`. Everything inside of the curly brackets is part of the object. An object can be thought of as a new section of JSON, that contain all the same typs and structures.

### Where is JSON used?
- API calls

### Example Project Introduction
Now that you have a basic understnaging of what JSON is, and why you need know about it, we can begin with our example project. As I mentioned earlier, we will be making a simple program that goes through the stages calling an API and retreving JSON, error chcking, and parsing the JSON into our custom datatypes. For consistency, all classes relating to a movie are prefixed with `M_`
The datatypes are as follows:

The `M_Genre` enumeration describes the different genres of movie. The enumerations have a raw value of type `String` so that the string that is returned as the **value** can be cast to a `M_Genre`. In the code extract 
``` swift
enum M_Genre: String {
    case action      = "Action"
    case crime       = "Crime"
    ...
    case mystery     = "Mystery"
}
```
The `M_Rating` structure is used to store the different ratings that a particular movie has recieved. The source of the review (eg. Rotten Tomatoes) is stored in `source`, and the score that it recieved is contained in `value`.
``` swift
struct M_Rating {
    let source:    String
    let value:     String
}
```

The `M_ExtraDetails` structure is used to store less important information that is returned from the API call. It is also will serve as a good example of a nested structure later in.
``` swift
struct M_ExtraDetails{
    let runtime:   Int
    let writer:    String
    let ratings:   [M_Rating]
    let actors:    String
    let posterURL: String
}
```

Finally, we have the `M_Movie` structure. This is the end goal that we would like the JSON to parse to. `M_Movie` has properties that are of the types that we defined above, and is decalred as follows:

``` swift
struct M_Movie {
    let title:     String
    let year:      Int
    let rated:     String
    let genre:     [M_Genre]
    let details:   M_ExtraDetails
    var shortInfo: String {
        return title +  ", " + String(year)
    }
}
```

Now that we have all of the structures that we will be using defined, we can begin the main stages of this project.

### Making the API Call

``` swift 
struct APIFetcher {
    private static func fetch(from url: String, with completion: @escaping ([String: Any]) -> ()) {
        let stringUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let myUrl = URL(string: stringUrl!)
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "GET"
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
```


### Preparing for Errors
Whenever using external, and paritcularly online services, such as APIs, error handeling is imoportant. Defineing enumeratuons that mconform the `Error` protocol is useful for this reason, and  will be used by the parsers to `throw` an error. Below is an example of the error enumerations for the `M_ExtraDetail` structure, as you can see there is an error defined for each of the properites, which will need to be replacated for all of the previously defined structures.
``` swift
enum ExtraDetailJSONParseError: Error {
    case missingRuntime
    case missingWriter
    case missingAgeRating
    case missingActors
    case missingPosterURL
}
```
### Parsing in a Bottom-up Mannor 

Having declared our types, defined the errors that will be thrown, and have an overall good idea of the structure of our project, it is time to extend our `M_...` structures with their parsers.
Take note that, for instance, a `M_Movie` contains a `M_Genre` as one of its **values**. Based on this, intuitavly it would make sense to define the parser for the `M_Genre` prior doing the one for `M_Movie`. 

For example, below is the extension of the `M_ExtraDetails` structure that handels parseing the structures properties. When the desired property is of type `String` then the coversion is straight forward. 
```swift
extension M_ExtraDetails{
    private static func parseWriter(json: [String: Any]) throws -> String {
        guard let writer = json["Writer"] as? String else {
            throw ExtraDetailJSONParseError.missingWriter
        }
        return writer
    }
    
    ...
    
    private static func parsePosterURL(json: [String: Any]) throws -> String {
        guard let posterURL = json["Poster"] as? String else {
            throw ExtraDetailJSONParseError.missingPosterURL
        }
        return posterURL
    }
    
    private static func parseRuntime(json: [String: Any]) throws -> Int {
    guard let runtime = json["Runtime"] as? String else {
        throw ExtraDetailJSONParseError.missingRuntime
    }
    return Int(runtime.components(separatedBy: " ")[0])!
}
```

### Presentation and Use
- CustomStringConvertable





### References

### Code Link
A source controlled runabble version can be found [here](https://github.com/Tomos-Evans/swift_JSON_parsing).
