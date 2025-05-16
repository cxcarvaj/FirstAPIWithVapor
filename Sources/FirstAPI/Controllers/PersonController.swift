//
//  PersonController.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 14/5/25.
//

import Vapor
import Fluent

struct PersonController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let groupedRoutes = routes.grouped("person")
        groupedRoutes.post("new", use: createPerson)
        groupedRoutes.get("all", use: getAll)
        groupedRoutes.get("allPretty", use: getAllPretty)
        groupedRoutes.put("update", use: updatePerson)
        groupedRoutes.delete("delete", use: deletePerson)
    }
    
    func createPerson(_ req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(PersonDTO.self)
        let newPerson = Person(name: dto.name, email: dto.email, address: dto.address)
        
        try await newPerson.create(on: req.db)
        return .created
    }
    
    func getAll(_ req: Request) async throws -> [Person] {
       try await Person.query(on: req.db)
            .with(\.$course)
            .all()
//            .map(\.toDTO)
    }
    
    func getAllPretty(_ req: Request) async throws -> [PersonDTO] {
       try await Person.query(on: req.db)
            .with(\.$course)
            .all()
            .map(\.toDTO)
    }
    
    func getPersonByEmail(_ req: Request) async throws -> PersonDTO {
        guard let email = req.query[String.self, at: "email"] else {
            throw Abort(.badRequest, reason: "There is no email as a search param")
        }
        
        if let person = try await Person.query(on: req.db)
            .filter(\.$email == email)
            .first() {
            return person.toDTO
        } else {
            throw Abort(.notFound, reason: "There is no person with that email")
        }
    }
    
    func updatePerson(_ req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(PersonDTO.self)
        guard let person = try await Person.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() else { throw Abort(.notFound) }
        
        person.address = dto.address
        person.name = dto.name
        try await person.update(on: req.db)

        return .ok
    }
    
    func deletePerson(_ req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(PersonDTO.self)
        let person = try await Person.query(on: req.db)
        //Usamos group para unir condiciones, si solo usamos .filter(cond1).filter(cond2) no es muy eficiente
            .group(.and) { group in
                group.filter(\.$email == dto.email)
                    .filter(\.$name == dto.name)
            }
            .first()
        guard let person else { throw Abort(.notFound, reason: "In order to delete a person, you need to provide both email and name") }
        
        try await person.delete(on: req.db)

        return .ok
    }
}
