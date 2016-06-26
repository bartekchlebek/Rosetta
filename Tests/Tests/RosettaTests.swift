import Foundation
import XCTest
import Rosetta

func jsonFrom(_ data: Data) -> NSDictionary {
  return try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
}

func dataFrom(_ json: [String: AnyObject]) -> Data {
  return try! JSONSerialization.data(withJSONObject: json, options: [])
}

func dataFrom(_ json: [String]) -> Data {
	return try! JSONSerialization.data(withJSONObject: json, options: [])
}

func ==(lhs: SubObject, rhs: SubObject) -> Bool {
  return lhs.a1 == rhs.a1
}

struct SubObject: JSONConvertible, Equatable {
  var a1: String = "x"
  init () {
    
  }
  static func map(_ object: inout SubObject, json: Rosetta) {
    object.a1 <- json["a1-key"]
  }
}

struct Object: JSONConvertible {
  var a1: String  = "x"
  var a2: String! = "x"
  var a3: String? = "x"
  
  var b1: Int   = 0
  var b2: Int!  = 0
  var b3: Int?  = 0
  
  var c1: Bool   = false
  var c2: Bool!  = false
  var c3: Bool?  = false
  
  var d1: [String]  = ["x"]
  var d2: [String]! = ["x"]
  var d3: [String]? = ["x"]
  
  var e1: [String: String]  = ["x": "y"]
  var e2: [String: String]! = ["x": "y"]
  var e3: [String: String]? = ["x": "y"]
  
  var f1: URL  = URL(string: "http://www.google.pl")!
  var f2: URL! = URL(string: "http://www.google.pl")!
  var f3: URL? = URL(string: "http://www.google.pl")!
  
  var g1: SubObject  = SubObject()
  var g2: SubObject! = SubObject()
  var g3: SubObject? = SubObject()
  
  var h1: [URL]  = [URL(string: "http://www.google.pl")!]
  var h2: [URL]! = [URL(string: "http://www.google.pl")!]
  var h3: [URL]? = [URL(string: "http://www.google.pl")!]
  
  var i1: [String: URL]  = ["x": URL(string: "http://www.google.pl")!]
  var i2: [String: URL]! = ["x": URL(string: "http://www.google.pl")!]
  var i3: [String: URL]? = ["x": URL(string: "http://www.google.pl")!]
  
  init() {
    
  }
  
  static func map(_ object: inout Object, json: Rosetta) {
    object.a1 <- json["a1-key"]
    object.a2 <- json["a2-key"]
    object.a3 <~ json["a3-key"]
    
    object.b1 <- json["b1-key"]
    object.b2 <- json["b2-key"]
    object.b3 <~ json["b3-key"]
    
    object.c1 <- json["c1-key"]
    object.c2 <- json["c2-key"]
    object.c3 <~ json["c3-key"]
    
    object.d1 <- json["d1-key"]
    object.d2 <- json["d2-key"]
    object.d3 <~ json["d3-key"]
    
    object.e1 <- json["e1-key"]
    object.e2 <- json["e2-key"]
    object.e3 <~ json["e3-key"]
    
    object.f1 <- json["f1-key"] ~ NSURLBridge
    object.f2 <- json["f2-key"] ~ NSURLBridge
    object.f3 <~ json["f3-key"] ~ NSURLBridge
    
    object.g1 <- json["g1-key"]
    object.g2 <- json["g2-key"]
    object.g3 <~ json["g3-key"]
    
    object.h1 <- json["h1-key"] ~ BridgeArray(NSURLBridge)
    object.h2 <- json["h2-key"] ~ BridgeArray(NSURLBridge)
    object.h3 <~ json["h3-key"] ~ BridgeArray(NSURLBridge)
    
    object.i1 <- json["i1-key"] ~ BridgeObject(NSURLBridge)
    object.i2 <- json["i2-key"] ~ BridgeObject(NSURLBridge)
    object.i3 <~ json["i3-key"] ~ BridgeObject(NSURLBridge)
  }
}

struct Object1: JSONConvertible {
    var name: String

    init() {
        name = "John"
    }

    static func map(_ object: inout Object1, json: Rosetta) {
        object.name <- json["name"]
    }
}

struct Object2: JSONConvertible {
    var name: String!

    init() {

    }

    static func map(_ object: inout Object2, json: Rosetta) {
        object.name <- json["name"]
    }
}

struct Object3: JSONConvertible {
    var name: String?

    init() {

    }

    static func map(_ object: inout Object3, json: Rosetta) {
        object.name <~ json["name"]
    }
}

struct Object4: JSONConvertible {
    var name: String

