//
//  Matrix.swift
//  Matswift
//
//  Created by jknthn on 22/09/2017.
//  Copyright © 2017 Jeremi Kaczmarczyk (jeremi.kaczmarczyk@gmail.com)
//

import Foundation
import Accelerate
import GameplayKit

/// Type describing 2-dimensional matrix
public struct Matrix {
    
    /// Transpose operation
    public var T: Matrix {
        let newShape = shape.T
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_mtransD(values, 1, &result, 1, vDSP_Length(newShape.rows), vDSP_Length(newShape.columns))
        return Matrix(values: result, shape: newShape)
    }
    
    /// Flat array of `Matrix`s values
    public let values: [Double]
    
    /// Shape of the `Matrix`
    public let shape: Shape
    
    /// Initialization with visual representation of values as array of rows
    ///
    /// - parameter values:     Array of rows
    public init(values: [[Double]]) {
        self.values = values.reduce([Double](), +)
        self.shape = Shape(rows: values.count, columns: values[0].count)
    }
    
    /// Initialization with flat array of values and shape
    ///
    /// - parameter values:     Flat array of values
    /// - parameter shape:      Desired shape
    public init(values: [Double], shape: Shape) {
        precondition(values.count == shape.elements)
        self.values = values
        self.shape = shape
    }
    
    /// Function creating `Matrix` of zeroes
    ///
    /// - parameter shape:      Desired shape
    ///
    /// - returns:              `Matrix` filled with 0.0 values
    public static func zeros(shape: Shape) -> Matrix {
        let values = [Double](repeating : 0.0, count : shape.elements)
        return Matrix(values: values, shape: shape)
    }
    
    /// Function creating `Matrix` with random, uniform values
    ///
    /// - parameter shape:      Desired shape
    /// - parameter multiplier: Changes default 0.0 - 1.0 range of values
    ///
    /// - returns:              `Matrix` filled with random values
    public static func random(shape: Shape, multiplier: Double = 1.0) -> Matrix {
        var values = [Double]()
        let distribution = GKRandomDistribution(lowestValue: 0, highestValue: 1000)
        for _ in 0..<shape.elements {
            values.append(Double(distribution.nextUniform()) * multiplier)
        }
        return Matrix(values: values, shape: shape)
    }
}

/// `Matrix` - `Double` operators
extension Matrix {
    
    /// Addition operation. Scalar is added to every element of `Matrix`
    public static func +(lhs: Matrix, rhs: Double) -> Matrix{
        return lhs.addScalar(rhs)
    }
    
    /// Addition operation. Scalar is added to every element of `Matrix`
    public static func +(lhs: Double, rhs: Matrix) -> Matrix {
        return rhs.addScalar(lhs)
    }
    
    /// Subtraction operation. Scalar is subtracted from every element of `Matrix`
    public static func -(lhs: Matrix, rhs: Double) -> Matrix{
        return lhs + (-rhs)
    }
    
    /// Subtraction operation. Scalar is subtracted from every element of `Matrix`
    public static func -(lhs: Double, rhs: Matrix) -> Matrix {
        return lhs + rhs.invertSign()
    }
    
    /// Multiplication operation. Every element of `Matrix` is multiplied by scalar
    public static func *(lhs: Matrix, rhs: Double) -> Matrix{
        return lhs.multiplyByScalar(rhs)
    }
    
    /// Multiplication operation. Every element of `Matrix` is multiplied by scalar
    public static func *(lhs: Double, rhs: Matrix) -> Matrix {
        return rhs.multiplyByScalar(lhs)
    }
}

/// `Matrix` - `Matrix` operators
extension Matrix {
    
    /// Addition operation.
    /// If matrices shaped match corresponding elemens are added
    /// If either of the matrices can be broadcasted to other shape operation is performed with broadcasted `Matrix`
    /// Else the operation could not be performed
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
    
    /// Subtraction operation.
    /// If matrices shaped match corresponding elemens are subtracted
    /// If either of the matrices can be broadcasted to other shape operation is performed with broadcasted `Matrix`
    /// Else the operation could not be performed
    public static func -(lhs: Matrix, rhs: Matrix) -> Matrix {
        return lhs + rhs.invertSign()
    }
    
    /// Multiplication operation.
    /// If matrices shaped match corresponding elemens are multiplied
    /// If either of the matrices can be broadcasted to other shape operation is performed with broadcasted `Matrix`
    /// Else the operation could not be performed
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
    
    /// Division operation.
    /// If matrices shaped match corresponding elemens are divided
    /// If either of the matrices can be broadcasted to other shape operation is performed with broadcasted `Matrix`
    /// Else the operation could not be performed
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
}


