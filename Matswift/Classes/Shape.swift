//
//  Shape.swift
//  Matswift
//
//  Created by jknthn on 12/10/2017.
//  Copyright © 2017 Jeremi Kaczmarczyk (jeremi.kaczmarczyk@gmail.com)
//

import Foundation

/// Type describing 2-dimensional `Matrix` shape
public struct Shape: Equatable {
    
    /// Transpose operation
    public var T: Shape {
        return Shape(rows: columns, columns: rows)
    }
    
    /// Count of elements which `Matrix` given `Shape` holds
    public var elements: Int {
        return rows * columns
    }
    
    public let rows: Int
    public let columns: Int
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
}

extension Shape: Equatable {
    
    public static func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns
    }
}
