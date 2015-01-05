# Rosetta
The Rosetta Stone is a granodiorite stele inscribed with a decree issued at Memphis in 196 BC. It provided the key to the modern understanding of Egyptian hieroglyphs. [wiki](http://en.wikipedia.org/wiki/Rosetta_Stone)  
Just like the Rosetta Stone made translation of Egyptian hieroglyphs possible, this library is intended to make **parsing JSON to Swift** objects and back easy and safe.

## Installation

### CocoaPods

### Manual

## Features

* Parsing `JSON` to `Swift types` (Both **classes** and **structures** are supported)
* Parsing back to `JSON` (if you can parse `JSON` to a given `Swift type`, you can always get a `JSON` back)
* Type validation
* Type conversion (e.g. `Strings` in `JSON` can be bridged to `NSURL`)
* Value validation
* **Required** and **optional** fields support
* Concise syntax with advanced features opt-in
* No **required** protocols
* Debug logs

## Usage (in a nutshell)

This is just a brief overview of how `Rosetta` works, but it should give you the idea. Please refer to [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md) for thorough documentation.

### JSON Decoding

Let's look at a simple example. Say we have a `JSON` representation of a user:
```json
{  
  "name": "Bill",
  "age": 22
}
```
and want to be able to parse that into a Swift `struct`:
```swift
struct User {
  var name: String?
  var age: Int?
}
```
The most blunt and verbose way to do that is:
```swift
var user = User(name: nil, age: nil)
let success = Rosetta().decode(jsonDataOrString, to: &user, usingMap: {(json, inout object: User) -> () in
  object.name <~ json["name"]
  object.age  <~ json["age"]
})
```
But if we make `User` conform to the `JSONConvertible` protocol (`JSONConvertibleClass` for class types), we can reduce that call down to:
```swift
let user: User? = Rosetta().decode(jsonDataOrString)
```
`JSONConvertible` implementation for `User` may look like this:
```swift
extension User: JSONConvertible {
  init() {
    
  }
  
  static func map(json: Rosetta, inout object: User) {
    object.name <~ json["name"]
    object.age  <~ json["age"]
  }
}
```
For details on how `decoding` works, please refer to [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#json-decodin)

### JSON Encoding

You can always get a `JSON` back as `NSData` (assuming `userObject` conforms to `JSONConvertible` / `JSONConvertibleClass` protocol)
```swift
let json: NSData? = Rosetta().encode(userObject)
```
or `String`
```swift
let json: String? = Rosetta().encode(userObject)
```
Further `encoding` details are described in [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#json-encoding)

### Required fields

If you want a certain field to be treated as required, map it with a `<-` operator:
```swift
object.name <- json["name"]
```
`Decoding` / `encoding` will fail if such value is missing (or does not pass conversion or validation).

### Optional fields

If you want to treat a certain field as optional, map it with a `<~` operator:
```swift
object.name <~ json["name"]
```
If this field is missing (or does not pass conversion or validation) `Decoding` / `encoding` will not fail entirely, but will skip this field and move on.

### Type conversion

You can convert e.g. a `String` from JSON to `NSURL` using the `~` operator and a `bridge`
```swift
object.url <~ json["URL"] ~ BridgeString(
  decoder: {NSURL(string: $0)},
  encoder: {$0.absoluteString}
)
```
To make it more concise you can return the `bridge` from a function:
```swift
func NSURLBridge() -> Bridge<NSURL, NSString> {
  return BridgeString(
    decoder: {NSURL(string: $0)},
    encoder: {$0.absoluteString}
  )
}
```
and then map:
```swift
object.url <~ json["URL"] ~ NSURLBridge()
```
`NSURLBridge()` is in fact alreaty built-in to `Rosetta`, but you'll likely make other bridges of your own.

Bridging is a pretty big but essential part of `Rosetta`. It's explained in-depth in [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#bridging-)

### Value validation

You can validate the value using a `§` operator (`⌥6`) followed by a  
`(<SwiftPropertyType>) -> (BOOL)` closure:
```swift
object.age <~ json["age"] § {$0 > 0}
```
So in this example, `age` has to be greater than `0`.

More about validation in [guide](https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#validation-)

### Debug logs
`Rosetta` can print debug logs:
```
Rosetta
ViewController.swift:904 handleResult()
JSON String: {"age":0,"website":"ftp://nonono.bad"}
Error: Value Missing for key-path: name
Error: Validation Failed for key-path: age
Warning: Validation Failed for key-path: website
```
Logs are disabled by default. You can enable them by setting `.logLevel` property:
```swift
let rosetta = Rosetta()
rosetta.logLevel = .Errors
```
or
```swift
rosetta.logLevel = .Verbose
```
You can also change the **log output** (if `println()` does not suit you) and **customize** the log format. All that is described in-depth in [guide]https://github.com/bartekchlebek/Rosetta/blob/documentation/GUIDE.md#logs)

## License
Rosetta is available under the MIT license. See the [LICENSE](https://github.com/bartekchlebek/Rosetta/blob/master/LICENSE) file for more info.
