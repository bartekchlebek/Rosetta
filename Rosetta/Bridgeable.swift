import Foundation

public protocol Bridgeable {
	associatedtype JSONType: NSObject
	static func bridge() -> _Bridge<Self, JSONType>
}

extension String: Bridgeable {
	public static func bridge() -> _Bridge<String, NSString> {
		return StringBridge
	}
}

extension Int: Bridgeable {
	public static func bridge() -> _Bridge<Int, NSNumber> {
		return IntBridge
	}
}

extension UInt: Bridgeable {
	public static func bridge() -> _Bridge<UInt, NSNumber> {
		return UIntBridge
	}
}

extension Double: Bridgeable {
	public static func bridge() -> _Bridge<Double, NSNumber> {
		return DoubleBridge
	}
}

extension Bool: Bridgeable {
	public static func bridge() -> _Bridge<Bool, NSNumber> {
		return BoolBridge
	}
}

extension Float: Bridgeable {
	public static func bridge() -> _Bridge<Float, NSNumber> {
		return FloatBridge
	}
}

extension Int8: Bridgeable {
	public static func bridge() -> _Bridge<Int8, NSNumber> {
		return Int8Bridge
	}
}

extension Int16: Bridgeable {
	public static func bridge() -> _Bridge<Int16, NSNumber> {
		return Int16Bridge
	}
}

extension Int32: Bridgeable {
	public static func bridge() -> _Bridge<Int32, NSNumber> {
		return Int32Bridge
	}
}

extension Int64: Bridgeable {
	public static func bridge() -> _Bridge<Int64, NSNumber> {
		return Int64Bridge
	}
}

extension UInt8: Bridgeable {
	public static func bridge() -> _Bridge<UInt8, NSNumber> {
		return UInt8Bridge
	}
}

extension UInt16: Bridgeable {
	public static func bridge() -> _Bridge<UInt16, NSNumber> {
		return UInt16Bridge
	}
}

extension UInt32: Bridgeable {
	public static func bridge() -> _Bridge<UInt32, NSNumber> {
		return UInt32Bridge
	}
}

extension UInt64: Bridgeable {
	public static func bridge() -> _Bridge<UInt64, NSNumber> {
		return UInt64Bridge
	}
}
