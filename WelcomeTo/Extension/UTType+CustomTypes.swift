//
//  UTType+CustomTypes.swift
//  WelcomeTo
//
//  Created by thierryH24 on 05/08/2025.
//

import UniformTypeIdentifiers
import SwiftUI

extension UTType {
    static var sqlite: UTType {
        UTType(filenameExtension: "sqlite") ?? .data
    }
    static var store: UTType {
        UTType(filenameExtension: "store") ?? .data
    }
}
