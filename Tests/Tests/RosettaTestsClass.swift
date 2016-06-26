import Foundation
import XCTest
import Rosetta

func XCTAssertThrows(_ block: () throws -> ()) {
	do {
		try block()
		XCTFail("No error thrown")
	}
	catch {
		
	}
}

func XCTAssertNoThrow(_ block: () throws -> ()) {
	do {
		try block()
	}
	catch {
		XCTFail("Error thrown")
	}
}

func ==(lhs: SubObjectClass, rhs: SubObjectClass) -> Bool {
  return lhs.a1 == rhs.a1
}

class SubObjectClass: JSONConvertibleClass, Equatable {
  var a1: String = "x"
  required init () {
    
  }
  class func map(_ object: SubObjectClass, json: Rosetta) {
    object.a1 <- json["a1-key"]
  }
}

class ObjectClass: JSONConvertibleClass {
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
  
  var g1: SubObjectClass  = SubObjectClass()
  var g2: SubObjectClass! = SubObjectClass()
  var g3: SubObjectClass? = SubObjectClass()
  
  var h1: [URL]  = [URL(string: "http://www.google.pl")!]
  var h2: [URL]! = [URL(string: "http://www.google.pl")!]
  var h3: [URL]? = [URL(string: "http://www.google.pl")!]
  
  var i1: [String: URL]  = ["x": URL(string: "http://www.google.pl")!]
  var i2: [String: URL]! = ["x": URL(string: "http://www.google.pl")!]
  var i3: [String: URL]? = ["x": URL(string: "http://www.google.pl")!]
  
  required init() {
    
  }
  
  class func map(_ object: ObjectClass, json: Rosetta) {
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

class TestType1: JSONConvertibleClass {
    var name: String

    required init() {
        name = "John"
    }

    class func map(_ object: TestType1, json: Rosetta) {
        object.name <- json["name"]
    }
}

class TestType2: JSONConvertibleClass {
    var name: String!

    required init() {

    }

    class func map(_ object: TestType2, json: Rosetta) {
        object.name <- json["name"]
    }
}

class TestType3: JSONConvertibleClass {
    var name: String?

    required init() {

    }

    class func map(_ object: TestType3, json: Rosetta) {
        object.name <~ json["name"]
    }
}

class TestType4: JSONConvertibleClass {
    var name: String

    required init() {
        name = "John"
    }

    class func map(_ object: TestType4, json: Rosetta) {
        object.name <- json["name"]
    }
}

class TestType5: JSONConvertibleClass {
    var name: String

    required init() {
        name = "John"
    }

    class func map(_ object: TestType5, json: Rosetta) {
        object.name <- json["name"]
    }
}

class TestType6: JSONConvertibleClass {
    var a1: String = "x"

    required init() {

    }

    class func map(_ object: TestType6, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
    }
}

class TestType7: JSONConvertibleClass {
    var a1: String? = "x"

    required init() {

    }

    class func map(_ object: TestType7, json: Rosetta) {
        object.a1 <~ json["a1"] § {$0 == "a1"}
    }
}

class TestType8: JSONConvertibleClass {
    var name: String

    required init() {
        name = "John"
    }

    class func map(_ object: TestType8, json: Rosetta) {
        object.name <- json["result"]["name"]
    }
}

class TestType9: JSONConvertibleClass {
    var name: String

    required init() {
        name = "John"
    }

    class func map(_ object: TestType9, json: Rosetta) {
        object.name <- json["result"]["name"]
    }
}

class TestType10: JSONConvertibleClass {
    var a1: String?

    required init() {

    }

    class func map(_ object: TestType10, json: Rosetta) {
        object.a1 <- json["a1"]
    }
}

class TestType11: JSONConvertibleClass {
    var value: Int!
    required init() {

    }

    init(value: Int) {
        self.value = value
    }

    static func map(_ object: TestType11, json: Rosetta) {
        object.value <- json["value"]
    }
}

class TestType12: JSONConvertibleClass {
    var a1: TestType11 = TestType11()
    var a2: TestType11!
    var a3: TestType11?
    var b1: TestType11?

    required init() {

    }

    static func map(_ object: TestType12, json: Rosetta) {
        object.a1 <- json["a1"] § {$0.value == 5}
        object.a2 <- json["a2"] § {$0.value == 5}
        object.a3 <- json["a3"] § {$0.value == 5}
        object.b1 <~ json["b1"] § {$0.value == 5}
    }
}

class TestType13: JSONConvertibleClass {
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

    required init() {

    }

    class func map(_ object: TestType13, json: Rosetta) {
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

class TestType14: JSONConvertibleClass {
    var a1: String  = "x"
    var a2: String!
    var a3: String?

