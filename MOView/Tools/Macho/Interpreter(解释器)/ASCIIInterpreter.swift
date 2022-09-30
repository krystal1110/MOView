//
//  ASCIIInterpreter.swift
//  MOView
//
//  Created by ljy on 2022/9/29.
//

import Foundation

struct ASCIIInterpreter: Interpreter {
    var dataSlice: Data
    var section: Section64?
    var searchProtocol: SearchProtocol
    
    private let numberOfByteInLine = 45
    
    init(dataSlice: Data, section: Section64? = nil, searchProtocol: SearchProtocol) {
        self.dataSlice = dataSlice
        self.section = section
        self.searchProtocol = searchProtocol
    }
    
 
    
    func transitionData() -> [ExplanationItem]  {
        let rawData = self.dataSlice
        
        let chars = rawData.map { char -> Character in
            if char < 32 || char > 126{
                return "."
            }
            return Character(UnicodeScalar(char))
        }
        let str = String(chars)
        
        var count = 0
        
        if str.count % numberOfByteInLine == 0 {
            count = str.count / numberOfByteInLine
        }else{
            count = (str.count / numberOfByteInLine) + 1
        }
        

        var list:[ExplanationItem] = []
        for index in 0..<count {
            let startIndex = str.index(str.startIndex, offsetBy: index * numberOfByteInLine )
            var offsetBy = numberOfByteInLine
            if str.count - (index * numberOfByteInLine) < numberOfByteInLine {
                offsetBy = str.count - (index * numberOfByteInLine)
            }
            let endIndex =  str.index(startIndex, offsetBy: offsetBy)
            let newStr = String(str[startIndex..<endIndex])
            let item = ExplanationItem(sourceDataRange: nil, model: ExplanationModel(description: nil, explanation: newStr))
            list.append(item)
            
        }
        return list
    }
    
}
