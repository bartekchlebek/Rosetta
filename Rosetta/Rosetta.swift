import Foundation

public enum JSON {
  case Data(NSData)
  case String(Swift.String)
  
  var stringValue: Swift.String? {
    switch self {
    case let .Data(data):
      return NSString(data: data, encoding: NSUTF8StringEncoding) as? Swift.String
    case let .String(string):
      return string
    }
  }
  
  var dataValue: NSData? {
    switch self {
    case let .Data(data):
      return data
    case let .String(string):
      return string.toData()
    }
  }
  
  func toDictionary() -> ([Swift.String: AnyObject]?, [Log]?)
  {
    var logs: [Log] = []
    
    let parseData = {(data: NSData) -> ([Swift.String: AnyObject]?) in
      var error = NSErrorPointer()
      if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error)
        as? [Swift.String: AnyObject] {
          return json
      }
      else {
        logs.append(Log.DataToJSON(data: data, error: error.memory))
        return nil
      }
    }
    
    let parseString = {(string: Swift.String) -> ([Swift.String: AnyObject]?) in
      if let data = string.toData() {
        return parseData(data)
      }
      else {
        logs.append(Log.StringToData(string: string))
        return nil
      }
    }
    
    var jsonDictionary: [Swift.String: AnyObject]?
    switch self {
    case let .String(string):
      jsonDictionary = parseString(string)
    case let .Data(data):
      jsonDictionary = parseData(data)
    }
    
    if (jsonDictionary != nil) {
      return (jsonDictionary, nil)
    }
    else {
      return (nil, logs)
    }
  }
}

enum Mode {
  case Decode
  case Encode
}

enum Map<T> {
  case ValueTypeMap((inout T, Rosetta) -> ())
  case ClassTypeMap((T, Rosetta) -> ())
}

public class Rosetta {
  var keyPath: [String] = []
  var testRun: Bool = false
  var currentValue: AnyObject! {
    return valueForKeyPath(keyPath, inDictionary: dictionary)
  }
  var currentMode: Mode!
  var dictionary: [String: AnyObject]!
  var logs: [Log] = []
  
  public var logLevel: LogLevel = .Errors
  public typealias LogFormatter
    = (json: JSON?, logs: [Log], file: StaticString, line: UWord, function: StaticString) -> String
  public typealias LogHandler = (logString: String) -> ()
  public var logFormatter: LogFormatter = {
    json, logs, file, line, function in
    
    var string = "Rosetta"
    
    // "\(file)" is used instead of file.stringValue, because it causes compiler warning:
    // integer overflows when converted from 'Builtin.Int32' to 'Builtin.Int8'
    let fileString = "\(file)".componentsSeparatedByString("/").last ?? "\(file)"
    string += "\n"
    string += "\(fileString):\(line) \(function)"
    
    if let jsonString = json?.stringValue {
      string += "\n"
      string += "JSON String: \(jsonString)"
    }
    else if let jsonData = json?.dataValue {
      string += "\n"
      string += "JSON Data: \(jsonData)"
    }
    
    string += "\n"
    string += "\n".join(logs.map({$0.description}))
    return string
  }
  public var logHandler: LogHandler = {println("\($0)\n--------")}
  public func setLogFormatter(formatter: LogFormatter) {
    logFormatter = formatter
  }
  public func setLogHandler(handler: LogHandler) {
    logHandler = handler
  }
  
  public init() {
    
  }
  
  public subscript(key: String) -> Rosetta {
    get {
      keyPath.append(key)
      return self
    }
  }
  
  func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ input: JSON,
    inout to object: T,
    usingMap map: Map<T>
    ) -> Bool {
      
      // parse input into a dictionary
      let inputParsingResult = input.toDictionary()
      let jsonDictionary = inputParsingResult.0
      self.logs += inputParsingResult.1 ?? []
      
      // perform test run (check if any mapping fail, to leave the object unchanged)
      currentMode = .Decode
      self.testRun = true
      if let jsonDictionary = jsonDictionary {
        dictionary = jsonDictionary
        switch map {
        case let .ValueTypeMap(map):
          map(&object, self)
        case let .ClassTypeMap(map):
          map(object, self)
        }
      }
      
      var success = !LogsContainError(logs)
      if success == true {
        self.testRun = false
        if let jsonDictionary = jsonDictionary {
          dictionary = jsonDictionary
          switch map {
          case let .ValueTypeMap(map):
            map(&object, self)
          case let .ClassTypeMap(map):
            map(object, self)
          }
        }
      }
      
      switch logLevel {
      case .None:
        break
      case .Errors:
        if success == false {
          logHandler(logString: logFormatter(json: input, logs: logs, file: file, line: line, function: function))
        }
      case .Verbose:
        if logs.count > 0 {
          logHandler(logString: logFormatter(json: input, logs: logs, file: file, line: line, function: function))
        }
      }
      
      cleanup()
      return success
  }
  
  func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ object: T,
    usingMap map: Map<T>
    ) -> [String: AnyObject]? {
      
      // prepare rosetta
      currentMode = .Encode
      dictionary = [:]
      
      // parse
      var mutableObject = object
      switch map {
      case let .ValueTypeMap(map):
        map(&mutableObject, self)
      case let .ClassTypeMap(map):
        map(mutableObject, self)
      }
      
      let result = dictionary
      let logs = self.logs
      
      let success = !LogsContainError(logs)
      switch logLevel {
      case .None:
        break
      case .Errors:
        if success == false {
          logHandler(logString: logFormatter(json: nil, logs: logs, file: file, line: line, function: function))
        }
      case .Verbose:
        if logs.count > 0 {
          logHandler(logString: logFormatter(json: nil, logs: logs, file: file, line: line, function: function))
        }
      }
      
      cleanup()
      return success ? result : nil
      
  }
  
  //MARK: Value types decoding
  
  func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ input: JSON,
    inout to object: T,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, input, to: &object, usingMap: .ValueTypeMap(map))
  }
  
  //MARK: Value types encoding
  
  func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ object: T,
    usingMap map: (inout T, json: Rosetta) -> ()
    ) -> [String: AnyObject]? {
      
      return self.encode(file: file, line: line, function: function, object, usingMap: .ValueTypeMap(map))
  }
  
  //MARK: Class types decoding
  
  func decode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ input: JSON,
    inout to object: T,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> Bool {
      
      return self.decode(file: file, line: line, function: function, input, to: &object, usingMap: .ClassTypeMap(map))
  }
  
  //MARK: Class types encoding
  
  func encode<T>(
    file: StaticString = __FILE__,
    line: UWord = __LINE__,
    function: StaticString = __FUNCTION__,
    _ object: T,
    usingMap map: (T, json: Rosetta) -> ()
    ) -> [String: AnyObject]? {
      
      return self.encode(file: file, line: line, function: function, object, usingMap: .ClassTypeMap(map))
  }
  
  //MARK: Helpers
  
  func cleanup() {
    currentMode = nil
    dictionary = nil
    logs.removeAll(keepCapacity: false)
  }
}

