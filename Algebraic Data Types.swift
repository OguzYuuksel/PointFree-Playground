struct Pair<A, B> {
    let first: A
    let second: B
}

Pair<Bool, Bool>.init(first: true, second: true)
Pair<Bool, Bool>.init(first: true, second: false)
Pair<Bool, Bool>.init(first: false, second: true)
Pair<Bool, Bool>.init(first: false, second: false)

enum Three {
    case one
    case two
    case three
}

Pair<Bool, Three>.init(first: true, second: .one)
Pair<Bool, Three>.init(first: true, second: .two)
Pair<Bool, Three>.init(first: true, second: .three)
Pair<Bool, Three>.init(first: false, second: .one)
Pair<Bool, Three>.init(first: false, second: .two)
Pair<Bool, Three>.init(first: false, second: .three)

Pair<Bool, Void>.init(first: true, second: ())
Pair<Bool, Void>.init(first: false, second: ())

enum Never {}
// let _: Never = ???

// Pair<Bool, Never>.init(first: true, second: ???)

// Pair<Bool, Bool> = 4 = 2 * 2
// Pair<Bool, Three> = 6 = 2 * 3
// Pair<Bool, Void> = 2 = 2 * 1
// Pair<Void, Void> = 1 = 1 * 1
// Pair<Bool, Never> = 0 = 2 * 0

enum Either<A, B> {
    case left(A)
    case right(B)
}

Either<Bool, Bool>.left(true)
Either<Bool, Bool>.left(false)
Either<Bool, Bool>.right(true)
Either<Bool, Bool>.right(false)

Either<Bool, Three>.left(true)
Either<Bool, Three>.left(false)
Either<Bool, Three>.right(.one)
Either<Bool, Three>.right(.two)
Either<Bool, Three>.right(.three)

Either<Bool, Void>.left(true)
Either<Bool, Void>.left(false)
Either<Bool, Void>.right(())
// 2 + 1 = 3

Either<Bool, Never>.left(true)
Either<Bool, Never>.left(false)
// Either<Bool, Never>.right(???)
// 2 + 0 = 2

// struct = *
// enum = +
// Void = 1
// Never = 0

// A + 1 = 1 + A = A?

// A * B + A * C
//Either<Pair<A, B>, Pair<A, C>>
// A * B + A * C = A * (B + C)
//Pair<A, Either<B, C>>

import Foundation
//URLSession.shared
//    .dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)

// (Data + 1) * (URLResponse + 1) * (Error + 1)
//   = Data * URLResponse * Error
//     + Data * URLReponse
//     + URLReponse * Error
//     + Data * Error
//     + Data
//     + URLReponse
//     + Error
//     + 1

// Data * URLResponse + Error
// Either<Pair<Data, URLResponse>, Error>
// Result<(Data, URLResponse), Error>

let a = 2.0
let b = 3.0
let c = 4.0

// 2^100
pow(2, 100)

// Bool^Three
// Bool^(1 + 1 + 1)
// Bool^1 * Bool^1 * Bool^1
// (Three) -> Bool

// A^B = (B) -> (A) They are pure functions.
// 2^3 = 8
pow(2, 3)

// (a^b)^c = a^(b*c)
// (a <- b) <- c = a <- (b * c)
// c -> (b -> a) = (b * c) -> a
// (C) -> (B) -> A = (B, C) -> A // curry
func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C { return { a in { b in f(a, b) } } }
func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C { return { f($0)($1) } }


String.init(data:encoding:)
curry(String.init(data:encoding:))
uncurry(curry(String.init(data:encoding:)))

// a^1 = a
pow(a, 1) == a
pow(b, 1) == b
pow(c, 1) == c

// a^1 = a
// a <- 1 = a
// 1 -> a = a
// (Void) -> A = A
func to<A>(_ f: @escaping () -> A) -> A { f() }
func from<A>(_ a: A) -> () -> A { return { a } }

// a^0 = 1
pow(a, 0) == 1
pow(b, 0) == 1
pow(c, 0) == 1
pow(0, 0) == 1

// a^0 = 1
// a <- 0 = 1
// 0 -> a = 1
// Never -> a = Void
// Never -> A = Void
func to<A>(_ f: (Never) -> A) -> Void { return () }
func from<A>(_ f: ()) -> (Never) -> A {
    return { never in
        switch never {
            //
        }
    }
}

func absurd<A>(_ never: Never) -> A {
    switch never {
        //
    }
}

extension Result {
    func fold<A>(ifSuccess: (Success) -> A, ifFailure: (Failure) -> A) -> A {
        switch self {
        case let .success(success):
            return ifSuccess(success)
        case let .failure(failure):
            return ifFailure(failure)
        }
    }
}

extension String: Error { }
extension Never: Error { }

let result: Result<Int, String> = .success(2)

result
    .fold(ifSuccess: { _ in "OK" } , ifFailure: { _ in "Something went wrong" })

let infallinleResult: Result<Int, Never> = .success(2)

infallinleResult
    .fold(ifSuccess: { _ in "OK" } , ifFailure: absurd)

// (A) -> A
// (inout A) -> Void
func to<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { a in
        a = f(a)
    }
}

func from<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return {
        var copy = $0
        f(&copy)
        return copy
    }
}

// (A, B) -> A
// (inout A, B) -> Void

// (A, inout B) -> C
// (A, B) -> (C, B)
Data.init(from:)

// (A) throws -> B == (A) -> Result<B, Error>
func unthrow<A, B>(_ f: @escaping (A) throws -> B) -> (A) -> Result<B, Error> {
    return {
        do {
            return .success(try f($0))
        } catch {
            return .failure(error)
        }
    }
}

