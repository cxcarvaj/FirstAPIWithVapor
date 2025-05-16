//
//  CoursesController.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor
import Fluent

struct CoursesController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("courses")
        
        api.post("create", use: createCourse)
        api.get("all", use: getCourses)
        api.get("allPretty", use: getCoursesPretty)
        api.get("coursesWithStudents", use: getCoursesWithRegisteredStudents)
        api.post("registerStudent", use: registerStudent)
        api.get("people",":courseId" , use: getPeopleByCourse)
        api.get("peopleWithCourse",":courseId" , use: getPeopleWithCourse)
        api.get("getPeopleByCourse",":courseId" , use: getPeopleByCourse)
        api.get("getPeopleByCourseQuery", use: getPeopleByCourseQuery)
    }
    
    
    func createCourse(_ req: Request) async  throws -> HTTPStatus {
        let newCourse = try req.content.decode(Courses.self)
        if let curso = try await Courses.find(newCourse.id, on: req.db) {
            curso.name = newCourse.name
            curso.type = newCourse.type
            try await curso.update(on: req.db)
        } else {
            try await newCourse.create(on: req.db)
        }
        return .created
    }
    
    func getCourses(_ req: Request) async throws -> [CourseDTO] {
        try await Courses
            .query(on: req.db)
            .all()
            .map(\.toDTO)
    }
    
    func getCoursesPretty(_ req: Request) async throws -> [CourseDTO] {
       try await Courses
            .query(on: req.db)
            .with(\.$people)
            .all()
            .map { course in
                CourseDTO(id: course.id,
                          name: course.name,
                          type: course.type,
                          people: course.people.count > 0 ? course.people.map(\.toDTO) : nil)
            }
        
    }
    
    func getCoursesWithRegisteredStudents(_ req: Request) async throws -> [Courses] {
        try await Courses
            .query(on: req.db)
            .with(\.$people)
            .all()
    }
    
    func registerStudent(_ req: Request) async throws -> HTTPStatus {
        let registration = try req.content.decode(RegistrationDTO.self)
        
        guard let course = try await Courses.find(registration.id, on: req.db) else {
            throw Abort(.notFound, reason: "The course \(registration.id) does not exist")
        }
        if let person = try await Person.query(on: req.db)
            .filter(\.$email == registration.email)
            .first() {
            
            person.$course.id = course.id
            try await person.update(on: req.db)
            
        } else {
            throw Abort(.notFound, reason: "The student \(registration.email) does not exist")
        }
        
        return .accepted
    }
    
    func getPeopleWithCourse(_ req: Request) async throws -> CourseDTO {
        let courseID = try req.parameters.require("courseId", as: Int.self)
        guard let course = try await Courses.find(courseID, on: req.db) else {
            throw Abort(.notFound, reason: "Course \(courseID) does not exist")
        }
        try await course.$people.load(on: req.db) // Es lo mismo que hacer un query.with para cargar las relaciones
        return CourseDTO(id: course.id, name: course.name, type: course.type, people: course.people.map(\.toDTO))
    }
    
    //Este metodo abre 2 conexiones a la DB
    func getPeopleByCourse(_ req: Request) async throws -> [PersonDTO] {
        let courseID = try req.parameters.require("courseId", as: Int.self)
        guard let course = try await Courses.find(courseID, on: req.db) else {
            throw Abort(.notFound, reason: "Course \(courseID) does not exist")
        }
        try await course.$people.load(on: req.db) // Es lo mismo que hacer un query.with para cargar las relaciones
        return course.people.map(\.toDTO)
    }
    
    func getPeopleByCourseQuery(_ req: Request) async throws -> [PersonDTO] {
        guard let id = req.query[Int.self, at: "course"] else {
            throw Abort(.badRequest, reason: "There is no course id as query param")
        }
        
        return try await Person
            .query(on: req.db)
            .join(Courses.self, on: \Person.$course.$id == \Courses.$id, method: .left)
            .filter(Courses.self, \.$id == id)
            .with(\.$course)
            .all()
            .map(\.toDTO)
    }

}
