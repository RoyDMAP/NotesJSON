//
//  JSONFile.swift
//  NotesJSON
//
//  Created by Roy Dimapilis on 9/13/25.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreData

public struct JSONFile: FileDocument {
    public static var readableContentTypes: [UTType] = [.json]
    public var data: Data

    public init(data: Data = Data()) {
        self.data = data
    }

    public init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
