//
//  GameData.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 4/6/15.
//  Copyright (c) 2015 Carlos Beltran. All rights reserved.
//

import Foundation

// GameData is a wrapper for all the properties of the game that should be saved
// @param currentPlanet - To set up the right background
// @param currentProgress - To get the current progress (%)
// @param equippedWeaponName - Get the weapon the user has equipped
//
// The amount of currency the player has saved up
// @param goldAmount
// @param silverAmount
// @param platinumAmount
//
// Save the amount of "days" it took the player the complete the planet
// Display this information on the overall map of progress
// [0] corresponds to the days it took to complete planet 0, etc.
// @param planetStats
//
// SettingName:Value
// @param settings
//
// Key: WeaponData
// Information about all the weapons (unlocked, level)
// @param weaponInventory
class GameData: NSObject, NSCoding {
    
    var currentPlanet: String?
    var currentProgress: Int?
    var equippedWeaponName: String?
    var goldAmount: Int?
    var silverAmount: Int?
    var platinumAmount: Int?
    var planetStats: [Int]?
    var settings : [String: Int]?
    var weaponInventory: [String: WeaponData]?
    var baseStates: [String: Int]?
    
    // If a file with the information in this class does not exist, create an instance
    override init() {
        super.init()
        self.currentPlanet = "firstPlanet"
        self.currentProgress = 1
        self.equippedWeaponName = "missile_launcher"
        self.goldAmount = 0
        self.silverAmount = 0
        self.platinumAmount = 0
        self.planetStats = [0, 0, 0]
        self.settings = ["MusicVolume" : 100] // TODO: Add more settings!
        var weapons = setupWeapons()
        self.weaponInventory = [String:WeaponData]()
        self.baseStates = ["hangar-": 0, "dome-": 0, "lab-": 0]
        
        for w in weapons {
            self.weaponInventory![w.name!] = w
        }
    }
    
    // Sets up the dictionary of weapon data for the first time
    // Unlocks missile_launcher-1
    func setupWeapons() -> [WeaponData] {
        var array:[WeaponData] = []
        
        var mg1 = WeaponData(name: "machine_gun")

        var m1 = WeaponData(name: "missile_launcher")
        
        var l1 = WeaponData(name: "laser")
        
        var rg1 = WeaponData(name: "rail_gun")
        
        mg1.unlock()
        
        array.append(mg1)
        array.append(m1)
        array.append(l1)
        array.append(rg1)

        return array
    }
    
    // ¯\_(ツ)_/¯
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self.currentPlanet = aDecoder.decodeObjectForKey("currentPlanet") as? String
        self.currentProgress = aDecoder.decodeIntegerForKey("currentProgress")
        self.equippedWeaponName = aDecoder.decodeObjectForKey("equippedWeaponName") as? String
        self.goldAmount = aDecoder.decodeIntegerForKey("goldAmount")
        self.silverAmount = aDecoder.decodeIntegerForKey("silverAmount")
        self.platinumAmount = aDecoder.decodeIntegerForKey("platinumAmount")
        self.planetStats = aDecoder.decodeObjectForKey("planetStats") as? [Int]
        self.settings = aDecoder.decodeObjectForKey("settings") as? [String: Int]
        self.weaponInventory = aDecoder.decodeObjectForKey("weaponInventory") as? [String: WeaponData]
        self.baseStates = aDecoder.decodeObjectForKey("baseStates") as? [String: Int]
        
    }
    
    // ¯\_(ツ)_/¯
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.currentPlanet, forKey: "currentPlanet")
        aCoder.encodeInteger(self.currentProgress!, forKey: "currentProgress")
        aCoder.encodeObject(self.equippedWeaponName, forKey: "equippedWeaponName")
        aCoder.encodeInteger(self.goldAmount!, forKey: "goldAmount")
        aCoder.encodeInteger(self.silverAmount!, forKey: "silverAmount")
        aCoder.encodeInteger(self.platinumAmount!, forKey: "platinumAmount")
        aCoder.encodeObject(self.planetStats, forKey: "planetStats")
        aCoder.encodeObject(self.settings, forKey: "settings")
        aCoder.encodeObject(self.weaponInventory, forKey: "weaponInventory")
        aCoder.encodeObject(self.baseStates, forKey: "baseStates")
    }
    
    // Should return a path to the file we want, the only one that should be there!
    class func documentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let string = paths[0] as! NSString
        return string
    }
    
    class func getFilePath() -> NSString {
        var filepath = documentsDirectory().stringByAppendingPathComponent("gameData")
        return filepath
    }
    
}