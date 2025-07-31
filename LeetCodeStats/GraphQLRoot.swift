import Foundation

struct GraphQLRoot<T: Decodable>: Decodable {
    let  data:T
    let errors: [GraphQLError]?

    struct GraphQLError: Decodable {
        let message: String
        let path: [String]?
    }
}