    init() {
        name = "John"
    }

    static func map(_ object: inout Object4, json: Rosetta) {
        object.name <- json["name"]
    }
}

struct Object5: JSONConvertible {
    var name: String

    init() {
        name = "John"
    }

    static func map(_ object: inout Object5, json: Rosetta) {
        object.name <- json["result"]["name"]
    }
}

struct Object6: JSONConvertible {
    var name: String

    init() {
        name = "John"
    }

    static func map(_ object: inout Object6, json: Rosetta) {
        object.name <- json["result"]["name"]
    }
}

struct Object7: JSONConvertible {
    var a1: String?

    init() {

    }

    static func map(_ object: inout Object7, json: Rosetta) {
        object.a1 <- json["a1"]
    }
}

struct Object8: JSONConvertible {
    var a1: SubObject1 = SubObject1()
    var a2: SubObject1!
    var a3: SubObject1?
    var b1: SubObject1?

    init() {

    }

    static func map(_ object: inout Object8, json: Rosetta) {
        object.a1 <- json["a1"] § {$0.value == 5}
        object.a2 <- json["a2"] § {$0.value == 5}
        object.a3 <- json["a3"] § {$0.value == 5}
        object.b1 <~ json["b1"] § {$0.value == 5}
    }
}

struct SubObject1: JSONConvertible {
    var value: Int!
    init() {

    }

    init(value: Int) {
        self.value = value
    }

    static func map(_ object: inout SubObject1, json: Rosetta) {
        object.value <- json["value"]
    }
}

struct Object9: JSONConvertible {
    var a0: Int?
    var a1: Int8?
    var a2: Int16?
    var a3: Int32?
    var a4: Int64?
    var a5: UInt?
    var a6: UInt8?
    var a7: UInt16?
    var a8: UInt32?
    var a9: UInt64?

    var b0: Float?
    var b1: Double?
    //      var b2: Swift.Float80? // NOT SUPPORTED
    //      var b3: Float96? // NOT SUPPORTED

    var c0: Bool?

    var d0: NSNumber?

    var e0: String?
    var e1: NSString?
    var e2: NSMutableString?

    var f0: AnyObject?
    var g0: [AnyObject]?
    var h0: [String: AnyObject]?

    var i0: AnyObject?

    init() {

    }

    static func map(_ object: inout Object9, json: Rosetta) {
        object.a0 <- json["a0"]
        object.a1 <- json["a1"]
        object.a2 <- json["a2"]
        object.a3 <- json["a3"]
        object.a4 <- json["a4"]
        object.a5 <- json["a5"]
        object.a6 <- json["a6"]
        object.a7 <- json["a7"]
        object.a8 <- json["a8"]
        object.a9 <- json["a9"]

        object.b0 <- json["b0"]
        object.b1 <- json["b1"]
        //        object.b2 <- json["b2"]
        //        object.b3 <- json["b3"]

        object.c0 <- json["c0"]

        object.d0 <- json["d0"] ~ NSNumberBridge

        object.e0 <- json["e0"]
        object.e1 <- json["e1"] ~ NSStringBridge
        object.e2 <- json["e2"] ~ NSMutableStringBridge

        //        object.f0 <- json["f0"] ~ AnyObjectBridge()
        //        object.g0 <- json["g0"] ~ BridgeArray(AnyObjectBridge())
        //        object.h0 <- json["h0"] ~ BridgeObject(AnyObjectBridge())
        //
        //        object.i0 <- json["i0"] ~ TollFreeBridge()
    }
}

struct Object10: JSONConvertible {
    var name: String

    init() {
        name = "John"
    }

    static func map(_ object: inout Object10, json: Rosetta) {
        object.name <- json["name"]
    }
}

struct Structure1: JSONConvertible {
    var a1: String = "x"

    init() {

    }

    static func map(_ object: inout Structure1, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
    }
}

struct Structure2: JSONConvertible {
    var a1: String? = "x"

    init() {

    }

    static func map(_ object: inout Structure2, json: Rosetta) {
        object.a1 <~ json["a1"] § {$0 == "a1"}
    }
}

struct Structure3: JSONConvertible {
    var a1: String  = "x"
    var a2: String!
    var a3: String?

    init() {

    }

    static func map(_ object: inout Structure3, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
        object.a2 <- json["a2"] § {$0 == "a2"}
        object.a3 <~ json["a3"] § {$0 == "a3"}
    }
}

struct Structure4: JSONConvertible {
    var a1: URL  = URL(string: "http://www.wp.pl")!
    var a2: URL!
    var a3: URL?

    init() {

    }