/// Public functions
extension Matrix {
    
    /// Calculate dot product of matrices. `Matrix` calling this function is left side matrix in calculation
    ///
    /// - parameter rMatrix:    Right `Matrix` of the equation
    ///
    /// - returns:              `Matrix` result of dot product
    public func dot(_ rMatrix: Matrix) -> Matrix {
        precondition(shape.columns == rMatrix.shape.rows)
        let newShape = Shape(rows: shape.rows, columns: rMatrix.shape.columns)
        var result = [Double](repeating : 0.0, count : newShape.elements)
        vDSP_mmulD(values, 1, rMatrix.values, 1, &result, 1, vDSP_Length(shape.rows), vDSP_Length(rMatrix.shape.columns), vDSP_Length(shape.columns))
        return Matrix(values: result, shape: newShape)
    }
    
    /// Inverts sign of every element of the `Matrix`
    ///
    /// - returns:      `Matrix` with values of opposite sign
    public func invertSign() -> Matrix {
        return Matrix(values: values.map { -$0 }, shape: shape)
    }
    
    /// Sums every element of `Matrix`
    ///
    /// - returns:      `Double` result of summation
    public func sum() -> Double {
        var result = 0.0
        vDSP_sveD(values, 1, &result, vDSP_Length(values.count))
        return result
    }
    
    /// Enum describing whether summation occurs along columns or rows
    public enum SumDirection {
        case rows
        case columns
    }
    
    /// Sums rows or columns of a `Matrix`
    ///
    /// - parameter direction:      Controls if summation occurs along rows or columns
    ///
    /// - returns:                  `Matrix` of shape rows x 1 or 1 x columns depending on direction with summed elements
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
    
    /// Logarithm with the base of `e` of every element
    ///
    /// - returns:      `Matrix` with computed values
    public func log() -> Matrix {
        return Matrix(values: values.map { Darwin.log($0) }, shape: shape)
    }
    
    /// Broadcasting operation inspired by NumPy in python
    ///
    /// - parameter shape:      `Shape` off `Matrix` we want to fit into
    ///
    /// - returns:              `Matrix` in succeded, nil otherwise
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
}

/// Private functions
extension Matrix {
    
    /// Add scalar to `Matrix`
    ///
    /// - parameter scalar:     Value of scalar number
    ///
    /// - returns:              `Matrix` with scalar added to every element
    private func addScalar(_ scalar: Double) -> Matrix {
        var sc = scalar
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vsaddD(values, 1, &sc, &result, 1, vDSP_Length(result.count))
        return Matrix(values: result, shape: shape)
    }
    
    /// Multiply `Matrix` by scalar
    ///
    /// - parameter scalar:     Value of scalar number
    ///
    /// - returns:              `Matrix` every element multiplied by scalar
    private func multiplyByScalar(_ scalar: Double) -> Matrix {
        var sc = scalar
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vsmulD(values, 1, &sc, &result, 1, vDSP_Length(result.count))
        return Matrix(values: result, shape: shape)
    }
    
    /// Add `Matrix` to `Matrix`
    ///
    /// - parameter matrix:     Other `Matrix`
    ///
    /// - returns:              `Matrix`
    private func add(_ matrix: Matrix) -> Matrix {
        precondition(matrix.shape == shape)
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vaddD(values, 1, matrix.values, 1, &result, 1, vDSP_Length(values.count))
        return Matrix(values: result, shape: shape)
    }
    
    /// Multiply `Matrix` and `Matrix` element wise
    ///
    /// - parameter matrix:     Other `Matrix`
    ///
    /// - returns:              `Matrix`
    private func multiply(by matrix: Matrix) -> Matrix {
        precondition(matrix.shape == shape)
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vmulD(values, 1, matrix.values, 1, &result, 1, vDSP_Length(values.count))
        return Matrix(values: result, shape: shape)
    }
    
    /// Divide `Matrix` by `Matrix` element wise
    ///
    /// - parameter matrix:     Other `Matrix`
    ///
    /// - returns:              `Matrix`
    private func divide(by matrix: Matrix) -> Matrix {
        precondition(matrix.shape == shape)
        var result = [Double](repeating : 0.0, count : values.count)
        vDSP_vdivD(matrix.values, 1, values, 1, &result, 1, vDSP_Length(values.count))
        return Matrix(values: result, shape: shape)
    }
}

extension Matrix: Equatable {
    
    public static func ==(lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.values == rhs.values && lhs.shape == rhs.shape
    }
}
