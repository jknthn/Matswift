//
//  MatrixTests.swift
//  Matswift_example
//
//  Created by jknth on 01/09/2017.
//  Copyright © 2017 Jeremi Kaczmarczyk. All rights reserved.
//

import XCTest
@testable import Matswift

class ShapeTests: XCTestCase {
    
    func testEquatable() {
        XCTAssertEqual(Shape(rows: 1, columns: 2), Shape(rows: 1, columns: 2))
    }
    
    func testTranspose() {
        XCTAssertEqual(Shape(rows: 1, columns: 2), Shape(rows: 2, columns: 1).T)
    }
    
    func testElements() {
        XCTAssertEqual(Shape(rows: 2, columns: 2).elements, 4)
    }
}

class MatrixTests: XCTestCase {
    
    func testInit() {
        let matrix1 = Matrix(values: [1.0, 2.0, 3.0, 4.0], shape: Shape(rows: 2, columns: 2))
        let matrix2 = Matrix(values: [[1.0, 2.0], [3.0, 4.0]])
        
        let values = [1.0, 2.0, 3.0, 4.0]
        let shape = Shape(rows: 2, columns: 2)
        
        XCTAssertEqual(matrix1.values, values)
        XCTAssertEqual(matrix1.shape, shape)
        XCTAssertEqual(matrix2.values, values)
        XCTAssertEqual(matrix2.shape, shape)
        XCTAssertEqual(matrix1, matrix2)
    }
    
    func testScalarAddition() {
        let matrix = Matrix(values: [[1.0, 2.0], [3.0, 4.0]])
        let result = Matrix(values: [[2.0, 3.0], [4.0, 5.0]])
        
        XCTAssertEqual(matrix + 1.0, result)
        XCTAssertEqual(1.0 + matrix, result)
    }
    
    func testScalarMultiplication() {
        let matrix = Matrix(values: [[1.0, 2.0], [3.0, 4.0]])
        let result = Matrix(values: [[2.0, 4.0], [6.0, 8.0]])
        
        XCTAssertEqual(matrix * 2.0, result)
        XCTAssertEqual(2.0 * matrix, result)
    }
    
    func testBroadcasting() {
        let result1Matrix = Matrix(values: [[1.0, 2.0], [1.0, 2.0], [1.0, 2.0], [1.0, 2.0]])
        let matrix1 = Matrix(values: [[1.0, 2.0], [1.0, 2.0]])
        
        let result2Matrix = Matrix(values: [Double](repeating: 0.0, count: 12), shape: Shape(rows: 3, columns: 4))
        let matrix2 = Matrix(values: [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0]])
        
