
/*
 
 Задание1:
 Имеются числа 0,1,2,3,4...,1_000_000
 посчитать сумму этих чисел через операции (10 асинхронных операций хватит).
 Последняя операция (11-ая) операция будет иметь зависимость от остальных и суммировать их результаты.
 Примечание: Класс AsyncOperation можно взять из занятия для создания своей операции.
 
 */
import UIKit


class AsyncOperation: Operation {
    
    enum State: String {
        case ready
        case executing
        case finished
        
        var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    override var isReady: Bool {
        return state == .ready && super.isReady
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished || isCancelled
    }
}

class SumAsyncOperation: AsyncOperation {
    
    let a: Int?
    let b: Int?
    var result: Int?
    
    init(_ a: Int?, _ b: Int?) {
      
        self.a = a
        self.b = b
    }
    
    override func main() {
        
        guard !isCancelled else {
            state = .finished
            print("Cancelled.")
            return
        }
        
        state = .executing
        
        DispatchQueue.global().async {
            
          if let inputA = self.a, let inputB = self.b {
            
            var result = 0
            for i in inputA...inputB {
                
                    result += i
                }
               self.result = result
            }
            
            print("Finished.")
            self.state = .finished
        }
    }
}
var first = 1
var second = 100000
var arrayOfAsyncOperation = [SumAsyncOperation]()
let queue = OperationQueue()

for _ in 1...10 {
    
        let sum = SumAsyncOperation(first, second)
        first = second
        second += 100000
        queue.addOperation(sum)
        arrayOfAsyncOperation.append(sum)
    
}

class SumOfResultsOperation: AsyncOperation {
    
    private let arrayOfAsyncOperation: [SumAsyncOperation]!
     var finalResult: Int?
    
    init(arrayOfAsyncOperation: [SumAsyncOperation]) {
        
        self.arrayOfAsyncOperation = arrayOfAsyncOperation
        
    }
    
    override func main() {
        
        guard !isCancelled else {
            state = .finished
            print("Cancelled.")
            return
        }
        
        state = .executing
        
        DispatchQueue.global().async {
            
            if let inputArray = self.arrayOfAsyncOperation {
                
                var sumOfAllOperations: Int = 0
                
                for resultOfOneOperation in inputArray {
                    
                    sumOfAllOperations += resultOfOneOperation.result!
                    
                }
                print("Сумма всех операций: \(sumOfAllOperations)")
                self.finalResult = sumOfAllOperations
                
            }
            
            print("Finished.")
            self.state = .finished
        }
    }
}

let sumOfResultsOperation = SumOfResultsOperation(arrayOfAsyncOperation: arrayOfAsyncOperation)


for operation in arrayOfAsyncOperation {
    
    sumOfResultsOperation.addDependency(operation)
}

queue.addOperation(sumOfResultsOperation)



