import Foundation

enum Mode {
	case Decode
	case Encode
}

enum Map<T> {
	case ValueTypeMap((inout T, Rosetta) -> ())
	case ClassTypeMap((T, Rosetta) -> ())
}

public class Rosetta {
	var testRun: Bool = false
	var dictionary: [String: AnyObject]!
	var keyPath: [String] = []
	var logs: [Log] = []
	var currentValue: AnyObject! { return valueForKeyPath(keyPath, inDictionary: dictionary) }
	var currentMode: Mode!

	public var logLevel: LogLevel = .Errors
	public var logFormatter = defaultLogFormatter
	public var logHandler = defaultLogHandler

	public func setLogFormatter(formatter: LogFormatter) { logFormatter = formatter }
	public func setLogHandler(handler: LogHandler) { logHandler = handler }

	public init() {

	}

	public subscript(key: String) -> Rosetta {
		get {
			keyPath.append(key)
			return self
		}
	}

	func decode<T>(
		file file: StaticString = __FILE__,
		line: UInt = __LINE__,
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
		file file: StaticString = __FILE__,
		line: UInt = __LINE__,
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
		file file: StaticString = __FILE__,
		line: UInt = __LINE__,
		function: StaticString = __FUNCTION__,
		_ input: JSON,
		inout to object: T,
		usingMap map: (inout T, json: Rosetta) -> ()
		) -> Bool {

			return self.decode(file: file, line: line, function: function, input, to: &object, usingMap: .ValueTypeMap(map))
	}

	//MARK: Value types encoding

	func encode<T>(
		file file: StaticString = __FILE__,
		line: UInt = __LINE__,
		function: StaticString = __FUNCTION__,
		_ object: T,
		usingMap map: (inout T, json: Rosetta) -> ()
		) -> [String: AnyObject]? {

			return self.encode(file: file, line: line, function: function, object, usingMap: .ValueTypeMap(map))
	}

	//MARK: Class types decoding

	func decode<T>(
		file file: StaticString = __FILE__,
		line: UInt = __LINE__,
		function: StaticString = __FUNCTION__,
		_ input: JSON,
		inout to object: T,
		usingMap map: (T, json: Rosetta) -> ()
		) -> Bool {

			return self.decode(file: file, line: line, function: function, input, to: &object, usingMap: .ClassTypeMap(map))
	}

	//MARK: Class types encoding

	func encode<T>(
		file file: StaticString = __FILE__,
		line: UInt = __LINE__,
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
		return (try? NSJSONSerialization.JSONObjectWithData(self, options: [])) as? [String: AnyObject]
	}

	func toString() -> String? {
		return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
	}
}
