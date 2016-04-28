import Foundation

class PersistencyModel {
    
    class var defaultModel:PersistencyModel {
        struct Singleton {
            static let model = PersistencyModel()
        }
        
        return Singleton.model
    }
}