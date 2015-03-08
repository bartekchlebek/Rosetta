import Foundation
import XCTest
import Rosetta

func jsonFrom(data: NSData) -> NSDictionary {
  return NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
}

func dataFrom(json: [String: AnyObject]) -> NSData {
  return NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil)!
}

func ==(lhs: SubObject, rhs: SubObject) -> Bool {
  return lhs.a1 == rhs.a1
}

struct SubObject: JSONConvertible, Equatable {
  var a1: String = "x"
  init () {
    
  }
  static func map(inout object: SubObject, json: Rosetta) {
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
  
  var f1: NSURL  = NSURL(string: "http://www.google.pl")!
  var f2: NSURL! = NSURL(string: "http://www.google.pl")!
  var f3: NSURL? = NSURL(string: "http://www.google.pl")!
  
  var g1: SubObject  = SubObject()
  var g2: SubObject! = SubObject()
  var g3: SubObject? = SubObject()
  
  var h1: [NSURL]  = [NSURL(string: "http://www.google.pl")!]
  var h2: [NSURL]! = [NSURL(string: "http://www.google.pl")!]
  var h3: [NSURL]? = [NSURL(string: "http://www.google.pl")!]
  
  var i1: [String: NSURL]  = ["x": NSURL(string: "http://www.google.pl")!]
  var i2: [String: NSURL]! = ["x": NSURL(string: "http://www.google.pl")!]
  var i3: [String: NSURL]? = ["x": NSURL(string: "http://www.google.pl")!]
  
  init() {
    
  }
  
  static func map(inout object: Object, json: Rosetta) {
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
    
    object.f1 <- json["f1-key"] ~ NSURLBridge()
    object.f2 <- json["f2-key"] ~ NSURLBridge()
    object.f3 <~ json["f3-key"] ~ NSURLBridge()
    
    object.g1 <- json["g1-key"]
    object.g2 <- json["g2-key"]
    object.g3 <~ json["g3-key"]
    
    object.h1 <- json["h1-key"] ~ BridgeArray(NSURLBridge())
    object.h2 <- json["h2-key"] ~ BridgeArray(NSURLBridge())
    object.h3 <~ json["h3-key"] ~ BridgeArray(NSURLBridge())
    
    object.i1 <- json["i1-key"] ~ BridgeObject(NSURLBridge())
    object.i2 <- json["i2-key"] ~ BridgeObject(NSURLBridge())
    object.i3 <~ json["i3-key"] ~ BridgeObject(NSURLBridge())
  }
}

func complexJSON() -> NSData {
  let bundle = NSBundle(forClass: RosettaTests.classForCoder())
  let url = bundle.URLForResource("complex JSON", withExtension: "json")
  return NSData(contentsOfURL: url!)!
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
    struct Object: JSONConvertible {
      var name: String
      
      init() {
        name = "John"
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["name": "Bob"]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithUnwrappedOptional() {
    struct Object: JSONConvertible {
      var name: String!
      
      init() {
        
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["name": "Bob"]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithOptional() {
    struct Object: JSONConvertible {
      var name: String?
      
      init() {
        
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <~ json["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(Dictionary<String, AnyObject>()))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.name == nil, "object.name should remain unmodified")
  }
  
  func testComplexDecoder() {
    let dictionary = complexJSON()
    let object: Object? = Rosetta().decode(dictionary)
    
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
    
    XCTAssertEqual(object!.f1, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f2, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f3!, NSURL(string: "http://www.wp.pl")!)
    
    var subObject = SubObject(); subObject.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObject)
    XCTAssertEqual(object!.g2, subObject)
    XCTAssertEqual(object!.g3!, subObject)
  }
  
  func testComplexEncoder() {
    let data = complexJSON()
    let decoded: Object? = Rosetta().decode(data)
    XCTAssertTrue(decoded != nil, "decoded object should exist")
    let encoded: NSData? = Rosetta().encode(decoded!)
    XCTAssertTrue(encoded != nil, "encoded object should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingDecoder() {
    struct Object: JSONConvertible {
      var name: String
      
      init() {
        name = "John"
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["name": 11]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingDecoderWithError() {
    struct Object: JSONConvertible {
      var name: String
      
      init() {
        name = "John"
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["name": 11]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testValidatedEncoder() {
    struct Structure: JSONConvertible {
      var a1: String = "x"
      
      init() {
        
      }
      
      private static func map(inout object: Structure, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
      }
    }
    
    let structure = Structure()
    let json: NSData? = Rosetta().encode(structure)
    XCTAssertTrue(json == nil, "json should not exist")
  }
  
  func testValidatedEncoder1() {
    struct Structure: JSONConvertible {
      var a1: String? = "x"
      
      init() {
        
      }
      
      private static func map(inout object: Structure, json: Rosetta) {
        object.a1 <~ json["a1"] § {$0 == "a1"}
      }
    }
    
    let structure = Structure()
    let json: NSData? = Rosetta().encode(structure)
    XCTAssertTrue(json != nil, "json should exist")
    XCTAssertTrue(jsonFrom(json!)["a1"] == nil, "json[\"a1\"] should not exist")
  }
  
  func testKeyPathsDecoder() {
    struct Object: JSONConvertible {
      var name: String
      
      init() {
        name = "John"
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <- json["result"]["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["result": ["name": "Bob"]]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testKeyPathsEncoder() {
    struct Object: JSONConvertible {
      var name: String
      
      init() {
        name = "John"
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.name <- json["result"]["name"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["result": ["name": "Bob"]]))
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testRequiredOptionalType() {
    struct Object: JSONConvertible {
      var a1: String?
      
      init() {
        
      }
      
      private static func map(inout object: Object, json: Rosetta) {
        object.a1 <- json["a1"]
      }
    }
    
    let object: Object? = Rosetta().decode(dataFrom(["a2": "a2"]))
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCustomMap() {
    struct Object {
      var a1: String?
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    var object = Object(a1: nil)
    let result = Rosetta().decode(jsonData, to: &object, usingMap: { (inout object: Object, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(result == true, "result should be 'true'")
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCustomMapFailing() {
    struct Object {
      var a1: String?
    }
    let jsonData = dataFrom(["a2": "garbage"])
    var object = Object(a1: "a1-value")
    let result = Rosetta().decode(jsonData, to: &object, usingMap: { (inout object: Object, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(result == false, "result should be 'false'")
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
    let object = Rosetta().decode(jsonData, usingMap: { (inout object: Object, json) -> () in
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
    let object = Rosetta().decode(jsonData, usingMap: { (inout object: Object, json) -> () in
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
    let object = Rosetta().decode(jsonData, usingMap: { (inout object: Object, json) -> () in
      object.a1 <~ json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 == nil, "object.a1 should not exist")
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
    
    var f1: NSURL  = NSURL(string: "http://www.google.pl")!
    var f2: NSURL! = NSURL(string: "http://www.google.pl")!
    var f3: NSURL? = NSURL(string: "http://www.google.pl")!
    
    var g1: SubObject  = SubObject()
    var g2: SubObject! = SubObject()
    var g3: SubObject? = SubObject()
    
    var h1: [NSURL]  = [NSURL(string: "http://www.google.pl")!]
    var h2: [NSURL]! = [NSURL(string: "http://www.google.pl")!]
    var h3: [NSURL]? = [NSURL(string: "http://www.google.pl")!]
    
    var i1: [String: NSURL]  = ["x": NSURL(string: "http://www.google.pl")!]
    var i2: [String: NSURL]! = ["x": NSURL(string: "http://www.google.pl")!]
    var i3: [String: NSURL]? = ["x": NSURL(string: "http://www.google.pl")!]
    
    init() {
      
    }
    
    static func map(inout object: KeyPathObject, json: Rosetta) {
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
      
      object.f1 <- json["result"]["object"]["f1-key"] ~ NSURLBridge()
      object.f2 <- json["result"]["object"]["f2-key"] ~ NSURLBridge()
      object.f3 <- json["result"]["object"]["f3-key"] ~ NSURLBridge()
      
      object.g1 <- json["result"]["object"]["g1-key"]
      object.g2 <- json["result"]["object"]["g2-key"]
      object.g3 <- json["result"]["object"]["g3-key"]
      
      object.h1 <- json["result"]["object"]["h1-key"] ~ BridgeArray(NSURLBridge())
      object.h2 <- json["result"]["object"]["h2-key"] ~ BridgeArray(NSURLBridge())
      object.h3 <- json["result"]["object"]["h3-key"] ~ BridgeArray(NSURLBridge())
      
      object.i1 <- json["result"]["object"]["i1-key"] ~ BridgeObject(NSURLBridge())
      object.i2 <- json["result"]["object"]["i2-key"] ~ BridgeObject(NSURLBridge())
      object.i3 <- json["result"]["object"]["i3-key"] ~ BridgeObject(NSURLBridge())
    }
  }
  
  func complexKeyPathJSON() -> NSData {
    let bundle = NSBundle(forClass: RosettaTests.classForCoder())
    let url = bundle.URLForResource("complex keyPath JSON", withExtension: "json")
    return NSData(contentsOfURL: url!)!
  }
  
  func testComplexKeyPathDecoder() {
    let jsonData = complexKeyPathJSON()
    let object: KeyPathObject? = Rosetta().decode(jsonData)
    
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
    
    XCTAssertEqual(object!.f1, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f2, NSURL(string: "http://www.wp.pl")!)
    XCTAssertEqual(object!.f3!, NSURL(string: "http://www.wp.pl")!)
    
    var subObject = SubObject(); subObject.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObject)
    XCTAssertEqual(object!.g2, subObject)
    XCTAssertEqual(object!.g3!, subObject)
  }
  
  func testComplexKeyPathEncoder() {
    let jsonData = complexKeyPathJSON()
    let decoded: KeyPathObject? = Rosetta().decode(jsonData)
    XCTAssertTrue(decoded != nil, "decoded should not be nil")
    let encoded: NSData? = Rosetta().encode(decoded!)
    XCTAssertTrue(encoded != nil, "encoded should not be nil")
    XCTAssertTrue(
      jsonFrom(jsonData).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingComplexKeyPathDecoder() {
    let dictionary = complexJSON()
    let object: KeyPathObject? = Rosetta().decode(dictionary)
    
    
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingComplexKeyPathDecoder2() {
    let dictionary = complexKeyPathJSON()
    let object: Object? = Rosetta().decode(dictionary)
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testDecodingWithCustomMap() {
    struct Object {
      var a1: String?
      init () {
        
      }
    }
    
    var object = Object()
    Rosetta().decode(dataFrom(["a1": "a1"]), to: &object, usingMap: { (inout object: Object, json) -> () in
      object.a1 <- json["a1"]
    })
    
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1")
  }
  
  func testImplicitBridgeWithValidator() {
    struct SubObject: JSONConvertible {
      var value: Int!
      init() {
        
      }
      
      init(value: Int) {
        self.value = value
      }
      
      static func map(inout object: SubObject, json: Rosetta) {
        object.value <- json["value"]
      }
    }
    
    struct Object: JSONConvertible {
      var a1: SubObject = SubObject()
      var a2: SubObject!
      var a3: SubObject?
      var b1: SubObject?
      
      init() {
        
      }
      
      static func map(inout object: Object, json: Rosetta) {
        object.a1 <- json["a1"] § {$0.value == 5}
        object.a2 <- json["a2"] § {$0.value == 5}
        object.a3 <- json["a3"] § {$0.value == 5}
        object.b1 <~ json["b1"] § {$0.value == 5}
      }
    }
    
    var obj: Object?
    obj = Rosetta().decode(
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
    
    obj = Rosetta().decode(
      dataFrom(
        ["a1": ["value": 4],
          "a2": ["value": 5],
          "a3": ["value": 5],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj == nil, "obj should not be nil")
    
    obj = Rosetta().decode(
      dataFrom(
        ["a1": ["value": 5],
          "a2": ["value": 4],
          "a3": ["value": 5],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj == nil, "obj should not be nil")
    
    obj = Rosetta().decode(
      dataFrom(
        ["a1": ["value": 5],
          "a2": ["value": 5],
          "a3": ["value": 4],
          "b1": ["value": 5]]
      )
    )
    XCTAssertTrue(obj == nil, "obj should not be nil")
    
    obj = Rosetta().decode(
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
    
    obj = Object()
    obj!.a1 = SubObject(value: 5)
    obj!.a2 = SubObject(value: 5)
    obj!.a3 = SubObject(value: 5)
    obj!.b1 = SubObject(value: 5)
    var data = Rosetta().encode(obj!) as NSData?
    XCTAssertTrue(data != nil, "data should not be nil")
    XCTAssertTrue(jsonFrom(data!).isEqualToDictionary(
      ["a1": ["value": 5],
        "a2": ["value": 5],
        "a3": ["value": 5],
        "b1": ["value": 5]]), "wrong encoding result")
    
    obj = Object()
    obj!.a1 = SubObject(value: 4)
    obj!.a2 = SubObject(value: 5)
    obj!.a3 = SubObject(value: 5)
    obj!.b1 = SubObject(value: 5)
    data = Rosetta().encode(obj!) as NSData?
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = Object()
    obj!.a1 = SubObject(value: 5)
    obj!.a2 = SubObject(value: 4)
    obj!.a3 = SubObject(value: 5)
    obj!.b1 = SubObject(value: 5)
    data = Rosetta().encode(obj!) as NSData?
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = Object()
    obj!.a1 = SubObject(value: 5)
    obj!.a2 = SubObject(value: 5)
    obj!.a3 = SubObject(value: 4)
    obj!.b1 = SubObject(value: 5)
    data = Rosetta().encode(obj!) as NSData?
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = Object()
    obj!.a1 = SubObject(value: 5)
    obj!.a2 = SubObject(value: 5)
    obj!.a3 = SubObject(value: 5)
    obj!.b1 = SubObject(value: 4)
    data = Rosetta().encode(obj!) as NSData?
    XCTAssertTrue(data != nil, "data should not be nil")
    XCTAssertTrue(jsonFrom(data!).isEqualToDictionary(
      ["a1": ["value": 5],
        "a2": ["value": 5],
        "a3": ["value": 5]]), "wrong encoding result")
  }
  
  //MARK: auto-bridged types
  
  func testAutoBridgedTypes() {
    struct Object: JSONConvertible {
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
      
      private static func map(inout object: Object, json: Rosetta) {
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
        
        object.d0 <- json["d0"] ~ NSNumberBridge()
        
        object.e0 <- json["e0"]
        object.e1 <- json["e1"] ~ NSStringBridge()
        object.e2 <- json["e2"] ~ NSMutableStringBridge()
        
        //        object.f0 <- json["f0"] ~ AnyObjectBridge()
        //        object.g0 <- json["g0"] ~ BridgeArray(AnyObjectBridge())
        //        object.h0 <- json["h0"] ~ BridgeObject(AnyObjectBridge())
        //
        //        object.i0 <- json["i0"] ~ TollFreeBridge()
      }
    }
  }
  
  //MARK: syntax tests (only to test if the code compiles)
  
  func testTrailingClosure()
  {
    let data = NSData()
    let string = ""

    struct ValueType: Creatable {
      
    }
    
    var valueTypeObject = ValueType()
    var valueTypeResult: ValueType?
    
    Rosetta().decode(data, to: &valueTypeObject) { (inout o: ValueType, j) -> () in
      
    }
    valueTypeResult = Rosetta().decode(data) { (inout o: ValueType, j) -> () in
      
    }
    Rosetta().decode(string, to: &valueTypeObject) { (inout o: ValueType, j) -> () in
      
    }
    valueTypeResult = Rosetta().decode(string) { (inout o: ValueType, j) -> () in
      
    }
    
    var dataResult: NSData?
    var stringResult: String?
    dataResult = Rosetta().encode(valueTypeObject) { (inout o: ValueType, j) -> () in
      
    }
    stringResult = Rosetta().encode(valueTypeObject) { (inout o: ValueType, json) -> () in
      
    }
  }
  
  //MARK: validators
  
  func testValidation() {
    struct Structure: JSONConvertible {
      var a1: String  = "x"
      var a2: String!
      var a3: String?
      
      init() {
        
      }
      
      private static func map(inout object: Structure, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
        object.a2 <- json["a2"] § {$0 == "a2"}
        object.a3 <~ json["a3"] § {$0 == "a3"}
      }
    }
    
    var s1: Structure? = Rosetta().decode(
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
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a2",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
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
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a3"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a2",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a1",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
  }
  
  func testValidationWithCustomBridge() {
    struct Structure: JSONConvertible {
      var a1: NSURL  = NSURL(string: "http://www.wp.pl")!
      var a2: NSURL!
      var a3: NSURL?
      
      init() {
        
      }
      
      private static func map(inout object: Structure, json: Rosetta) {
        object.a1 <- json["a1"] ~ NSURLBridge() § {$0.absoluteString == "http://www.google.com"}
        object.a2 <- json["a2"] ~ NSURLBridge() § {$0.absoluteString == "http://www.google.com"}
        object.a3 <~ json["a3"] ~ NSURLBridge() § {$0.absoluteString == "http://www.google.com"}
      }
    }
    
    var s1: Structure? = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "http://www.google.com",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 != nil, "s1.a3 should exist")
    
    XCTAssertEqual(s1!.a1.absoluteString!, "http://www.google.com")
    XCTAssertEqual(s1!.a2.absoluteString!, "http://www.google.com")
    XCTAssertEqual(s1!.a3!.absoluteString!, "http://www.google.com")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "http://www.google.com",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "a",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "http://www.google.com",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 != nil, "structure object should exist")
    
    XCTAssertTrue(s1!.a2 != nil, "s1.a2 should exist")
    XCTAssertTrue(s1!.a3 == nil, "s1.a3 should not exist")
    
    XCTAssertEqual(s1!.a1.absoluteString!, "http://www.google.com")
    XCTAssertEqual(s1!.a2.absoluteString!, "http://www.google.com")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "http://www.google.com"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "http://www.google.com",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "http://www.google.com",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
    
    s1 = Rosetta().decode(
      dataFrom(
        ["a1": "a",
          "a2": "a",
          "a3": "a"]
      )
    )
    XCTAssertTrue(s1 == nil, "structure object should not exist")
  }
  
  func testArrayOfJSONConvertible() {
    struct User: JSONConvertible {
      var name: String?
      
      init() {
        
      }
      
      init(name: String) {
        self.name = name
      }
      
      static func map(inout object: User, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    struct Group: JSONConvertible {
      var users1: [User] = []
      var users2: [User]!
      var users3: [User]?
      
      init() {
        
      }
      
      init(users1: [User], users2: [User], users3: [User]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
      }
      
      static func map(inout object: Group, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
      }
    }
    
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
    var group: Group? = Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = Group(
      users1: [User(name: "Bob"), User(name: "Jony")],
      users2: [User(name: "Tim")],
      users3: [User(name: "Steve"), User(name: "Eddy"), User(name: "Craig")]
    )
    let encoded: NSData? = Rosetta().encode(group!)
    XCTAssertTrue(encoded != nil, "encoded data should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testDictionaryOfJSONConvertible() {
    struct User: JSONConvertible {
      var name: String?
      
      init() {
        
      }
      
      init(name: String) {
        self.name = name
      }
      
      static func map(inout object: User, json: Rosetta) {
        object.name <- json["name"]
      }
    }
    
    struct Group: JSONConvertible {
      var users1: [String: User] = [:]
      var users2: [String: User]!
      var users3: [String: User]?
      
      init() {
        
      }
      
      init(users1: [String: User], users2: [String: User], users3: [String: User]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
      }
      
      static func map(inout object: Group, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
      }
    }
    
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
    var group: Group? = Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = Group(
      users1: ["H/W Guy": User(name: "Bob"), "Design": User(name: "Jony")],
      users2: ["CEO": User(name: "Tim")],
      users3: ["Founder": User(name: "Steve"), "Ferrari guy": User(name: "Eddy"), "California guy": User(name: "Craig")]
    )
    let encoded: NSData? = Rosetta().encode(group!)
    XCTAssertTrue(encoded != nil, "encoded data should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqualToDictionary(jsonFrom(encoded!) as! [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testReadme() {
    struct User: JSONConvertible {
      var ID: String?
      var name: String?
      var age: Int?
      var website: NSURL?
      var friends: [User]?
      var family: [String : User]?
      
      init() {
        
      }
      
      static func map(inout object: User, json: Rosetta) {
        object.ID       <- json["uniqueID"] // Map required properties with <-
        object.name     <~ json["name"] // Map optional properties with <~
        object.age      <~ json["age"] § {$0 > 0} // Add validation closure after § operator (age > 0)
        // Types not conforming to Bridgeable protocol (like NSURL here) need to have bridging code after ~ operator
        object.website  <~ json["website_url"] ~ BridgeString(
          decoder: {NSURL(string: $0 as String)}, // convert NSString from json to NSURL
          encoder: {$0.absoluteString} // convert NSURL from Person to NSString for JSON
        )
        object.friends  <~ json["friends"] // Automaticaly mapped arrays
        object.family   <~ json["family"] // Automaticaly mapped dictionaries
      }
    }
  }
  
  func testReadme1() {
    
    struct CustomConvertibleType: JSONConvertible {
      var someValue: Double?
      
      init() {
        
      }
      
      static func map(inout object: CustomConvertibleType, json: Rosetta) {
        object.someValue <- json["value"]
      }
    }
    
    enum CustomBridgeableType: Int, Bridgeable {
      case One = 1, Two, Three, Four
      
      static func bridge() -> Bridge<CustomBridgeableType, NSNumber> {
        return BridgeNumber(
          decoder: {CustomBridgeableType(rawValue: $0.integerValue)},
          encoder: {$0.rawValue}
        )
      }
    }
    
    struct YourCustomType: JSONConvertible {
      var value1: Int?
      var value2: CustomBridgeableType?
      var value3: CustomConvertibleType?
      var value4: NSURL?
      
      var requiredValue1: String = ""
      var requiredValue2: String!
      var requiredValue3: String?
      
      var validatedValue1: String?
      var validatedValue2: CustomBridgeableType?
      var validatedValue3: CustomConvertibleType?
      var validatedValue4: NSURL?
      
      var array1: [Int]?
      var array2: [CustomBridgeableType]?
      var array3: [CustomConvertibleType]?
      var array4: [NSURL]?
      
      var dictionary1: [String : Int]?
      var dictionary2: [String : CustomBridgeableType]?
      var dictionary3: [String : CustomConvertibleType]?
      var dictionary4: [String : NSURL]?
      
      init() {
        
      }
      
      static func map(inout object: YourCustomType, json: Rosetta) {
        object.value1 <~ json["value1"]
        object.value2 <~ json["value2"]
        object.value2 <~ json["value3"]
        object.value4 <~ json["value4"] ~ BridgeString(
          decoder: {NSURL(string: $0 as String)},
          encoder: {$0.absoluteString}
        )
        
        // Bridging placed in a constant just to reuse
        let urlBridge = BridgeString(
          decoder: {NSURL(string: $0 as String)},
          encoder: {$0.absoluteString}
        )
        
        object.requiredValue1 <- json["required1"]
        object.requiredValue2 <- json["required2"]
        object.requiredValue3 <- json["required3"]
        
        object.validatedValue1 <~ json["validated1"] § {$0.hasPrefix("requiredPrefix")}
        object.validatedValue2 <~ json["validated2"] § {$0 == .One || $0 == .Three}
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
  }
}
