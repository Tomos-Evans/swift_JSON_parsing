
# JSON Parsing to Custom Datatypes in Swift 3

## Motivation
On your quest to develop your perfect iOS app, it will soon become apparent that there is only so much you can do with good UX. It is at this point that the three golden letters on convenient and useful information will cross your path, API. APIs are used to provide extra data and information, which come almost exclusively in JSON format, which is the center of this project.

This tutorial will discuss methods and implement a way of asynchronously parsing JSON that was returned from an API call into custom data types for further use in your app. The project will be based around the [OMDb API](http://www.omdbapi.com/) , and create a small project that displays information about any specified movie. Although the project is simple, the techniques are highly scalable, and common place in large software development projects. 

The format of this article will take the style of a tutorial, with relevant code snippets dispersed throughout the text in relevant places. I will be explaining by example as we build the simple project together. A link the the runnable xCode playground can be found at the end of the article.

## What is JSON?
JavaScript Object Notation (JSON), is a human readable format for structuring data. An example of JSON that we will be using can be found [here](https://gist.github.com/Tomos-Evans/584b96f4cad889e6c4ad6a7520d2e87f). It is used primarily to transmit data between a server and web application. The main structure behind JSON is based around `key : value` pairs. These pairs are similar to a dictionary in Java or Python, and consist of a `key`, which is the identifier, and a `value` which is the data that will be returned when the corresponding value is requested. The `Value` component can be one of several types to aid structure. Types include Booleans, Numbers (Integers and Floats) and Strings. JSON also supports types that are a little less obvious. Arrays containing any of the allowed types can be used to return list items, which is useful for nested structures. In addition, an "object" is indicated by curly brackets (`{...}`). Everything inside of the curly brackets is part of the object, and an object can be thought of as a new section of JSON that contain all the same types and structures.

## Where is JSON used?
As I touched on earlier, JSON is primarily used for the communication of structured data between a client and a server. This becomes most apparent when using APIs. In the past the XML standard was used to communicate API information, but since the more lightweight JSON came to light, the industry hasn't looked back. Here is just a few of the most popular APIs that return JSON as their primary method: Twitter API, Facebook Social Graph API, Flickr, YouTube, 26 Weather APIs, Rotten Tomatoes and Reddit. As you can see, being able to interact effectively with these services could bring your app to the next level. 

## Example Project Introduction 

Now that you have a basic understanding of what JSON is, and why you need know about it, we can begin with our example project. As I mentioned earlier, we will be making a simple program that goes through the stages calling an API and retrieving JSON, error checking, and parsing the JSON into our custom data types. For consistency, all classes relating to a movie are prefixed with `M_` so that they can be distinguished from Swift's inbuilt structures.

The data types are as follows:

The `M_Genre` enumeration describes the different genres of movie. The enumerations have a raw value of type `String` so that the string that is returned as the value can be cast to a `M_Genre`. In the code extract below I have only defined a select number of genres, in practice you would define more. 
``` swift
enum M_Genre: String {
    case action      = "Action"
    case crime       = "Crime"
    ...
    case mystery     = "Mystery"
}
```
The `M_Rating` structure is used to store the different ratings that a particular movie has received. The source of the review (eg. Rotten Tomatoes) is stored in `source`, and the score that it received is contained in `value`.
``` swift
struct M_Rating {
    let source:    String
    let value:     String
}
```

The `M_ExtraDetails` structure is used to store less important information that is returned from the API call. It is also will serve as a good example of a nested structure later on.
``` swift
struct M_ExtraDetails{
    let runtime:   Int
    let writer:    String
    let ratings:   [M_Rating]
    let actors:    String
    let posterURL: String
}
```

Finally, we have the `M_Movie` structure. This is the end goal that we would like the JSON to parse to.`M_Movie` has properties that are of the types that we defined above, and is declared as follows:

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

## Making the API Call

Although this tutorial isn\'t aimed at providing the perfect solution  for making request, the method below can be used as a starting point. The important aspect is defined in the `fetchMovie` function, where the base URL is defined, the `fetch` function is called to make the request, and finally the returned JSON is parsed in an attempt to form a `M\_Movie`.
 
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
        let url = "http://www.omdbapi.com/?t=\(title)"
        fetch(from: url) { json in
            let movie = json
            let parsedMovie = try! M_Movie(json: movie)
            completion(parsedMovie)
        }
    }
}
```

The implementation above is asynchronous, meaning that through the use of the \code{completion} the system will continue to run, and not hang while the request takes place. When the request is complete a call back is used to return the data that was requested. This is particularly useful for processes that rely on other services, such as the web server that is responding to our request. This can be seen in action at the end of the project by making multiple calls, and observing that some of the time the responses will be outputted in a different order. Asynchronous behavior is useful in many situation, and this is a very good example of its benefits over synchronous behavior.


## Preparing for Errors
Whenever using external, and particularly online services, such as APIs, error handling is important. Defining enumerations that conform the `Error` protocol is useful for this reason, and  will be used by the parsers to `throw` an error. Below is an example of the error enumerations for the `M_ExtraDetail` structure, as you can see there is an error defined for each of the properties, which will need to be replicated for all of the previously defined structures.
``` swift
enum ExtraDetailJSONParseError: Error {
    case missingRuntime
    case missingWriter
    case missingAgeRating
    case missingActors
    case missingPosterURL
}
```
## Parsing in a Bottom-up Manner

Having declared our types, defined the errors that will be thrown, and have an overall good idea of the structure of our project, it is time to extend our `M_..` structures with their respective parsers.
Take note that, for instance, a `M\_Movie` contains a `M\_Genre` as one of its values. Based on this, intuitively it would make sense to define the parser for the `M_Genre` prior doing the one for `M_Movie`. 

For example, below is the extension of the `M_ExtraDetails` structure that handles parsing the structures properties. When the desired property is of type `String` then the conversion is straight forward. The guard statement simply checks that the value is not `nil`, and if not, returns the parsed string. If the value is `nil`, then the errors that we defined earlier are thrown. When the type of the property that we are trying to parse into is not of type `String`, we must cast the value to the correct type, as seen in the `ParseRuntime` function. Take note that the returned value for the movies runtime is of the form "123 mins", so in order to just extract the Integer part, we can use the `components(separatedBy: " ")` command, which returns a list in the form `["123", "mins"]`. Taking the 0th element of this list is therefor the String containing the Integer that we desire.
``` swift
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

