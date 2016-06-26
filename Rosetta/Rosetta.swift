import Foundation

enum Mode {
	case decode
	case encode
}

enum Map<T> {
	case valueTypeMap((inout T, Rosetta) -> ())
	case classTypeMap((T, Rosetta) -> ())
}

public final class Rosetta {
	var testRun: Bool = false
	var dictionary: [String: AnyObject]!
	var keyPath: [String] = []
	var logs: [Log] = []
	var currentValue: AnyObject! { return valueForKeyPath(keyPath, inDictionary: dictionary) }
	var currentMode: Mode!

	public var logLevel: LogLevel = .errors
	public var logFormatter = defaultLogFormatter
	public var logHandler = defaultLogHandler

	public func setLogFormatter(_ formatter: LogFormatter) { logFormatter = formatter }
	public func setLogHandler(_ handler: LogHandler) { logHandler = handler }

	public init() {

	}

	public subscript(key: String) -> Rosetta {
		get {
			keyPath.append(key)
			return self
		}
	}

	func decode<T>(_ input: JSON, to object: inout T, usingMap map: Map<T>) throws {

		let jsonDictionary = try input.toDictionary()

		// perform test run (check if any mapping fail, to leave the object unchanged)
		currentMode = .decode
		dictionary = jsonDictionary

		switch map {
		case .classTypeMap(let map):
			self.testRun = true
			map(object, self)

			if LogsContainError(logs) {
				throw genericError
			}

			self.testRun = false
			map(object, self)
		case .valueTypeMap(let map):
			var tmpObject = object

			map(&tmpObject, self)

			if LogsContainError(logs) {
				throw genericError
			}

			object = tmpObject
		}
		self.cleanup()
	}

	func encode<T>(_ object: T, usingMap map: Map<T>) throws -> JSON {
		// prepare rosetta
		currentMode = .encode
		dictionary = [:]

		// parse
		var mutableObject = object
		switch map {
		case let .valueTypeMap(map):
			map(&mutableObject, self)
		case let .classTypeMap(map):
			map(mutableObject, self)
		}

		let result = dictionary
		let logs = self.logs

		let success = !LogsContainError(logs)
		switch logLevel {
		case .none:
			break
		case .errors:
			if success == false {
				logHandler(logString: logFormatter(json: nil, logs: logs))
			}
		case .verbose:
			if logs.count > 0 {
				logHandler(logString: logFormatter(json: nil, logs: logs))
			}
		}

		cleanup()

		if !success {
			throw genericError
		}
		
		return JSON(dictionary: result!)
	}

	//MARK: Helpers

	private func cleanup() {
		currentMode = nil
		dictionary = nil
		logs.removeAll(keepingCapacity: false)
	}
}
