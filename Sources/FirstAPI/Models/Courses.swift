//
//  Courses.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor
import Fluent

enum CourseType: String, Codable {
    case smp = "Swift Mastery Program"
    case sdp = "Swift Developer Program"
    case vdp = "Vision Developer Program"
    case sap = "Swift Accessibilty Program"
}

final class Courses: Model, Content, @unchecked Sendable {
    static let schema = "courses"
    
    @ID(custom: .id) var id: Int?
    @Field(key: "name") var name: String
    @Enum(key: "type") var type: CourseType
    // Estos datos deben ser opcionales ya que se agregan al momento de creación o actualización. Por eso tampoco van en el constructor.
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    @Children(for: \.$course) var people: [Person]
    
    init() { }
    
    init(id: Int? = nil, name: String, type: CourseType) {
        self.id = id
        self.name = name
        self.type = type
    }
}