        XCTAssertEqual(matrix1.broadcast(to: result1Matrix.shape), result1Matrix)
        XCTAssertEqual(matrix2.broadcast(to: result2Matrix.shape), result2Matrix)
        XCTAssertNil(matrix1.broadcast(to: result2Matrix.shape))
        XCTAssertNil(matrix2.broadcast(to: result1Matrix.shape))
    }
    
    func testAddition() {
        let matrix1 = Matrix(values: [[1.0, 1.0], [1.0, 1.0]])
        let matrix2 = Matrix(values: [[1.0, 1.0], [1.0, 1.0]])
        let matrix3 = Matrix(values: [[1.0, 1.0]])
        let matrix4 = Matrix(values: [[1.0], [1.0]])
        
        
        let resultMatrix = Matrix(values: [[2.0, 2.0], [2.0, 2.0]])
        
        XCTAssertEqual(matrix1 + matrix2, resultMatrix)
        XCTAssertEqual(matrix1 + matrix3, resultMatrix)
        XCTAssertEqual(matrix1 + matrix4, resultMatrix)
        XCTAssertEqual(matrix2 + matrix1, resultMatrix)
        XCTAssertEqual(matrix3 + matrix1, resultMatrix)
        XCTAssertEqual(matrix4 + matrix1, resultMatrix)
    }
    
    func testSum() {
        let matrix1 = Matrix(values: [[1.0, 2.0], [1.0, 2.0]])
        let matrix2 = Matrix(values: [[1.0, 1.0], [1.0, 1.0]])
        let matrix3 = Matrix(values: [[1.0, 1.0]])
        
        XCTAssertEqual(matrix1.sum(), 6.0)
        XCTAssertEqual(matrix2.sum(), 4.0)
        XCTAssertEqual(matrix3.sum(), 2.0)
    }
    
    func testMultiplication() {
        let matrix1 = Matrix(values: [[1.0, 1.0], [1.0, 1.0]])
        let matrix2 = Matrix(values: [[2.0, 2.0], [2.0, 2.0]])
        let matrix3 = Matrix(values: [[2.0, 2.0]])
        let matrix4 = Matrix(values: [[2.0], [2.0]])
        
        
        let resultMatrix = Matrix(values: [[2.0, 2.0], [2.0, 2.0]])
        
        XCTAssertEqual(matrix1 * matrix2, resultMatrix)
        XCTAssertEqual(matrix1 * matrix3, resultMatrix)
        XCTAssertEqual(matrix1 * matrix4, resultMatrix)
        XCTAssertEqual(matrix2 * matrix1, resultMatrix)
        XCTAssertEqual(matrix3 * matrix1, resultMatrix)
        XCTAssertEqual(matrix4 * matrix1, resultMatrix)
    }
    
    func testTraspose() {
        let matrix = Matrix(values: [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
        let result = Matrix(values: [[1.0, 4.0], [2.0, 5.0], [3.0, 6.0]])
        
        XCTAssertEqual(matrix.T, result)
    }
    
    func testDot() {
        let matrix = Matrix(values: [3.0, 2.0, 4.0, 5.0, 6.0, 7.0], shape: Shape(rows: 3, columns: 2))
        let matrix2 = Matrix(values: [10.0, 20.0, 30.0, 30.0, 40.0, 50.0], shape: Shape(rows: 2, columns: 3))
        
        let result = Matrix(values: [90.0, 140.0, 190.0, 190.0, 280.0, 370.0, 270.0, 400.0, 530.0], shape: Shape(rows: 3, columns: 3))
        
        XCTAssertEqual(matrix.dot(matrix2), result)
    }
    
    func testLog() {
        let matrix = Matrix(values: [3.0, 2.0, 4.0, 5.0], shape: Shape(rows:2, columns: 2))
        let result = Matrix(values: [log(3.0), log(2.0), log(4.0), log(5.0)], shape: Shape(rows: 2, columns: 2))
        
        XCTAssertEqual(matrix.log(), result)
    }
    
    func testInvertSign() {
        let matrix = Matrix(values: [3.0, -2.0, 4.0, -5.0], shape: Shape(rows:2, columns: 2))
        let result = Matrix(values: [-3.0, 2.0, -4.0, 5.0], shape: Shape(rows:2, columns: 2))
        
        XCTAssertEqual(matrix.invertSign(), result)
    }
    
    func testScalarSubtraction() {
        let matrix = Matrix(values: [[1.0, 2.0], [3.0, 4.0]])
        let result1 = Matrix(values: [[0.0, 1.0], [2.0, 3.0]])
        let result2 = Matrix(values: [[1.0, 0.0], [-1.0, -2.0]])
        
        XCTAssertEqual(matrix - 1.0, result1)
        XCTAssertEqual(2.0 - matrix, result2)
    }
    
    func testMatrixSubtraction() {
        let matrix1 = Matrix(values: [[1.0, 2.0], [3.0, 2.0]])
        let matrix2 = Matrix(values: [[0.0, 1.0], [2.0, 3.0]])
        let result = Matrix(values: [[1.0, 1.0], [1.0, -1.0]])
        
        XCTAssertEqual(matrix1 - matrix2, result)
    }
    
    func testDirectionalSum() {
        let matrix = Matrix(values: [[1.0, 2.0], [3.0, 2.0]])
        let rowResult = Matrix(values: [[3.0], [5.0]])
        let columnResult = Matrix(values: [[4.0, 4.0]])
        
        
        XCTAssertEqual(matrix.sum(direction: .rows), rowResult)
        XCTAssertEqual(matrix.sum(direction: .columns), columnResult)
    }
    
    func testMatrixDivision() {
        let matrix = Matrix(values: [[1.0, 2.0], [3.0, 2.0]])
        let divisor1 = Matrix(values: [[2.0, 2.0], [2.0, 2.0]])
        let divisor2 = Matrix(values: [[2.0, 2.0]])
        
        let result = Matrix(values: [[0.5, 1.0], [1.5, 1.0]])
        
        XCTAssertEqual(matrix / divisor1, result)
        XCTAssertEqual(matrix / divisor2, result)
    }
}