    required init() {

    }

    class func map(_ object: TestType14, json: Rosetta) {
        object.a1 <- json["a1"] § {$0 == "a1"}
        object.a2 <- json["a2"] § {$0 == "a2"}
        object.a3 <~ json["a3"] § {$0 == "a3"}
    }
}

class TestType15: JSONConvertibleClass {
    var a1: URL  = URL(string: "http://www.wp.pl")!
    var a2: URL!
    var a3: URL?

    required init() {

    }

    class func map(_ object: TestType15, json: Rosetta) {
        object.a1 <- json["a1"] ~ NSURLBridge § {$0.absoluteString == "http://www.google.com"}
        object.a2 <- json["a2"] ~ NSURLBridge § {$0.absoluteString == "http://www.google.com"}
        object.a3 <~ json["a3"] ~ NSURLBridge § {$0.absoluteString == "http://www.google.com"}
    }
}

class TestType16: JSONConvertibleClass {
    var name: String?

    required init() {

    }

    init(name: String) {
        self.name = name
    }

    class func map(_ object: TestType16, json: Rosetta) {
        object.name <- json["name"]
    }
}

class TestType17: JSONConvertibleClass {
    var users1: [TestType16] = []
    var users2: [TestType16]!
    var users3: [TestType16]?

    required init() {

    }

    init(users1: [TestType16], users2: [TestType16], users3: [TestType16]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
    }

    class func map(_ object: TestType17, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
    }
}

class TestType18: JSONConvertibleClass {
    var name: String?

    required init() {

    }

    init(name: String) {
        self.name = name
    }

    class func map(_ object: TestType18, json: Rosetta) {
        object.name <- json["name"]
    }
}

class TestType19: JSONConvertibleClass {
    var users1: [String: TestType18] = [:]
    var users2: [String: TestType18]!
    var users3: [String: TestType18]?

    required init() {

    }

    init(users1: [String: TestType18], users2: [String: TestType18], users3: [String: TestType18]) {
        self.users1 = users1
        self.users2 = users2
        self.users3 = users3
    }

    class func map(_ object: TestType19, json: Rosetta) {
        object.users1 <- json["users1"]
        object.users2 <- json["users2"]
        object.users3 <- json["users3"]
    }
}



class RosettaClassTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSimpleDecoder() {
    let object = try? Rosetta().decode(dataFrom(["name": "Bob"])) as TestType1
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithUnwrappedOptional() {
    let object = try? Rosetta().decode(dataFrom(["name": "Bob"])) as TestType2
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testSimpleDecoderWithOptional() {
    let object = try? Rosetta().decode(dataFrom(Dictionary<String, AnyObject>())) as TestType3
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.name == nil, "object.name should remain unmodified")
  }
  
  func testComplexDecoder() {
    let dictionary = complexJSON()
    let object = try? Rosetta().decode(dictionary) as ObjectClass
    
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
    
    let subObjectClass = SubObjectClass(); subObjectClass.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObjectClass)
    XCTAssertEqual(object!.g2, subObjectClass)
    XCTAssertEqual(object!.g3!, subObjectClass)
  }
  
