//
//  APIResponse.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//


struct ApiResponse<T: Codable>: Codable {
    let status: String
    let message: String?
    let data: T
}
