import Foundation

public protocol Creatable {
	init()
}

public protocol Mappable {
	static func map(inout object: Self, json: Rosetta)
}

public protocol MappableClass: class {
	static func map(object: Self, json: Rosetta)
}

public protocol JSONConvertible : Creatable, Mappable {

}

public protocol JSONConvertibleClass : Creatable, MappableClass {

}
