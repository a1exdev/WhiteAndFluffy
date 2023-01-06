//
//  ViewLoadable.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 05.01.2023.
//

import UIKit

public protocol ViewLoadable {
    
    associatedtype MainView: UIView
}
 
extension ViewLoadable where Self: UIViewController {
    // The UIViewController's custom view
    public var mainView: MainView {
        guard let customView = view as? MainView else {
            fatalError("Expected view to be of type \(MainView.self) but got \(type(of: view)) instead")
        }
        return customView
    }
}

open class ViewController<ViewType: UIView>: UIViewController, ViewLoadable {
    
    public typealias MainView = ViewType
    
    open override func loadView() {
        let customView = MainView()
        view = customView
    }
}