    static func map(_ object: inout Structure4, json: Rosetta) {
        object.a1 <- json["a1"] ~ NSURLBridge § {$0.absoluteString == "http://www.google.com"}
        object.a2 <- json["a2"] ~ NSURLBridge § {$0.absoluteString == "http://www.google.com"}
        object.a3 <~ json["a3"] ~ NSURLBridge § {$0.absoluteString == "http://www.google.com"}
    }
}

struct User1: JSONConvertible {
    var name: String?

    init() {

    }

    init(name: String) {
        self.name = name
    }

    static func map(_ object: inout User1, json: Rosetta) {
        object.name <- json["name"]
    }
}

struct Group1: JSONConvertible {
    var users1: [User1] = []
    var users2: [User1]!
    var users3: [User1]?

    init() {

    }

    init(users1: [User1], users2: [User1], users3: [User1]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
    }

    static func map(_ object: inout Group1, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
    }
}

struct User2: JSONConvertible {
    var name: String?

    init() {

    }

    init(name: String) {
        self.name = name
    }

    static func map(_ object: inout User2, json: Rosetta) {
        object.name <- json["name"]
    }
}

struct Group2: JSONConvertible {
    var users1: [String: User2] = [:]
    var users2: [String: User2]!
    var users3: [String: User2]?

    init() {

    }

    init(users1: [String: User2], users2: [String: User2], users3: [String: User2]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
    }

    static func map(_ object: inout Group2, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
    }
}

struct User3: JSONConvertible {
    var ID: String?
    var name: String?
    var age: Int?
    var website: URL?
    var friends: [User3]?
    var family: [String : User3]?

    init() {

    }

    static func map(_ object: inout User3, json: Rosetta) {
        object.ID       <- json["uniqueID"] // Map required properties with <-
        object.name     <~ json["name"] // Map optional properties with <~
        object.age      <~ json["age"] § {$0 > 0} // Add validation closure after § operator (age > 0)
        // Types not conforming to Bridgeable protocol (like NSURL here) need to have bridging code after ~ operator
        object.website  <~ json["website_url"] ~ BridgeString(
            decoder: {URL(string: $0 as String)}, // convert NSString from json to NSURL
            encoder: {$0.absoluteString} // convert NSURL from Person to NSString for JSON
        )
        object.friends  <~ json["friends"] // Automaticaly mapped arrays
        object.family   <~ json["family"] // Automaticaly mapped dictionaries
    }
}

struct CustomConvertibleType: JSONConvertible {
    var someValue: Double?

    init() {

    }

    static func map(_ object: inout CustomConvertibleType, json: Rosetta) {
        object.someValue <- json["value"]
    }
}

enum CustomBridgeableType: Int, Bridgeable {
    case one = 1, two, three, four

    static func bridge() -> Bridge<CustomBridgeableType, NSNumber> {
        return BridgeNumber(
            decoder: {CustomBridgeableType(rawValue: $0.intValue)},
            encoder: {$0.rawValue}
        )
    }
}

struct YourCustomType: JSONConvertible {
    var value1: Int?
    var value2: CustomBridgeableType?
    var value3: CustomConvertibleType?
    var value4: URL?

    var requiredValue1: String = ""
    var requiredValue2: String!
    var requiredValue3: String?

    var validatedValue1: String?
    var validatedValue2: CustomBridgeableType?
    var validatedValue3: CustomConvertibleType?
    var validatedValue4: URL?

    var array1: [Int]?
    var array2: [CustomBridgeableType]?
    var array3: [CustomConvertibleType]?
    var array4: [URL]?

    var dictionary1: [String : Int]?
    var dictionary2: [String : CustomBridgeableType]?
    var dictionary3: [String : CustomConvertibleType]?
    var dictionary4: [String : URL]?

    init() {

    }

    static func map(_ object: inout YourCustomType, json: Rosetta) {
        object.value1 <~ json["value1"]
        object.value2 <~ json["value2"]
        object.value2 <~ json["value3"]
        object.value4 <~ json["value4"] ~ BridgeString(
            decoder: {URL(string: $0 as String)},
            encoder: {$0.absoluteString}
        )

        // Bridging placed in a constant just to reuse
        let urlBridge = BridgeString(
            decoder: {URL(string: $0 as String)},
            encoder: {$0.absoluteString}
        )

        object.requiredValue1 <- json["required1"]
        object.requiredValue2 <- json["required2"]
        object.requiredValue3 <- json["required3"]

        object.validatedValue1 <~ json["validated1"] § {$0.hasPrefix("requiredPrefix")}
        object.validatedValue2 <~ json["validated2"] § {$0 == .one || $0 == .three}
        object.validatedValue3 <~ json["validated3"] § {$0.someValue > 10.0}
        object.validatedValue4 <~ json["validated4"] ~ urlBridge § {$0.scheme == "https"}

        object.array1 <~ json["array1"]
        object.array2 <~ json["array2"]
        object.array3 <~ json["array3"]
        object.array4 <~ json["array4"] ~ BridgeArray(urlBridge)

        object.dictionary1 <~ json["dictionary1"]
        object.dictionary2 <~ json["dictionary2"]
        object.dictionary3 <~ json["dictionary3"]
        object.dictionary4 <~ json["dictionary4"] ~ BridgeObject(urlBridge)
    }
}

