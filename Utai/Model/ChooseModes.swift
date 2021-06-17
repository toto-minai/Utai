//
//  ChooseMode.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/17.
//

import Foundation

enum ShowMode: Int, Identifiable {
    case master, release, both
    
    var id: Int { rawValue }
}
enum SortMode { case none, year }
