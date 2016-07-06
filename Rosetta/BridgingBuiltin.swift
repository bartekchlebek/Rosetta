import Foundation

//MARK: Bridging between basic JSON types and Swift types

extension Int {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: Int64(Int.min), max: Int64(Int.max)) {
			self = Int(number)
		}
		else {
			return nil
		}
	}
}

extension UInt {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: UInt64(UInt.min), max: UInt64(UInt.max)) {
			self = UInt(number)
		}
		else {
			return nil
		}
	}
}

extension Int8 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: Int64(Int8.min), max: Int64(Int8.max)) {
			self = Int8(number)
		}
		else {
			return nil
		}
	}
}

extension UInt8 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: UInt64(UInt8.min), max: UInt64(UInt8.max)) {
			self = UInt8(number)
		}
		else {
			return nil
		}
	}
}

extension Int16 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: Int64(Int16.min), max: Int64(Int16.max)) {
			self = Int16(number)
		}
		else {
			return nil
		}
	}
}

extension UInt16 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: UInt64(UInt16.min), max: UInt64(UInt16.max)) {
			self = UInt16(number)
		}
		else {
			return nil
		}
	}
}

extension Int32 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: Int64(Int32.min), max: Int64(Int32.max)) {
			self = Int32(number)
		}
		else {
			return nil
		}
	}
}

extension UInt32 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: UInt64(UInt32.min), max: UInt64(UInt32.max)) {
			self = UInt32(number)
		}
		else {
			return nil
		}
	}
}

extension Int64 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: Int64.min, max: Int64.max) {
			self = Int64(number)
		}
		else {
			return nil
		}
	}
}

extension UInt64 {
	init?(nsnumber: NSNumber) {
		if let number = numberInRange(nsnumber, min: UInt64(UInt64.min), max: UInt64(UInt64.max)) {
			self = UInt64(number)
		}
		else {
			return nil
		}
	}
}

public let BoolBridge: _Bridge<Bool, NSNumber> = _BridgeNumber<Bool>(
	decoder: { .success($0 as Bool)},
	encoder: { .success($0) }
)

public let IntBridge: _Bridge<Int, NSNumber> = _BridgeNumber<Int>(
	decoder: { Int(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success($0) }
)

public let UIntBridge: _Bridge<UInt, NSNumber> = _BridgeNumber<UInt>(
	decoder: { UInt(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success($0) }
)

public let FloatBridge: _Bridge<Float, NSNumber> = _BridgeNumber<Float>(
	decoder: { .success($0 as Float) },
	encoder: { .success($0) }
)

public let DoubleBridge: _Bridge<Double, NSNumber> = _BridgeNumber<Double>(
	decoder: { .success($0 as Double) },
	encoder: { .success($0) }
)

public let StringBridge: _Bridge<String, NSString> = _BridgeString<String>(
	decoder: { .success($0 as String) },
	encoder: { .success($0) }
)

public let Int8Bridge: _Bridge<Int8, NSNumber> = _BridgeNumber<Int8>(
	decoder: { Int8(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let Int16Bridge: _Bridge<Int16, NSNumber> = _BridgeNumber<Int16>(
	decoder: { Int16(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let Int32Bridge: _Bridge<Int32, NSNumber> = _BridgeNumber<Int32>(
	decoder: { Int32(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let Int64Bridge: _Bridge<Int64, NSNumber> = _BridgeNumber<Int64>(
	decoder: { Int64(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt8Bridge: _Bridge<UInt8, NSNumber> = _BridgeNumber<UInt8>(
	decoder: { UInt8(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt16Bridge: _Bridge<UInt16, NSNumber> = _BridgeNumber<UInt16>(
	decoder: { UInt16(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt32Bridge: _Bridge<UInt32, NSNumber> = _BridgeNumber<UInt32>(
	decoder: { UInt32(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt64Bridge: _Bridge<UInt64, NSNumber> = _BridgeNumber<UInt64>(
	decoder: { UInt64(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let NSStringBridge: _Bridge<NSString, NSString> = _BridgeString<NSString>(decoder: { .success($0) }, encoder: { .success($0) })

public let NSMutableStringBridge: _Bridge<NSMutableString, NSString> = _BridgeString<NSMutableString>(
	decoder: { .success(NSMutableString(string: $0 as String)) },
	encoder: { .success($0) }
)

public let NSNumberBridge: _Bridge<NSNumber, NSNumber> = _BridgeNumber<NSNumber>(decoder: { .success($0) }, encoder: { .success($0) })

//MARK: Bridge between a JSONConvertible and an object JSON type

public func JSONConvertibleBridge<T: JSONConvertible>() -> _Bridge<T, NSDictionary> {
	return _UnsafeBridgeDictionary<T>(
		decoder: {
			guard let dictionary = $0 as? [String: AnyObject] else { return .unexpectedValue }
			let json = JSON(dictionary: dictionary)
			guard let result = try? Rosetta().decode(json) as T else { return .unexpectedValue }
			return .success(result)
		},
		encoder: {
			guard let json: JSON = try? Rosetta().encode($0) else { return .error }
			guard let dictionary = json.dictionary else { return .error }
			return .success(dictionary)
		}
	)
}

//MARK: Bridge between a JSONConvertibleClass and an object JSON type

public func JSONConvertibleClassBridge<T: JSONConvertibleClass>() -> _Bridge<T, NSDictionary> {
	return _UnsafeBridgeDictionary<T>(
		decoder: {
			guard let dictionary = $0 as? [String: AnyObject] else { return .unexpectedValue }
			let json = JSON(dictionary: dictionary)
			return (try? Rosetta().decode(json)).map { .success($0) } ?? .unexpectedValue
		},
		encoder: {
			guard let json: JSON = try? Rosetta().encode($0) else { return .error }
			guard let dictionary = json.dictionary else { return .error }
			return .success(dictionary)
		}
	)
}

//MARK: Bridges for common conversions

public let NSURLBridge: _Bridge<URL, NSString> = _BridgeString<URL>(
	decoder: { URL(string: $0 as String).map { .success($0) } ?? .unexpectedValue },
	encoder: { $0.absoluteString.map { .success($0) } ?? .error }
)

//MARK: Helpers

func numberInRange(_ number: NSNumber, min: Int64, max: Int64) -> Int64? {
	let value = number.int64Value
	return (value >= min) && (value <= max) ? value : nil
}

func numberInRange(_ number: NSNumber, min: UInt64, max: UInt64) -> UInt64? {
	let value = number.uint64Value
	return (value >= min) && (value <= max) ? value : nil
}
