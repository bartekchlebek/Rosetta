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

public let BoolBridge: Bridge<Bool, NSNumber> = BridgeNumber<Bool>(
	decoder: { .success($0.boolValue)},
	encoder: { .success(NSNumber(value: $0)) }
)

public let IntBridge: Bridge<Int, NSNumber> = BridgeNumber<Int>(
	decoder: { Int(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UIntBridge: Bridge<UInt, NSNumber> = BridgeNumber<UInt>(
	decoder: { UInt(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let FloatBridge: Bridge<Float, NSNumber> = BridgeNumber<Float>(
	decoder: { .success($0.floatValue) },
	encoder: { .success(NSNumber(value: $0)) }
)

public let DoubleBridge: Bridge<Double, NSNumber> = BridgeNumber<Double>(
	decoder: { .success($0.doubleValue) },
	encoder: { .success(NSNumber(value: $0)) }
)

public let StringBridge: Bridge<String, NSString> = BridgeString<String>(
	decoder: { .success($0 as String) },
	encoder: { .success($0 as NSString) }
)

public let Int8Bridge: Bridge<Int8, NSNumber> = BridgeNumber<Int8>(
	decoder: { Int8(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let Int16Bridge: Bridge<Int16, NSNumber> = BridgeNumber<Int16>(
	decoder: { Int16(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let Int32Bridge: Bridge<Int32, NSNumber> = BridgeNumber<Int32>(
	decoder: { Int32(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let Int64Bridge: Bridge<Int64, NSNumber> = BridgeNumber<Int64>(
	decoder: { Int64(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt8Bridge: Bridge<UInt8, NSNumber> = BridgeNumber<UInt8>(
	decoder: { UInt8(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt16Bridge: Bridge<UInt16, NSNumber> = BridgeNumber<UInt16>(
	decoder: { UInt16(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt32Bridge: Bridge<UInt32, NSNumber> = BridgeNumber<UInt32>(
	decoder: { UInt32(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let UInt64Bridge: Bridge<UInt64, NSNumber> = BridgeNumber<UInt64>(
	decoder: { UInt64(nsnumber: $0).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success(NSNumber(value: $0)) }
)

public let NSStringBridge: Bridge<NSString, NSString> = BridgeString<NSString>(decoder: { .success($0) }, encoder: { .success($0) })

public let NSMutableStringBridge: Bridge<NSMutableString, NSString> = BridgeString<NSMutableString>(
	decoder: { .success(NSMutableString(string: $0 as String)) },
	encoder: { .success($0) }
)

public let NSNumberBridge: Bridge<NSNumber, NSNumber> = BridgeNumber<NSNumber>(decoder: { .success($0) }, encoder: { .success($0) })

//MARK: Bridge between a JSONConvertible and an object JSON type

public func JSONConvertibleBridge<T: JSONConvertible>() -> Bridge<T, NSDictionary> {
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
			return .success(NSDictionary(dictionary: dictionary))
		}
	)
}

//MARK: Bridge between a JSONConvertibleClass and an object JSON type

public func JSONConvertibleClassBridge<T: JSONConvertibleClass>() -> Bridge<T, NSDictionary> {
	return _UnsafeBridgeDictionary<T>(
		decoder: {
			guard let dictionary = $0 as? [String: AnyObject] else { return .unexpectedValue }
			let json = JSON(dictionary: dictionary)
			return (try? Rosetta().decode(json)).map { .success($0) } ?? .unexpectedValue
		},
		encoder: {
			guard let json: JSON = try? Rosetta().encode($0) else { return .error }
			guard let dictionary = json.dictionary else { return .error }
			return .success(NSDictionary(dictionary: dictionary))
		}
	)
}

//MARK: Bridges for common conversions

public let NSURLBridge: Bridge<URL, NSString> = BridgeString<URL>(
	decoder: { URL(string: $0 as String).map { .success($0) } ?? .unexpectedValue },
	encoder: { .success($0.absoluteString as NSString) }
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
