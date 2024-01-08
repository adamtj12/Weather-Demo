//  AdamSampleProject

import Foundation

typealias DispatchClosure = () -> ()

func syncMainThread(_ closure: DispatchClosure) {
    if Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.sync {
            closure()
        }
    }
}

func asyncMainThread(_ closure: @escaping DispatchClosure) {
    DispatchQueue.main.async {
        closure()
    }
}

func sync(_ queue: DispatchQueue, closure: @escaping DispatchClosure) {
    #if DEBUG
    #else
    #endif
    
    if OperationQueue.current?.underlyingQueue == queue {
        closure()
        return
    }
    
    queue.sync {
        closure()
    }
}

func async(_ queue: DispatchQueue, closure: @escaping DispatchClosure) {
    queue.async {
        closure()
    }
}

// Delay in milliseconds
func asyncMainThread(_ delay: Int, closure: @escaping DispatchClosure) {
    let time = DispatchTime.now() + DispatchTimeInterval.milliseconds(delay)
    DispatchQueue.main.asyncAfter(deadline: time) {
       closure()
    }
}

func async(_ queue: DispatchQueue, delay: Int, closure: @escaping DispatchClosure) {
    let time = DispatchTime.now() + DispatchTimeInterval.milliseconds(delay)
    queue.asyncAfter(deadline: time) {
        closure()
    }
}

func serialBackgroundQueue(withLabel label: String) -> DispatchQueue {
    //return DispatchQueue.global(qos: .background)
    return DispatchQueue(label: label, qos: .background, attributes: [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}

func concurrentBackgroundQueue(withLabel label: String) -> DispatchQueue {
    //return DispatchQueue.global(qos: .background)
    return DispatchQueue(label: label, qos: .background, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}