func complexJSON() -> Data {
  let bundle = Bundle(for: RosettaTests.classForCoder())
  let url = bundle.urlForResource("complex JSON", withExtension: "json")
  return (try! Data(contentsOf: url!))
}

class RosettaTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSimpleDecoder() {
    let object: Object1? = try? Rosetta().decode(dataFrom(["name": "Bob"]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithUnwrappedOptional() {
    let object: Object2? = try? Rosetta().decode(dataFrom(["name": "Bob"]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithOptional() {
    let object: Object3? = try? Rosetta().decode(dataFrom(Dictionary<String, AnyObject>()))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.name == nil, "object.name should remain unmodified")
  }
  
  func testComplexDecoder() {
    let dictionary = complexJSON()
    let object: Object? = try? Rosetta().decode(dictionary)
    
    XCTAssertTrue(object != nil, "object should exist")
    
    XCTAssertEqual(object!.a1, "a1-value")
    XCTAssertEqual(object!.a2, "a2-value")
    XCTAssertEqual(object!.a3!, "a3-value")
    
    XCTAssertEqual(object!.b1, 1)
    XCTAssertEqual(object!.b2, 2)
    XCTAssertEqual(object!.b3!, 3)
    
    XCTAssertEqual(object!.c1, true)
    XCTAssertEqual(object!.c2, true)
    XCTAssertEqual(object!.c3!, true)
    
    XCTAssertEqual(object!.d1, ["d1-1", "d1-2", "d1-3"])
    XCTAssertEqual(object!.d2, ["d2-1", "d2-2", "d2-3"])
    XCTAssertEqual(object!.d3!, ["d3-1", "d3-2", "d3-3"])
    
    XCTAssertEqual(object!.e1, ["e1": "e1-value"])
    XCTAssertEqual(object!.e2, ["e2": "e2-value"])
    XCTAssertEqual(object!.e3!, ["e3": "e3-value"])
    
    XCTAssertEqual(object!.f1, URL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f2, URL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f3!, URL(string: "http://www.wp.pl")!)
    
    var subObject = SubObject(); subObject.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObject)
    XCTAssertEqual(object!.g2, subObject)
    XCTAssertEqual(object!.g3!, subObject)
  }
  
  func testComplexEncoder() {
    let data = complexJSON()
    let decoded: Object? = try? Rosetta().decode(data)
    XCTAssertTrue(decoded != nil, "decoded object should exist")
    let encoded: Data? = try? Rosetta().encode(decoded!)
    XCTAssertTrue(encoded != nil, "encoded object should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqual(to: jsonFrom(encoded!) as [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingDecoder() {
    let object: Object4? = try? Rosetta().decode(dataFrom(["name": 11]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingDecoderWithError() {
    let object: Object10? = try? Rosetta().decode(dataFrom(["name": 11]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testValidatedEncoder() {
    let structure = Structure1()
    let json: Data? = try? Rosetta().encode(structure)
    XCTAssertTrue(json == nil, "json should not exist")
  }
  
  func testValidatedEncoder1() {
    let structure = Structure2()
    let json: Data? = try? Rosetta().encode(structure)
    XCTAssertTrue(json != nil, "json should exist")
    XCTAssertTrue(jsonFrom(json!)["a1"] == nil, "json[\"a1\"] should not exist")
  }
  
  func testKeyPathsDecoder() {
    let object: Object5? = try? Rosetta().decode(dataFrom(["result": ["name": "Bob"]]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testKeyPathsEncoder() {
    let object: Object6? = try? Rosetta().decode(dataFrom(["result": ["name": "Bob"]]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testRequiredOptionalType() {
    let object: Object7? = try? Rosetta().decode(dataFrom(["a2": "a2"]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCustomMap() {
    struct Object {
      var a1: String?
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    var object = Object(a1: nil)

		XCTAssertNoThrow {
			try Rosetta().decode(jsonData, to: &object, usingMap: { (object: inout Object, json) -> () in
				object.a1 <- json["a1"]
			})
		}

    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCustomMapFailing() {
    struct Object {
      var a1: String?
    }
    let jsonData = dataFrom(["a2": "garbage"])
    var object = Object(a1: "a1-value")

		XCTAssertThrows {
			try Rosetta().decode(jsonData, to: &object, usingMap: { (object: inout Object, json) -> () in
				object.a1 <- json["a1"]
			})
		}

    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCreatableWithCustomMap() {
    struct Object: Creatable {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    let object = try? Rosetta().decode(jsonData, usingMap: { (object: inout Object, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object!.a1!, "a1-value")
  }
  
  func testCreatableWithCustomMapFailing() {
    struct Object: Creatable {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    let object = try? Rosetta().decode(jsonData, usingMap: { (object: inout Object, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCreatableWithCustomMapOptionalIgnored() {
    struct Object: Creatable {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    let object = try? Rosetta().decode(jsonData, usingMap: { (object: inout Object, json) -> () in
      object.a1 <~ json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 == nil, "object.a1 should not exist")
  }
  
  func testDroppingAllChangesIfDecodingFails()
  {
    struct Object {
      var a: String
      var b: String
    }
    
    let data = dataFrom(["a" : "1"])
    var object = Object(a: "0", b: "0")

		XCTAssertThrows {
			try Rosetta().decode(data, to: &object) { (o: inout Object, j) -> () in
				o.a <- j["a"]
				o.b <- j["b"]
			}
		}

    XCTAssertTrue(object.a == "0", "object.a should be equal to \"0\"")
    XCTAssertTrue(object.b == "0", "object.b should be equal to \"0\"")
  }
  
  //MARK: Key Path tests
  
  struct KeyPathObject: JSONConvertible {
    var a1: String  = "x"
    var a2: String! = "x"
    var a3: String? = "x"
    
    var b1: Int   = 0
    var b2: Int!  = 0
    var b3: Int?  = 0
    
    var c1: Bool   = false
    var c2: Bool!  = false
    var c3: Bool?  = false
    
    var d1: [String]  = ["x"]
    var d2: [String]! = ["x"]
    var d3: [String]? = ["x"]
    
    var e1: [String: String]  = ["x": "y"]
    var e2: [String: String]! = ["x": "y"]
    var e3: [String: String]? = ["x": "y"]
    
    var f1: URL  = URL(string: "http://www.google.pl")!
    var f2: URL! = URL(string: "http://www.google.pl")!
    var f3: URL? = URL(string: "http://www.google.pl")!
    
    var g1: SubObject  = SubObject()
    var g2: SubObject! = SubObject()
    var g3: SubObject? = SubObject()
    
    var h1: [URL]  = [URL(string: "http://www.google.pl")!]
    var h2: [URL]! = [URL(string: "http://www.google.pl")!]
    var h3: [URL]? = [URL(string: "http://www.google.pl")!]
    
    var i1: [String: URL]  = ["x": URL(string: "http://www.google.pl")!]
    var i2: [String: URL]! = ["x": URL(string: "http://www.google.pl")!]
    var i3: [String: URL]? = ["x": URL(string: "http://www.google.pl")!]
    
    init() {
      
    }
    
    static func map(_ object: inout KeyPathObject, json: Rosetta) {
      object.a1 <- json["result"]["object"]["a1-key"]
      object.a2 <- json["result"]["object"]["a2-key"]
      object.a3 <- json["result"]["object"]["a3-key"]
      
      object.b1 <- json["result"]["object"]["b1-key"]
      object.b2 <- json["result"]["object"]["b2-key"]
      object.b3 <- json["result"]["object"]["b3-key"]
      
      object.c1 <- json["result"]["object"]["c1-key"]
      object.c2 <- json["result"]["object"]["c2-key"]
      object.c3 <- json["result"]["object"]["c3-key"]
      
      object.d1 <- json["result"]["object"]["d1-key"]
      object.d2 <- json["result"]["object"]["d2-key"]
      object.d3 <- json["result"]["object"]["d3-key"]
      
      object.e1 <- json["result"]["object"]["e1-key"]
      object.e2 <- json["result"]["object"]["e2-key"]
      object.e3 <- json["result"]["object"]["e3-key"]
      
      object.f1 <- json["result"]["object"]["f1-key"] ~ NSURLBridge
      object.f2 <- json["result"]["object"]["f2-key"] ~ NSURLBridge
      object.f3 <- json["result"]["object"]["f3-key"] ~ NSURLBridge
      
      object.g1 <- json["result"]["object"]["g1-key"]
      object.g2 <- json["result"]["object"]["g2-key"]
      object.g3 <- json["result"]["object"]["g3-key"]
      
      object.h1 <- json["result"]["object"]["h1-key"] ~ BridgeArray(NSURLBridge)
      object.h2 <- json["result"]["object"]["h2-key"] ~ BridgeArray(NSURLBridge)
      object.h3 <- json["result"]["object"]["h3-key"] ~ BridgeArray(NSURLBridge)
      
      object.i1 <- json["result"]["object"]["i1-key"] ~ BridgeObject(NSURLBridge)
      object.i2 <- json["result"]["object"]["i2-key"] ~ BridgeObject(NSURLBridge)
      object.i3 <- json["result"]["object"]["i3-key"] ~ BridgeObject(NSURLBridge)
    }
  }
  
  func complexKeyPathJSON() -> Data {
    let bundle = Bundle(for: RosettaTests.classForCoder())
    let url = bundle.urlForResource("complex keyPath JSON", withExtension: "json")
    return (try! Data(contentsOf: url!))
  }
  
  func testComplexKeyPathDecoder() {
    let jsonData = complexKeyPathJSON()
    let object: KeyPathObject? = try? Rosetta().decode(jsonData)
    
    XCTAssertTrue(object != nil, "object should exist")
    
    XCTAssertEqual(object!.a1, "a1-value")
    XCTAssertEqual(object!.a2, "a2-value")
    XCTAssertEqual(object!.a3!, "a3-value")
    
    XCTAssertEqual(object!.b1, 1)
    XCTAssertEqual(object!.b2, 2)
    XCTAssertEqual(object!.b3!, 3)
    
    XCTAssertEqual(object!.c1, true)
    XCTAssertEqual(object!.c2, true)
    XCTAssertEqual(object!.c3!, true)
    
    XCTAssertEqual(object!.d1, ["d1-1", "d1-2", "d1-3"])
    XCTAssertEqual(object!.d2, ["d2-1", "d2-2", "d2-3"])
    XCTAssertEqual(object!.d3!, ["d3-1", "d3-2", "d3-3"])
    
    XCTAssertEqual(object!.e1, ["e1": "e1-value"])
    XCTAssertEqual(object!.e2, ["e2": "e2-value"])
    XCTAssertEqual(object!.e3!, ["e3": "e3-value"])
    
    XCTAssertEqual(object!.f1, URL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f2, URL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f3!, URL(string: "http://www.wp.pl")!)
    
    var subObject = SubObject(); subObject.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObject)
    XCTAssertEqual(object!.g2, subObject)
    XCTAssertEqual(object!.g3!, subObject)
  }
  
  func testComplexKeyPathEncoder() {
    let jsonData = complexKeyPathJSON()
    let decoded: KeyPathObject? = try? Rosetta().decode(jsonData)
    XCTAssertTrue(decoded != nil, "decoded should not be nil")
    let encoded: Data? = try? Rosetta().encode(decoded!)
    XCTAssertTrue(encoded != nil, "encoded should not be nil")
    XCTAssertTrue(
      jsonFrom(jsonData).isEqual(to: jsonFrom(encoded!) as [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingComplexKeyPathDecoder() {
    let dictionary = complexJSON()
    let object: KeyPathObject? = try? Rosetta().decode(dictionary)
    
    
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingComplexKeyPathDecoder2() {
    let dictionary = complexKeyPathJSON()
    let object: Object? = try? Rosetta().decode(dictionary)
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testDecodingWithCustomMap() {
    struct Object {
      var a1: String?
      init () {
        
      }
    }
    
    var object = Object()
		_ = try? Rosetta().decode(dataFrom(["a1": "a1"]), to: &object, usingMap: { (object: inout Object, json) -> () in
      object.a1 <- json["a1"]
    })
    
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1")
  }
  
  func testImplicitBridgeWithValidator() {
    var obj: Object8?
    obj = try? Rosetta().decode(
      dataFrom(
        ["a1": ["value": 5],
          "a2": ["value": 5],
          "a3": ["value": 5],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj != nil, "obj should not be nil")
    
    XCTAssertTrue(obj!.a1.value != nil, "obj.a1.value should not be nil")
    XCTAssertTrue(obj!.a1.value == 5, "obj.a1.value should == 5")
    
    XCTAssertTrue(obj!.a2 != nil, "obj.a2 should not be nil")
    XCTAssertTrue(obj!.a2.value != nil, "obj.a2.value should not be nil")
    XCTAssertTrue(obj!.a2.value == 5, "obj.a2.value should == 5")
    
    XCTAssertTrue(obj!.a3 != nil, "obj.a3 should not be nil")
    XCTAssertTrue(obj!.a3!.value != nil, "obj.a3.value should not be nil")
    XCTAssertTrue(obj!.a3!.value! == 5, "obj.a3.value should == 5")
    
    XCTAssertTrue(obj!.b1 != nil, "obj.b1 should not be nil")
    XCTAssertTrue(obj!.b1!.value != nil, "obj.b1.value should not be nil")
    XCTAssertTrue(obj!.b1!.value! == 5, "obj.b1.value should == 5")
    
    obj = try? Rosetta().decode(
      dataFrom(
        ["a1": ["value": 4],
          "a2": ["value": 5],
          "a3": ["value": 5],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj == nil, "obj should not be nil")
    
    obj = try? Rosetta().decode(
      dataFrom(
        ["a1": ["value": 5],
          "a2": ["value": 4],
          "a3": ["value": 5],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj == nil, "obj should not be nil")
    
    obj = try? Rosetta().decode(
      dataFrom(
        ["a1": ["value": 5],
          "a2": ["value": 5],
          "a3": ["value": 4],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj == nil, "obj should not be nil")
    
    obj = try? Rosetta().decode(
      dataFrom(
        ["a1": ["value": 5],
          "a2": ["value": 5],
          "a3": ["value": 5],
          "b1": ["value": 4]]
      )
    )
    XCTAssertTrue(obj != nil, "obj should not be nil")
    
    XCTAssertTrue(obj!.a1.value != nil, "obj.a1.value should not be nil")
    XCTAssertTrue(obj!.a1.value == 5, "obj.a1.value should == 5")
    
    XCTAssertTrue(obj!.a2 != nil, "obj.a2 should not be nil")
    XCTAssertTrue(obj!.a2.value != nil, "obj.a2.value should not be nil")
    XCTAssertTrue(obj!.a2.value == 5, "obj.a2.value should == 5")
    
    XCTAssertTrue(obj!.a3 != nil, "obj.a3 should not be nil")
    XCTAssertTrue(obj!.a3!.value != nil, "obj.a3.value should not be nil")
    XCTAssertTrue(obj!.a3!.value! == 5, "obj.a3.value should == 5")
    
    XCTAssertTrue(obj!.b1 == nil, "obj.b1 should not be nil")
    
    obj = Object8()
    obj!.a1 = SubObject1(value: 5)
    obj!.a2 = SubObject1(value: 5)
    obj!.a3 = SubObject1(value: 5)
    obj!.b1 = SubObject1(value: 5)
    var data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data != nil, "data should not be nil")
    XCTAssertTrue(jsonFrom(data!).isEqual(
      ["a1": ["value": 5],
        "a2": ["value": 5],
        "a3": ["value": 5],
        "b1": ["value": 5]]), "wrong encoding result")
    
    obj = Object8()
    obj!.a1 = SubObject1(value: 4)
    obj!.a2 = SubObject1(value: 5)
    obj!.a3 = SubObject1(value: 5)
    obj!.b1 = SubObject1(value: 5)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = Object8()
    obj!.a1 = SubObject1(value: 5)
    obj!.a2 = SubObject1(value: 4)
    obj!.a3 = SubObject1(value: 5)
    obj!.b1 = SubObject1(value: 5)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = Object8()
    obj!.a1 = SubObject1(value: 5)
    obj!.a2 = SubObject1(value: 5)
    obj!.a3 = SubObject1(value: 4)
    obj!.b1 = SubObject1(value: 5)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = Object8()
    obj!.a1 = SubObject1(value: 5)
    obj!.a2 = SubObject1(value: 5)
    obj!.a3 = SubObject1(value: 5)
    obj!.b1 = SubObject1(value: 4)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data != nil, "data should not be nil")
    XCTAssertTrue(jsonFrom(data!).isEqual(
      ["a1": ["value": 5],
        "a2": ["value": 5],
        "a3": ["value": 5]]), "wrong encoding result")
  }
  
  //MARK: syntax tests (only to test if the code compiles)
  
  func testTrailingClosure()
  {
    let data = Data()
    let string = ""

    struct ValueType: Creatable {
      
    }
    
    var valueTypeObject = ValueType()
    
    _ = try? Rosetta().decode(data, to: &valueTypeObject) { (o: inout ValueType, j) -> () in
      
    }
    _ = try? Rosetta().decode(data) { (o: inout ValueType, j) -> () in
      
    } as ValueType
    _ = try? Rosetta().decode(string, to: &valueTypeObject) { (o: inout ValueType, j) -> () in
      
    }
    _ = try? Rosetta().decode(string) { (o: inout ValueType, j) -> () in
      
    } as ValueType

		_ = try? Rosetta().encode(valueTypeObject) { (o: inout ValueType, j) -> () in
      
    } as Data
    _ = try? Rosetta().encode(valueTypeObject) { (o: inout ValueType, json) -> () in
      
    } as String
  }
  
  //MARK: validators
  
  func testValidation() {
    var s1: Structure3? = try? Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a2",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 != nil, "s1.a3 should exist")
    
    XCTAssertEqual(s1!.a1, "a1")
    XCTAssertEqual(s1!.a2, "a2")
    XCTAssertEqual(s1!.a3!, "a3")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a2",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a2",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 == nil, "s1.a3 should not exist")
    
    XCTAssertEqual(s1!.a1, "a1")
    XCTAssertEqual(s1!.a2, "a2")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a2",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
  }
  
  func testValidationWithCustomBridge() {
    var s1: Structure4? = try? Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "http://www.google.com",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 != nil, "s1.a3 should exist")
    
    XCTAssertEqual(s1!.a1.absoluteString, "http://www.google.com")
    XCTAssertEqual(s1!.a2.absoluteString, "http://www.google.com")
    XCTAssertEqual(s1!.a3!.absoluteString, "http://www.google.com")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "http://www.google.com",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "a",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "http://www.google.com",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 == nil, "s1.a3 should not exist")
    
    XCTAssertEqual(s1!.a1.absoluteString, "http://www.google.com")
    XCTAssertEqual(s1!.a2.absoluteString, "http://www.google.com")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "http://www.google.com",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = try? Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
  }
  
  func testArrayOfJSONConvertible() {
    let data = dataFrom(
      ["users1": [
        ["name": "Bob"],
        ["name": "Jony"]
        ],
        "users2": [
          ["name": "Tim"]
        ],
        "users3": [
          ["name": "Steve"],
          ["name": "Eddy"],
          ["name": "Craig"]
      ]]
    )
    var group: Group1? = try? Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = Group1(
      users1: [User1(name: "Bob"), User1(name: "Jony")],
      users2: [User1(name: "Tim")],
      users3: [User1(name: "Steve"), User1(name: "Eddy"), User1(name: "Craig")]
    )
    let encoded: Data? = try? Rosetta().encode(group!)
    XCTAssertTrue(encoded != nil, "encoded data should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqual(to: jsonFrom(encoded!) as [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testDictionaryOfJSONConvertible() {
    let data = dataFrom(
      ["users1": [
        "H/W Guy": ["name": "Bob"],
        "Design": ["name": "Jony"]
        ],
        "users2": [
          "CEO": ["name": "Tim"]
        ],
        "users3": [
          "Founder": ["name": "Steve"],
          "Ferrari guy": ["name": "Eddy"],
          "California guy": ["name": "Craig"]
      ]]
    )
    var group: Group2? = try? Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = Group2(
      users1: ["H/W Guy": User2(name: "Bob"), "Design": User2(name: "Jony")],
      users2: ["CEO": User2(name: "Tim")],
      users3: ["Founder": User2(name: "Steve"), "Ferrari guy": User2(name: "Eddy"), "California guy": User2(name: "Craig")]
    )
    let encoded: Data? = try? Rosetta().encode(group!)
    XCTAssertTrue(encoded != nil, "encoded data should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqual(to: jsonFrom(encoded!) as [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }

	//MARK: JSON with array at root

	func testFailingDecodingIfRootIsArrayAndExpectedDictionary() {
		let data = dataFrom(
			["value1", "value2", "value3", "value4"]
		)
		let object: Object? = try? Rosetta().decode(data)
		XCTAssertTrue(object == nil, "decoded object should not exist")
	}

	func testDecodingJSONWithArrayAtRoot() {
		let array = ["value1", "value2", "value3", "value4"]
		let data = dataFrom(array)
		let object = try? Rosetta().decode(data) as [String]
		XCTAssertTrue(object != nil, "decoded object should exist")
		XCTAssertTrue(object.map { $0 == array } ?? false)
	}

	func testEncodingToJSONWithArrayAtRoot() {
		let array = ["value1", "value2", "value3", "value4"]
		let data = dataFrom(array)
		let encoded = try? Rosetta().encode(array) as Data
		XCTAssertTrue(encoded != nil, "decoded object should exist")
		XCTAssertTrue(encoded.map { $0 == data } ?? false)
	}
}
