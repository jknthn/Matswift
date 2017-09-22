//
//  Matrix.swift
//  Matswift
//
//  Created by jknthn on 22/09/2017.
//  Copyright © 2017 Jeremi Kaczmarczyk. All rights reserved.
//

import Foundation
import Accelerate
import GameplayKit

public enum SumDirection {
    case rows
    case columns
}

public struct Shape: Equatable {
    
    public var T: Shape {
        return Shape(rows: columns, columns: rows)
    }
    
    public var elements: Int {
        return rows * columns
    }
    
    public let rows: Int
    public let columns: Int
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
    
    public static func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns
    }
}

public struct Matrix: Equatable {
    
    public var T: Matrix {
        let newShape = shape.T
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_mtransD(values, 1, &result, 1, vDSP_Length(newShape.rows), vDSP_Length(newShape.columns))
        return Matrix(values: result, shape: newShape)
    }
    
    public let values: [Double]
    public let shape: Shape
    
    public init(values: [[Double]]) {
        self.values = values.reduce([Double](), +)
        self.shape = Shape(rows: values.count, columns: values[0].count)
    }
    
    public init(values: [Double], shape: Shape) {
        precondition(values.count == shape.elements)
        self.values = values
        self.shape = shape
    }
    
    public init(zeros: Shape) {
        self.values = [Double](repeating : 0.0, count : zeros.elements)
        self.shape = zeros
    }
    
    public init(random: Shape, multiplier: Double) {
        var values = [Double]()
        let distribution = GKRandomDistribution(lowestValue: 0, highestValue: 1000)
        for _ in 0..<random.elements {
            values.append(Double(distribution.nextUniform()) * multiplier)
        }
        self.values = values
        self.shape = random
    }
    
    private func addScalar(_ scalar: Double) -> Matrix {
        var sc = scalar
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vsaddD(values, 1, &sc, &result, 1, vDSP_Length(result.count))
        return Matrix(values: result, shape: shape)
    }
    
    private func multiplyByScalar(_ scalar: Double) -> Matrix {
        var sc = scalar
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vsmulD(values, 1, &sc, &result, 1, vDSP_Length(result.count))
        return Matrix(values: result, shape: shape)
    }
    
    public func broadcast(to newShape: Shape) -> Matrix? {
        if newShape.rows == shape.rows && newShape.columns % shape.columns == 0 {
            var newValues = [Double]()
            let amount = newShape.columns / shape.columns
            for v in values {
                for _ in 0..<amount {
                    newValues.append(v)
                }
            }
            return Matrix(values: newValues, shape: newShape)
        } else if newShape.columns == shape.columns && newShape.rows % shape.rows == 0  {
            var newValues = [Double]()
            for _ in 0..<(newShape.rows / shape.rows) {
                newValues += values
            }
            return Matrix(values: newValues, shape: newShape)
        } else {
            return nil
        }
    }
    
    private func add(_ matrix: Matrix) -> Matrix {
        precondition(matrix.shape == shape)
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vaddD(values, 1, matrix.values, 1, &result, 1, vDSP_Length(values.count))
        return Matrix(values: result, shape: shape)
    }
    
    private func multiply(by matrix: Matrix) -> Matrix {
        precondition(matrix.shape == shape)
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vmulD(values, 1, matrix.values, 1, &result, 1, vDSP_Length(values.count))
        return Matrix(values: result, shape: shape)
    }
    
    public func sum() -> Double {
        var result = 0.0
        vDSP_sveD(values, 1, &result, vDSP_Length(values.count))
        return result
    }
    
    public static func ==(lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.values == rhs.values && lhs.shape == rhs.shape
    }
    
    public static func +(lhs: Matrix, rhs: Double) -> Matrix{
        return lhs.addScalar(rhs)
    }
    
    public static func +(lhs: Double, rhs: Matrix) -> Matrix {
        return rhs.addScalar(lhs)
    }
    
