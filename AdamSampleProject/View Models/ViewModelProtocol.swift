//  AdamSampleProject

import Foundation

protocol ViewModel: AnyObject {
    var title: String { get }
    
    func viewAppeared()
}

extension ViewModel {
    func viewAppeared() {
        // Do Nothing
    }
}