The above process must b e completed for the other structures. By looking at the format and structure of the JSON, it is possible see the required Key, and by parsing on that key, a particular value can be obtained.

## Presentation and Use 

We are DONE! By this stage, we have successfully made an API request, received the JSON, and parsed it safely into our custom data type. There is just one small thing that we can do to make displaying our new `M_Movie` datatype, which is to define `customStringConvertable`. This will allow us to used the `print` command to display the properties of the structure in a clean way.

``` swift
extension M_Movie: CustomStringConvertible{
    var description: String{
        
        return "Movie Information : \n" +
        "   Title    : \(self.title           )      \n" +
        "   Year     : \(self.year            )      \n" +
        "   Rated    : \(self.rated           )      \n" +
        "   Runtime  : \(self.details.runtime ) mins \n" +
        "   Actors   : \(self.details.actors  )      \n" +
        "   Writer   : \(self.details.writer  )      \n" +
        "   Plot     : \(self.plot            )      \n" +
        "\n"
    }
}
```

All that is left to do now is run our code! Simply enter:

`APIFetcher.fetchMovie(title: "black hawk down") { print(\$0) }`

and the following output should be attained:
``` sh
Movie Information : 
   Title		: Black Hawk Down 
   Year		    : 2001 
   Rated        : R 
   Runtime      : 144 mins 
   Actors       : Josh Hartnett, Ewan McGregor, Tom Sizemore, Eric Bana 
   Writer       : Mark Bowden (book), Ken Nolan (screenplay) 
   Plot         : U.S. soldiers drop into Somalia to capture two top lieutenants of a renegade warlord and find themselves in a battle with a large force Somalis.
```
Which overall, I think is pretty cool. 


## Why is this Readme so long!?
This project was an assessed "tutorial" for the Univerisity of Bristol's Software Enginnering Unit, which had a requirement that the readme should explain the code properly
