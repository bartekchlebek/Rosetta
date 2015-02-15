import Foundation

public protocol Creatable {
  init()
}

public protocol Mappable {
  static func map(json: Rosetta, inout object: Self)
}

public protocol MappableClass: class {
  static func map(json: Rosetta, object: Self)
}

public protocol JSONConvertible : Creatable, Mappable {
  
}

public protocol JSONConvertibleClass : Creatable, MappableClass {
  
}
