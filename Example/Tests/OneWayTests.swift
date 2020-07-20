//
//  OneWayTests.swift
//  AwesomeKeyPath_Tests
//
//  Created by Tonny on 20/07/20.
//  Copyright © 2020 Tonny. All rights reserved.
//  Github: https://github.com/tonnylitao/AwesomeKeyPath
//

import XCTest
import AwesomeKeyPath

class OneWayTests: XCTestCase {
    var lbl: UILabel!
    var field: UITextField!
    var viewModel: KPDataBindingViewModel<User>!
    
    
    override func setUpWithError() throws {
        lbl = UILabel()
        field = UITextField()
        
        viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User(), [
            lbl     <- \.name,
            field   <- \.email
        ])
    }

    override func tearDownWithError() throws {
        viewModel.unbind(\.name)
    }

    func testInitial() throws {
        XCTAssertNil(viewModel.model.name)
        XCTAssertNil(lbl.text)
        
        XCTAssertNil(viewModel.model.email)
        XCTAssert(field.text == "")
    }
    
    func testInitialWithData() throws {
        let lbl = UILabel()
        let field = UITextField()
        let viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User.random, [
            lbl     <- \.name,
            field   <- \.email
        ])
        
        XCTAssert(lbl.text == viewModel.model.name)
        XCTAssert(field.text == viewModel.model.email)
    }
    
    func testUpdate() throws {
        let text = String.random
        
        viewModel.update(\.name, with: text)
        XCTAssert(viewModel.model.name == text)
        XCTAssert(lbl.text == text)
        
        viewModel.update(\.name, with: nil)
        XCTAssertNil(viewModel.model.name)
        XCTAssertNil(lbl.text)
        
        //
        viewModel.update(\.email, with: text)
        XCTAssert(viewModel.model.email == text)
        XCTAssert(field.text == text)
        
        viewModel.update(\.email, with: nil)
        XCTAssertNil(viewModel.model.email)
        XCTAssert(field.text == "")
    }
    
    func testUnbind() throws {
        viewModel.unbind(\.name)
        XCTAssertFalse(viewModel.update(\.name, with: String.random))
    }
    
    func testOneFieldToManyView() throws {
        let view1 = UILabel()
        let view2 = UILabel()
        let view3 = UITextField()
        
        let viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User.random, [
            view1    <- \.name,
            view2    <- \.name,
            view3    <- \.name
        ])
        
        XCTAssert(view1.text == viewModel.model.name)
        XCTAssert(view2.text == viewModel.model.name)
        XCTAssert(view3.text == viewModel.model.name)
        
        let text = String.random
        viewModel.update(\.name, with: text)
        XCTAssert(view1.text == text)
        XCTAssert(view2.text == text)
        XCTAssert(view3.text == text)
        
        viewModel.update(\.name, with: nil)
        XCTAssertNil(view1.text)
        XCTAssertNil(view2.text)
        XCTAssert(view3.text == "")
    }
    
    func testManyFieldToOneView() throws {
        let lbl = UILabel()
        
        let viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User.random, [
            lbl    <- \.name,
            lbl    <- \.email,
            lbl    <- \.groupName
        ])
        
        XCTAssert(lbl.text == viewModel.model.groupName)
        
        viewModel.update(\.name, with: String.random)
        XCTAssert(lbl.text == viewModel.model.name)
        
        viewModel.update(\.email, with: String.random)
        XCTAssert(lbl.text == viewModel.model.email)
        
        viewModel.update(\.groupName, with: String.random)
        XCTAssert(lbl.text == viewModel.model.groupName)
    }
    
    func testOneFormat() throws {
        let text = String.random
        
        let lbl = UILabel()
        
        let viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User.random, [
            lbl    <~ (\.name, { $0.text = ($1 ?? "") + text }),
        ])
        
        XCTAssert(lbl.text == (viewModel.model.name ?? "") + text)
        
        viewModel.update(\.name, with: String.random)
        XCTAssert(lbl.text == (viewModel.model.name ?? "") + text)
        
        viewModel.update(\.name, with: nil)
        XCTAssert(lbl.text == text)
    }
    
    func testMultileFormat() throws {
        let text1 = String.random
        let text2 = String.random
        
        let lbl = UILabel()
        let field = UITextField()
        
        let viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User.random, [
            lbl    <~ (\.name, { $0.text = ($1 ?? "") + text1 }),
            field  <~ (\.name, { $0.text = ($1 ?? "") + text2 }),
        ])
        
        XCTAssert(lbl.text == (viewModel.model.name ?? "") + text1)
        XCTAssert(field.text == (viewModel.model.name ?? "") + text2)
        
        viewModel.update(\.name, with: String.random)
        XCTAssert(lbl.text == (viewModel.model.name ?? "") + text1)
        XCTAssert(field.text == (viewModel.model.name ?? "") + text2)
        
        viewModel.update(\.name, with: nil)
        XCTAssert(lbl.text == text1)
        XCTAssert(field.text == text2)
    }
    
    func testOtherFormat() throws {
        let lbl = UILabel()
        
        let viewModel = KPDataBindingViewModel<User>()
        
        viewModel.bind(User(), [
            KPOneWayBinding(lbl, \User.name, { $0.layer.cornerRadius = CGFloat(Float($1 ?? "0") ?? 0) })
        ])
        
        XCTAssert(lbl.layer.cornerRadius == 0)
        
        let random = CGFloat.random(in: 0...1000)
        viewModel.update(\.name, with: "\(random)")
        XCTAssert(lbl.layer.cornerRadius == CGFloat(Float("\(random)") ?? 0))
        
        viewModel.update(\.name, with: nil)
        XCTAssert(lbl.layer.cornerRadius == 0)
    }
}
