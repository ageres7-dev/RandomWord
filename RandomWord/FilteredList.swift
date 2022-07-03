//
//  FilteredList.swift
//  RandomWord
//
//  Created by Sergey Dolgikh on 03.07.2022.
//


import CoreData
import SwiftUI

enum Predicate: String {
    case beginsWith = "BEGINSWITH"
    case beginsWithNotCaseSensitive = "BEGINSWITH[c]"
    case containsNotCaseSensitive = "CONTAINS[c]"
    case contains = "CONTAINS"
    case inPredicate = "IN"
    case equals = "=="
    case less = "<"
    case more = ">"
}

struct FilteredList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>

    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content

    var body: some View {
        List(fetchRequest, id: \.self) { singer in
            self.content(singer)
        }
    }
    
    init(sortDescriptors: [NSSortDescriptor],
        isInverse: Bool = false,
         filterKey: String,
         predicate: Predicate,
         filterValue: String,
         @ViewBuilder content: @escaping (T) -> Content
         
    ) {
        let isInverseString = isInverse ? "NOT" : ""
        _fetchRequest = FetchRequest(
            sortDescriptors: sortDescriptors,
            predicate: NSPredicate(format: "\(isInverseString) %K \(predicate.rawValue) %@", filterKey, filterValue)
        )
        
        
//        _fetchRequest = FetchRequest<T>(
//            sortDescriptors: sortDescriptors,
//            predicate: NSPredicate(format: "\(isInverseString) %K \(predicate.rawValue) %@", filterKey, filterValue)
//        )
        
        self.content = content
    }
}
