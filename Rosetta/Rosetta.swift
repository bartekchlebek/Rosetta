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

			let success = !LogsContainError(logs)
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
