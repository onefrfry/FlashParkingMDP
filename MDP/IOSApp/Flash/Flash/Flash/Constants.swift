//
//  Constants.swift
//  Flash
//
//  Created by Sam Bohnett on 3/29/22.
//

import Foundation
import UIKit

/*
 Delegate that is used between some of the subViews to interact with view1 and view2 controllers
 */
protocol SetupDelegate {
    func changeLabels(for inputs: [String])
    func toggleBlur(_ toggle: Bool)
    func removeView()
    func changeButtons(_ sender: Any)
    func runTestMain()
}

protocol NavigateDelegate {
    func reloadAllMapCollectionViewCells(on: Int, with: UICollectionView)
    func imageTranslation(on openedCell: MapCell, _ stringVal: String)
}
 
/*
struct Coord {
    var z: Int //floor
    var y: Int //row
    var x: Int//col
};
 */
/*
struct Tile {
    var value: CChar
    var reachedByGoing: CChar
    var directionToCar: CChar
    var discovered: Bool
};
 */

/*
 Helpful constants for ease of use and minimizes typos
 */
struct Constants {
    static let localized = "moveToFind";
    static let navigation = "moveToNav";
    static let newCell = "PCell";
    static let nibName = "ParkingCell"
    static let floorButton = "FloorButton"
    static let floorCell = "FloorCell"
    static let mapCell = "MapCell"
    static let view2Controller = "homeSideScreen"
    static let mapScrollCell = "mapScrollCell"
    static let cCharE = ("E".cString(using: String.Encoding.utf8)?[0])!
    static let cCharP = ("P".cString(using: String.Encoding.utf8)?[0])!
    static let cCharX = ("X".cString(using: String.Encoding.utf8)?[0])!
    static let cCharS = ("S".cString(using: String.Encoding.utf8)?[0])!
    static let cCharC = ("C".cString(using: String.Encoding.utf8)?[0])!
}
