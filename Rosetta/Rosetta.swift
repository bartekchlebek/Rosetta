import Foundation

enum Mode {
	case Decode
	case Encode
}

enum Map<T> {
	case ValueTypeMap((inout T, Rosetta) -> ())
	case ClassTypeMap((T, Rosetta) -> ())
}

public final class Rosetta {
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

	func decode<T>(input: JSON, inout to object: T, usingMap map: Map<T>) throws {

		let jsonDictionary = try input.toDictionary()

		// perform test run (check if any mapping fail, to leave the object unchanged)
		currentMode = .Decode
		dictionary = jsonDictionary

		switch map {
		case .ClassTypeMap(let map):
			self.testRun = true
			map(object, self)

			if LogsContainError(logs) {
				throw genericError
			}

			self.testRun = false
			map(object, self)
		case .ValueTypeMap(let map):
			var tmpObject = object

			map(&tmpObject, self)

			if LogsContainError(logs) {
				throw genericError
			}

			object = tmpObject
		}
		self.cleanup()
	}

	func encode<T>(object: T, usingMap map: Map<T>) throws -> JSON {
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
				logHandler(logString: logFormatter(json: nil, logs: logs))
			}
		case .Verbose:
			if logs.count > 0 {
				logHandler(logString: logFormatter(json: nil, logs: logs))
			}
		}

		cleanup()

		if !success {
			throw genericError
		}
		
		return JSON(dictionary: result)
	}

	//MARK: Helpers

	private func cleanup() {
		currentMode = nil
		dictionary = nil
		logs.removeAll(keepCapacity: false)
	}
}