//MARK: Decoding

func decode<T, U, V>(
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) -> T? {
    
    let severity: Log.Severity = optional ? .Warning : .Error
    var decodedValue: T?
    if let value = value {
      if let value = value as? V {
        if let value = bridge.decoder(value) {
          if validator?(value) ?? true {
            decodedValue = value
          }
          else {
            rosetta.logs.append(Log.Mapping(severity: severity, type: .ValidationFailed, keyPath: rosetta.keyPath))
          }
        }
        else if optional == false {
          rosetta.logs.append(Log.Mapping(severity: severity, type: .BridgingFailed, keyPath: rosetta.keyPath))
        }
      }
      else if optional == false {
        rosetta.logs.append(Log.Mapping(severity: severity, type: .WrongType, keyPath: rosetta.keyPath))
      }
    }
    else if optional == false {
      rosetta.logs.append(Log.Mapping(severity: severity, type: .ValueMissing, keyPath: rosetta.keyPath))
    }
    rosetta.keyPath.removeAll(keepCapacity: false)
    return decodedValue
}

func decodeTo<T, U, V>(
  inout property: T,
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
    if rosetta.testRun == false {
      if let decoded = decoded {
        property = decoded
      }
    }
}

func decodeTo<T, U, V>(
  inout property: T!,
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
    if rosetta.testRun == false {
      if let decoded = decoded {
        property = decoded
      }
    }
}

func decodeTo<T, U, V>(
  inout property: T?,
  #value: U?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, V>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
    if rosetta.testRun == false {
      if let decoded = decoded {
        property = decoded
      }
    }
}

//MARK: Encoding

func encodeFrom<T, U>(
  property: T?,
  #rosetta: Rosetta,
  #bridge: Bridge<T, U>,
  #validator: (T -> Bool)?,
  #optional: Bool) {
    
    let severity: Log.Severity = optional ? .Warning : .Error
    if let property = property {
      if validator?(property) ?? true {
        if let encodedValue = bridge.encoder(property) {
          setValue(encodedValue, atKeyPath: rosetta.keyPath, inDictionary: &rosetta.dictionary!)
        }
        else {
          rosetta.logs.append(Log.Mapping(severity: severity, type: .BridgingFailed, keyPath: rosetta.keyPath))
        }
      }
      else {
        rosetta.logs.append(Log.Mapping(severity: severity, type: .ValidationFailed, keyPath: rosetta.keyPath))
      }
    }
    else {
      rosetta.logs.append(Log.Mapping(severity: severity, type: .ValueMissing, keyPath: rosetta.keyPath))
    }
    rosetta.keyPath.removeAll(keepCapacity: false)
}

// ------------------------------------------------

func valueForKeyPath(keyPath: [String], inDictionary dictionary: [String: AnyObject]) -> AnyObject? {
  if keyPath.count == 0 {
    return dictionary
  }
  else {
    var branch = dictionary
    for index in 0..<keyPath.count - 1 {
      if let subdict = branch[keyPath[index]] as? [String: AnyObject] {
        branch = subdict
      }
      else {
        return nil
      }
    }
    return branch[keyPath.last!]
  }
}

func dictionaryBySettingValue(
  value: AnyObject,
  forKeyPath keyPath: [String],
  inDictionary dictionary: [String: AnyObject]
  ) -> [String: AnyObject] {
    
    if keyPath.count == 0 {
      NSException(name: NSInternalInconsistencyException, reason: "ketPath must not be empty", userInfo: nil).raise()
      abort()
    }
    else if keyPath.count == 1 {
      var dictionary = dictionary
      dictionary[keyPath.first!] = value
      return dictionary
    }
    else {
      var dictionary = dictionary
      let firstKey = keyPath[0]
      var keyPath = keyPath
      keyPath.removeAtIndex(0)
      if let subdict = dictionary[firstKey] as? [String: AnyObject] {
        dictionary[firstKey] = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: subdict)
      }
      else {
        dictionary[firstKey] = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: [:])
      }
      return dictionary
    }
}

func setValue(value: AnyObject, atKeyPath keyPath: [String], inout inDictionary dictionary: [String: AnyObject]) {
  dictionary = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: dictionary)
}

extension String {
  func toData() -> NSData? {
    return self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
  }
}

extension NSData {
  func toDictionary() -> [String: AnyObject]? {
    return NSJSONSerialization.JSONObjectWithData(self, options: nil, error: nil) as? [String: AnyObject]
  }
  
  func toString() -> String? {
    return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
  }
}