    public static func -(lhs: Matrix, rhs: Double) -> Matrix{
        return lhs + (-rhs)
    }
    
    public static func -(lhs: Double, rhs: Matrix) -> Matrix {
        return lhs + rhs.invertSign()
    }
    
    public static func *(lhs: Matrix, rhs: Double) -> Matrix{
        return lhs.multiplyByScalar(rhs)
    }
    
    public static func *(lhs: Double, rhs: Matrix) -> Matrix {
        return rhs.multiplyByScalar(lhs)
    }
    
    public static func +(lhs: Matrix, rhs: Matrix) -> Matrix {
        if lhs.shape == rhs.shape {
            return lhs.add(rhs)
        } else if let broadcasted = lhs.broadcast(to: rhs.shape) {
            return broadcasted.add(rhs)
        } else if let broadcasted = rhs.broadcast(to: lhs.shape) {
            return lhs.add(broadcasted)
        } else {
            fatalError("Size error")
        }
    }
    
    public static func -(lhs: Matrix, rhs: Matrix) -> Matrix {
        return lhs + rhs.invertSign()
    }
    
    public static func *(lhs: Matrix, rhs: Matrix) -> Matrix {
        if lhs.shape == rhs.shape {
            return lhs.multiply(by: rhs)
        } else if let broadcasted = lhs.broadcast(to: rhs.shape) {
            return broadcasted.multiply(by: rhs)
        } else if let broadcasted = rhs.broadcast(to: lhs.shape) {
            return lhs.multiply(by:broadcasted)
        } else {
            fatalError("Size error")
        }
    }
    
    public static func /(lhs: Matrix, rhs: Matrix) -> Matrix {
        if lhs.shape == rhs.shape {
            return lhs.divide(by: rhs)
        } else if let broadcasted = lhs.broadcast(to: rhs.shape) {
            return broadcasted.divide(by: lhs)
        } else if let broadcasted = rhs.broadcast(to: lhs.shape) {
            return lhs.divide(by:broadcasted)
        } else {
            fatalError("Size error")
        }
    }
    
    private func divide(by matrix: Matrix) -> Matrix {
        precondition(matrix.shape == shape)
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vdivD(matrix.values, 1, values, 1, &result, 1, vDSP_Length(values.count))
        return Matrix(values: result, shape: shape)
    }
    
    public func dot(_ rMatrix: Matrix) -> Matrix {
        precondition(shape.columns == rMatrix.shape.rows)
        let newShape = Shape(rows: shape.rows, columns: rMatrix.shape.columns)
        var result = [Double](repeating : 0.0, count : newShape.elements)
        vDSP_mmulD(values, 1, rMatrix.values, 1, &result, 1, vDSP_Length(shape.rows), vDSP_Length(rMatrix.shape.columns), vDSP_Length(shape.columns))
        return Matrix(values: result, shape: newShape)
    }
    
    public func log() -> Matrix {
        return Matrix(values: values.map { Darwin.log($0) }, shape: shape)
    }
    
    public func invertSign() -> Matrix {
        return Matrix(values: values.map { -$0 }, shape: shape)
    }
    
    public func sum(direction: SumDirection) -> Matrix {
        switch direction {
        case .rows:
            var results = [Double]()
            for i in 0..<shape.rows {
                guard shape.columns > 1 else {
                    return self
                }
                let row = Array<Double>(values[(i * shape.columns)..<((i + 1) * shape.columns)])
                var result = 0.0
                vDSP_sveD(row, 1, &result, vDSP_Length(row.count))
                results.append(result)
            }
            return Matrix(values: results, shape: Shape(rows: results.count, columns: 1))
        case .columns:
            var results = [Double]()
            for _ in 0..<shape.columns {
                var result = 0.0
                vDSP_sveD(values, shape.rows, &result, vDSP_Length(shape.columns))
                results.append(result)
            }
            return Matrix(values: results, shape: Shape(rows: 1, columns: results.count))
            
        }
    }
}
