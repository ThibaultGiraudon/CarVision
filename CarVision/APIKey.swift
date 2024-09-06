//
//  APIKey.swift
//  CarVision
//
//  Created by Thibault Giraudon on 29/08/2024.
//

import Foundation

enum APIKey {
	static var `default`: String {
		
		guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
		else {
			print("Couldn't find file 'GenerativeAI-Info.plist'.")
			return ""
		}
		
		let plist = NSDictionary(contentsOfFile: filePath)
		
		guard let value = plist?.object(forKey: "API_KEY") as? String else {
			print("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
			return ""
		}
		
		if value.starts(with: "_") {
			print(
				"Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
			)
			return ""
		}
		
		return value
	}
}
