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
The `M_Genre` enumeration describes the different genres of movie.
``` swift
enum M_Genre: String {
    case action   = "Action"
    case crime    = "Crime"
    case thriller = "Thriller"
    case drama    = "Drama"
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

### Preparing for Errors

### Parsing in a Bottom-up Mannor 
- Genre
- ExtraInfo
- Movie

### Presentation and Use
- CustomStringConvertable





### References

### Code Link
A source controlled runabble version can be found [here](https://github.com/Tomos-Evans/swift_JSON_parsing).
