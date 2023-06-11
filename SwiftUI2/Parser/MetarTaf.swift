//
//  METAR.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import Foundation
import JavaScriptCore

class MetarTaf {
    static let shared = MetarTaf()
    
    private let vm = JSVirtualMachine()
    private let context: JSContext
    
    private init() {
        let jsCode = try? String.init(contentsOf: Bundle.main.url(forResource: "MetarTafParser.bundle", withExtension: "js")!)
        
        context = JSContext(virtualMachine: vm)
        context.evaluateScript(jsCode)
    }
    
    func parseMetar(_ data: String) async -> METAR? {
        let jsModule = self.context.objectForKeyedSubscript("MetarTafParser")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("MetarTafParser")
        if let result = jsAnalyzer?.invokeMethod("parseMetar", withArguments: [data]) {
            let jsonString = result.toString()
            let jsonData = jsonString!.data(using: .utf8)!
            do {
                var metar = try JSONDecoder().decode(METAR.self, from: jsonData)
                metar.rawString = data
                
                return metar
            } catch {
                // Failed to decode JSON or encountered an error
                print("Error decoding JSON: ", error)
            }
            
            return nil
        }
        
        return nil
    }
    
    func getFlightCategory(_ metar: String) -> String {
        let jsModule = self.context.objectForKeyedSubscript("MetarTafParser")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("MetarTafParser")
        if let result = jsAnalyzer?.invokeMethod("getFlightCategory", withArguments: [metar]) {
            let flightCategory = result.toString() ?? "N/A"
            
            return flightCategory
        }
        
        return "N/A"
    }
    
    func formatFlightCategory(_ category: String) -> String {
        let jsModule = self.context.objectForKeyedSubscript("MetarTafParser")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("MetarTafParser")
        if let result = jsAnalyzer?.invokeMethod("formatFlightCategory", withArguments: [category]) {
            let formattedCategory = result.toString() ?? "N/A"
            
            return formattedCategory
        }
        
        return "N/A"
    }
    
    func formatClouds(_ metar: String) -> String {
        let jsModule = self.context.objectForKeyedSubscript("MetarTafParser")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("MetarTafParser")
        if let result = jsAnalyzer?.invokeMethod("formatClouds", withArguments: [metar]) {
            let formattedClouds = result.toString() ?? "N/A"
            
            return formattedClouds
        }
        
        return "N/A"
    }
    
    func formatVisibility(_ metar: String) -> String {
        let jsModule = self.context.objectForKeyedSubscript("MetarTafParser")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("MetarTafParser")
        if let result = jsAnalyzer?.invokeMethod("formatVisibility", withArguments: [metar]) {
            let formattedVisibility = result.toString() ?? "N/A"
            
            return formattedVisibility
        }
        
        return "N/A"
    }
}