func throwing<A, B>(_ f: @escaping (A) -> Result<B, Error>) -> (A) throws -> B {
    return {
        switch f($0) {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

Data.init(from:)
unthrow(Data.init(from:))
throwing(unthrow(Data.init(from:)))

// a^(b + c) = a^b * a^c
// a <- (b + c) = (a <- b) * (a <- c)
// (B + C) -> A = (B -> A) * (C -> A)
// Either<B, C> -> A = ((B) -> A, (C) -> A)
func to<A, B, C>(_ f: @escaping (Result<B, C>) -> A) -> ((B) -> A, (C) -> A) {
    ({ f(.success($0)) }, { f(.failure($0)) })
}
func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Result<B, C>) -> A {
    return {
        switch $0 {
        case let .success(value):
            return f.0(value)
        case let .failure(error):
            return f.1(error)
        }
    }
}

// (a * b)^c = a^c * b^c
// (C) -> (A, B) = ((C) -> A, (C) -> B)
func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
    ( { f($0).0 } , { f($0).1 })
}

func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
    return {
        (f.0($0), f.1($0))
    }
}

struct Func<A, B> {
    let apply: (A) -> B
}

// Either <A, B> = A + B
// Pair<A, B> = A * B
// Func<A, B> = B^A

// | Algebra      | Swift Type System |
// | ------------ | ----------------- |
// | Sums         | Enums             |
// | Products     | Structs           |
// | Exponentials | Functions         |
// | Functions    | Generics          |

enum Optional<A> {
    case some(A)
    case none // Void
}

// Optional(A) = A + Void
//             = A + 1
// A? = A + 1

// A natural number is either:
// - Zero, or
// - The successor to some other natural number

enum NaturalNumber {
    case zero
    indirect case successor(NaturalNumber)
}

let zero = NaturalNumber.zero
let one = NaturalNumber.successor(.zero)
let two = NaturalNumber.successor(.successor(.zero))
let three = NaturalNumber.successor(.successor(.successor(.zero)))

func predecessor(_ nat: NaturalNumber) -> NaturalNumber? {
    switch nat {
    case .zero:
        return nil
    case .successor(let predecessor):
        return predecessor
    }
}

// NaturalNumber = 1 + NaturalNumber
//    = 1 + (1 + NaturalNumber)
//    = 1 + (1 + (1 + NaturalNumber))
//    = 1 + (1 + (1 + (1 + NaturalNumber)))
//    ...
//    = 1 + 1 + 1 + 1 ...

// List<A>
// A value in List<A> is either:
// - empty list, or
// - a value (called the head) appended onto the rest of list (called the tail)

enum List<A> {
    case empty
    indirect case cons(A, List<A>)
}

let xs: List<Int> = .cons(1, .cons(2, .cons(3, .empty)))
// [1, 2, 3]

func sum(_ xs: List<Int>) -> Int {
    switch xs {
    case .empty:
        return 0
    case let .cons(head, tail):
        return head + sum(tail)
    }
}

sum(xs)

// List(A) = 1 + A * List(A)
// => List(A) - A * List(A) = 1
// => List(A) * (1 - A) = 1
// => List(A) = 1 / (1 - A)

// List(A) = 1 + A * List(A)
//         = 1 + A * (1 + A * List(A))
//         = 1 + A + A*A * List(A)
//         = 1 + A + A*A * (1 + A * List(A))
//         = 1 + A + A*A + A*A*A * List(A)
//         = 1 + A + A*A + A*A*A + A*A*A*A * List(A)
//         = 1 + A + A*A + A*A*A + A*A*A*A + ....

enum AlgebraicList<A> {
    case empty
    case one(A)
    case two(A, A)
    case three(A, A, A)
    // ...
}

// List(A) = 1 / (1 - A)
//         = 1 + A + A*A + A*A*A ...

struct NonEmptyArray<A> {
    private let values: [A]
    
    init?(_ values: [A]) {
        guard !values.isEmpty else { return nil }
        self.values = values
    }
    
    init(values first: A, _ rest: A...) {
        self.values = [first] + rest
    }
}

extension NonEmptyArray: Collection {
    var startIndex: Int { values.startIndex }
    var endIndex: Int { values.endIndex }
    func index(after i: Int) -> Int { values.index(after: i) }
    subscript(index: Int) -> A { get { values[index] } }
}

extension NonEmptyArray {
    var first: A { values.first! }
    var last: A { values.last! }
}

NonEmptyArray([1, 2, 3])
NonEmptyArray([])
NonEmptyArray(values: 1, 2, 3)

// List(A) = 1 + A + A*A + A*A*A + ...
// NonEmptyList(A) = A + A*A + A*A*A + ...
//                 = A * (1 + A + A*A + ...)
//                 = A * List(A)

struct NonEmptyListProduct<A> {
    let head: A
    let tail: List<A>
}

let zs = NonEmptyListProduct(head: 1, tail: .cons(2, .cons(3, .empty)))

// NonEmptyList(A) = A + A*A + A*A*A + ...
//                 = A + A * (A + A*A + ...)
//                 = A + A * NonEmptyList(A)

enum NonEmptyListSum<A> {
    case singleton(A)
    indirect case cons(A, NonEmptyListSum<A>)
}

let zs1: NonEmptyListSum<Int> = .cons(1, .cons(2, .singleton(3)))

extension NonEmptyListSum {
    var first: A {
        switch self {
        case let .singleton(first):
            return first
        case let .cons(head, _):
            return head
        }
    }
}


