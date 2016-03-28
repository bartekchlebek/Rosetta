import Foundation

//MARK: Bridging between basic JSON types and Swift types

public let BoolBridge: Bridge<Bool, NSNumber> = BridgeNumber(
	decoder: {$0 as Bool},
	encoder: {$0}
)

public let IntBridge: Bridge<Int, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: Int64(Int.min), max: Int64(Int.max)).map{Int($0)} },
	encoder: {$0}
)

public let UIntBridge: Bridge<UInt, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: UInt64(UInt.min), max: UInt64(UInt.max)).map{UInt($0)} },
	encoder: {$0}
)

public let FloatBridge: Bridge<Float, NSNumber> = BridgeNumber(
	decoder: {$0 as Float},
	encoder: {$0}
)

public let DoubleBridge: Bridge<Double, NSNumber> = BridgeNumber(
	decoder: {$0 as Double},
	encoder: {$0}
)

public let StringBridge: Bridge<String, NSString> = BridgeString(
	decoder: {$0 as String},
	encoder: {$0}
)

public let Int8Bridge: Bridge<Int8, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: Int64(Int8.min), max: Int64(Int8.max)).map{Int8($0)} },
	encoder: { NSNumber(char: $0) }
)

public let Int16Bridge: Bridge<Int16, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: Int64(Int16.min), max: Int64(Int16.max)).map{Int16($0)} },
	encoder: { NSNumber(short: $0) }
)

public let Int32Bridge: Bridge<Int32, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: Int64(Int32.min), max: Int64(Int32.max)).map{Int32($0)} },
	encoder: { NSNumber(int: $0) }
)

public let Int64Bridge: Bridge<Int64, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: Int64.min, max: Int64.max) },
	encoder: { NSNumber(longLong: $0) }
)

public let UInt8Bridge: Bridge<UInt8, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: UInt64(UInt8.min), max: UInt64(UInt8.max)).map{UInt8($0)} },
	encoder: { NSNumber(unsignedChar: $0) }
)

public let UInt16Bridge: Bridge<UInt16, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: UInt64(UInt16.min), max: UInt64(UInt16.max)).map{UInt16($0)} },
	encoder: { NSNumber(unsignedShort: $0) }
)

public let UInt32Bridge: Bridge<UInt32, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: UInt64(UInt32.min), max: UInt64(UInt32.max)).map{UInt32($0)} },
	encoder: { NSNumber(unsignedInt: $0) }
)

public let UInt64Bridge: Bridge<UInt64, NSNumber> = BridgeNumber(
	decoder: { numberInRange($0, min: UInt64.min, max: UInt64.max) },
	encoder: { NSNumber(unsignedLongLong: $0) }
)

public let NSStringBridge: Bridge<NSString, NSString> = BridgeString(decoder: {$0}, encoder: {$0})

public let NSMutableStringBridge: Bridge<NSMutableString, NSString> = BridgeString(
	decoder: { NSMutableString(string: $0 as String) },
	encoder: { $0 }
)

public let NSNumberBridge: Bridge<NSNumber, NSNumber> = BridgeNumber(decoder: {$0}, encoder: {$0})

//MARK: Bridge between a JSONConvertible and an object JSON type

public func JSONConvertibleBridge<T: JSONConvertible>() -> Bridge<T, NSDictionary> {
	return UnsafeBridgeObject(
		decoder: {
			guard let dictionary = $0 as? [String: AnyObject] else { return nil }
			let json = JSON(dictionary: dictionary)
			return try? Rosetta().decode(json)
		},
		encoder: {
			guard let json: JSON = try? Rosetta().encode($0) else { return nil }
			return json.dictionary
		}
	)
}

//MARK: Bridge between a JSONConvertibleClass and an object JSON type

public func JSONConvertibleClassBridge<T: JSONConvertibleClass>() -> Bridge<T, NSDictionary> {
	return UnsafeBridgeObject(
		decoder: {
			guard let dictionary = $0 as? [String: AnyObject] else { return nil }
			let json = JSON(dictionary: dictionary)
			return try? Rosetta().decode(json)
		},
		encoder: {
			guard let json: JSON = try? Rosetta().encode($0) else { return nil }
			return json.dictionary
		}
	)
}

//MARK: Bridges for common conversions

public let NSURLBridge: Bridge<NSURL, NSString> = BridgeString(
	decoder: {NSURL(string: $0 as String)},
	encoder: {$0.absoluteString}
)

//MARK: Helpers

func numberInRange(number: NSNumber, min: Int64, max: Int64) -> Int64? {
	let value = number.longLongValue
	return (value >= min) && (value <= max) ? value : nil
}

func numberInRange(number: NSNumber, min: UInt64, max: UInt64) -> UInt64? {
	let value = number.unsignedLongLongValue
	return (value >= min) && (value <= max) ? value : nil
}
