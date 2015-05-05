//
//  WeaponData.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 4/8/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation


// Information about each weapon
class WeaponData: NSObject, NSCoding {
    var name: String!
    var level: Int!
    var sublevel:Int!
    var unlocked:Bool!
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(name: "error")
        self.name = aDecoder.decodeObjectForKey("name") as? String
        self.level = aDecoder.decodeIntegerForKey("level")
        self.sublevel = aDecoder.decodeIntegerForKey("sublevel")
        self.unlocked = aDecoder.decodeBoolForKey("unlocked")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name!, forKey: "name")
        aCoder.encodeInteger(self.level!, forKey: "level")
        aCoder.encodeInteger(self.sublevel!, forKey: "sublevel")
        aCoder.encodeBool(self.unlocked!, forKey: "unlocked")
    }
    
    init(name: String) {
        self.name = name
        self.level = 1
        self.sublevel = 1
        self.unlocked = false
    }
    
    func unlock() {
        self.unlocked = true
    }
    
    func upgrade() {
        self.sublevel!++
        if sublevel == 3 {
            sublevel == 0
            self.level!++
        }
    }
}