  func testComplexEncoder() {
    let data = complexJSON()
    let decoded = try? Rosetta().decode(data) as ObjectClass
    XCTAssertTrue(decoded != nil, "decoded object should exist")
    let encoded = try? Rosetta().encode(decoded!) as Data
    XCTAssertTrue(encoded != nil, "encoded object should exist")
    XCTAssertTrue(
      jsonFrom(data).isEqual(jsonFrom(encoded!) as [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingDecoder() {
    let object = try? Rosetta().decode(dataFrom(["name": 11])) as TestType4
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingDecoderWithError() {
    
    let object = try? Rosetta().decode(dataFrom(["name": 11])) as TestType5
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testValidatedEncoder() {
    let structure = TestType6()
    let json = try? Rosetta().encode(structure) as Data
    XCTAssertTrue(json == nil, "json should not exist")
  }
  
  func testValidatedEncoder1() {
    let structure = TestType7()
    let json = try? Rosetta().encode(structure) as Data
    XCTAssertTrue(json != nil, "json should exist")
    XCTAssertTrue(jsonFrom(json!)["a1"] == nil, "json[\"a1\"] should not exist")
  }
  
  func testKeyPathsDecoder() {
    let object = try? Rosetta().decode(dataFrom(["result": ["name": "Bob"]])) as TestType8
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testKeyPathsEncoder() {
    let object = try? Rosetta().decode(dataFrom(["result": ["name": "Bob"]])) as TestType9
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertEqual(object!.name, "Bob")
  }
  
  func testRequiredOptionalType() {
    let object = try? Rosetta().decode(dataFrom(["a2": "a2"])) as TestType10
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCustomMap() {
    class ObjectClass {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    var object = ObjectClass()
		XCTAssertNoThrow {
			try Rosetta().decode(jsonData, to: &object) { object, json in
				object.a1 <- json["a1"]
			}
		}
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCustomMapFailing() {
    class ObjectClass {
      var a1: String?
      
      init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    var object = ObjectClass()
    object.a1 = "a1-value"

		XCTAssertThrows {
			try Rosetta().decode(jsonData, to: &object, usingMap: { (object, json) -> () in
				object.a1 <- json["a1"]
			})
		}
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1-value")
  }
  
  func testCreatableWithCustomMap() {
    class ObjectClass: Creatable {
      var a1: String?
      
      required init() {
        
      }
    }
    let jsonData = dataFrom(["a1": "a1-value"])
    let object = try? Rosetta().decode(jsonData, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object!.a1!, "a1-value")
  }
  
  func testCreatableWithCustomMapFailing() {
    class ObjectClass: Creatable {
      var a1: String?
      
      required init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    let object = try? Rosetta().decode(jsonData, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <- json["a1"]
    })
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testCreatableWithCustomMapOptionalIgnored() {
    class ObjectClass: Creatable {
      var a1: String?
      
      required init() {
        
      }
    }
    let jsonData = dataFrom(["a2": "garbage"])
    let object = try? Rosetta().decode(jsonData, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <~ json["a1"]
    })
    XCTAssertTrue(object != nil, "object should exist")
    XCTAssertTrue(object!.a1 == nil, "object.a1 should not exist")
  }
  
  func testDroppingAllChangesIfDecodingFails()
  {
    class Object {
      var a: String
      var b: String
      
      init(a: String, b: String) {
        self.a = a
        self.b = b
      }
    }
    
    let data = dataFrom(["a" : "1"])
    var object = Object(a: "0", b: "0")

		XCTAssertThrows {
			try Rosetta().decode(data, to: &object) { (o: Object, j) -> () in
				o.a <- j["a"]
				o.b <- j["b"]
			}
		}

    XCTAssertTrue(object.a == "0", "object.a should be equal to \"0\"")
    XCTAssertTrue(object.b == "0", "object.b should be equal to \"0\"")
  }
  
  //MARK: Key Path tests
  
  class KeyPathObject: JSONConvertibleClass {
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
    
    var g1: SubObjectClass  = SubObjectClass()
    var g2: SubObjectClass! = SubObjectClass()
    var g3: SubObjectClass? = SubObjectClass()
    
    var h1: [URL]  = [URL(string: "http://www.google.pl")!]
    var h2: [URL]! = [URL(string: "http://www.google.pl")!]
    var h3: [URL]? = [URL(string: "http://www.google.pl")!]
    
    var i1: [String: URL]  = ["x": URL(string: "http://www.google.pl")!]
    var i2: [String: URL]! = ["x": URL(string: "http://www.google.pl")!]
    var i3: [String: URL]? = ["x": URL(string: "http://www.google.pl")!]
    
    required init() {
      
    }
    
    class func map(_ object: KeyPathObject, json: Rosetta) {
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
    let bundle = Bundle(for: RosettaClassTests.classForCoder())
    let url = bundle.urlForResource("complex keyPath JSON", withExtension: "json")
    return (try! Data(contentsOf: url!))
  }
  
  func testComplexKeyPathDecoder() {
    let jsonData = complexKeyPathJSON()
    let object = try? Rosetta().decode(jsonData) as KeyPathObject
    
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
    
    let subObjectClass = SubObjectClass(); subObjectClass.a1 = "a1-value"
    XCTAssertEqual(object!.g1, subObjectClass)
    XCTAssertEqual(object!.g2, subObjectClass)
    XCTAssertEqual(object!.g3!, subObjectClass)
  }
  
  func testComplexKeyPathEncoder() {
    let jsonData = complexKeyPathJSON()
    let decoded = try? Rosetta().decode(jsonData) as KeyPathObject
    XCTAssertTrue(decoded != nil, "decoded should not be nil")
    let encoded = try? Rosetta().encode(decoded!) as Data
    XCTAssertTrue(encoded != nil, "encoded should not be nil")
    XCTAssertTrue(
      jsonFrom(jsonData).isEqual(jsonFrom(encoded!) as [NSObject : AnyObject]),
      "encoded dictionary does not match the original dictionary"
    )
  }
  
  func testFailingComplexKeyPathDecoder() {
    let dictionary = complexJSON()
    let object = try? Rosetta().decode(dictionary) as KeyPathObject
    
    
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testFailingComplexKeyPathDecoder2() {
    let dictionary = complexKeyPathJSON()
    let object = try? Rosetta().decode(dictionary) as ObjectClass
    
    XCTAssertTrue(object == nil, "object should not exist")
  }
  
  func testDecodingWithCustomMap() {
    class ObjectClass {
      var a1: String?
      init () {
        
      }
    }
    
    var object = ObjectClass()
    _ = try? Rosetta().decode(dataFrom(["a1": "a1"]), to: &object, usingMap: { (object: ObjectClass, json) -> () in
      object.a1 <- json["a1"]
    })
    
    XCTAssertTrue(object.a1 != nil, "object.a1 should exist")
    XCTAssertEqual(object.a1!, "a1")
  }
  
  func testImplicitBridgeWithValidator() {
    var obj: TestType12?
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
    
    obj = TestType12()
    obj!.a1 = TestType11(value: 5)
    obj!.a2 = TestType11(value: 5)
    obj!.a3 = TestType11(value: 5)
    obj!.b1 = TestType11(value: 5)
    var data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data != nil, "data should not be nil")
    XCTAssertTrue(jsonFrom(data!).isEqual(
      ["a1": ["value": 5],
        "a2": ["value": 5],
        "a3": ["value": 5],
        "b1": ["value": 5]]), "wrong encoding result")
    
    obj = TestType12()
    obj!.a1 = TestType11(value: 4)
    obj!.a2 = TestType11(value: 5)
    obj!.a3 = TestType11(value: 5)
    obj!.b1 = TestType11(value: 5)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = TestType12()
    obj!.a1 = TestType11(value: 5)
    obj!.a2 = TestType11(value: 4)
    obj!.a3 = TestType11(value: 5)
    obj!.b1 = TestType11(value: 5)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = TestType12()
    obj!.a1 = TestType11(value: 5)
    obj!.a2 = TestType11(value: 5)
    obj!.a3 = TestType11(value: 4)
    obj!.b1 = TestType11(value: 5)
    data = try? Rosetta().encode(obj!) as Data
    XCTAssertTrue(data == nil, "data should be nil")
    
    obj = TestType12()
    obj!.a1 = TestType11(value: 5)
    obj!.a2 = TestType11(value: 5)
    obj!.a3 = TestType11(value: 5)
    obj!.b1 = TestType11(value: 4)
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
    
    class ClassType: Creatable {
      required init() {
        
      }
    }
    
    var classTypeObject = ClassType()
    
    _ = try? Rosetta().decode(data, to: &classTypeObject) { (o: ClassType, j) -> () in
      
    }
    _ = try? Rosetta().decode(data) { (o: ClassType, j) -> () in
      
    }
    _ = try? Rosetta().decode(string, to: &classTypeObject) { (o: ClassType, j) -> () in
      
    }
    _ = try? Rosetta().decode(string) { (o: ClassType, j) -> () in
      
    }

    _ = try? Rosetta().encode(classTypeObject) { (o: ClassType, j) -> () in
      
    } as Data
    _ = try? Rosetta().encode(classTypeObject) { (o: ClassType, json) -> () in
      
    } as String
  }
  
  //MARK: validators
  
  func testValidation() {
    var s1: TestType14? = try? Rosetta().decode(
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
    var s1: TestType15? = try? Rosetta().decode(
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
  
  func testArrayOfJSONConvertibleClass() {
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
    var group: TestType17? = try? Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = TestType17(
      users1: [TestType16(name: "Bob"), TestType16(name: "Jony")],
      users2: [TestType16(name: "Tim")],
      users3: [TestType16(name: "Steve"), TestType16(name: "Eddy"), TestType16(name: "Craig")]
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
    var group: TestType19? = try? Rosetta().decode(data)
    XCTAssertTrue(group != nil, "group should exist")
    XCTAssertTrue(group!.users2 != nil, "group.users2 should exist")
    XCTAssertTrue(group!.users3 != nil, "group.users3 should exist")
    XCTAssertTrue(group!.users1.count == 2, "group.users should have 2 items")
    XCTAssertTrue(group!.users2.count == 1, "group.users should have 2 items")
    XCTAssertTrue(group!.users3!.count == 3, "group.users should have 2 items")
    
    // encoding
    
    group = TestType19(
      users1: ["H/W Guy": TestType18(name: "Bob"), "Design": TestType18(name: "Jony")],
      users2: ["CEO": TestType18(name: "Tim")],
      users3: ["Founder": TestType18(name: "Steve"), "Ferrari guy": TestType18(name: "Eddy"), "California guy": TestType18(name: "Craig")]
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
		let object: ObjectClass? = try? Rosetta().decode(data)
		XCTAssertTrue(object == nil, "decoded object should not exist")
	}
}
