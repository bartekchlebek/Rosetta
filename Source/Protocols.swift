import Foundation

public protocol Creatable {
	init()
}

public protocol Mappable {
	static func map(_ object: inout Self, json: Rosetta)
}

public protocol MappableClass: class {
	static func map(_ object: Self, json: Rosetta)
}

public protocol JSONConvertible : Creatable, Mappable {

}

public protocol JSONConvertibleClass : Creatable, MappableClass {

}
