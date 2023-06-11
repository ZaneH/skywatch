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
        if let result = jsAnalyzer?.invokeMethod("parseMetar", withArguments: [data]),
           let jsonString = result.toString(),
           let jsonData = jsonString.data(using: .utf8) {
            do {
                let metar = try JSONDecoder().decode(METAR.self, from: jsonData)
                return metar
            } catch {
                // Failed to decode JSON or encountered an error
                print("Error decoding JSON: ", error)
            }
        } else {
            // Invalid JSON object returned from method invocation
            print("Invalid parser response")
        }
        
        return nil
    }
}
