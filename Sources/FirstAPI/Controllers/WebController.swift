//
//  WebController.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 16/5/25.
//

import Vapor
import Fluent
import Leaf


struct WebController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let web = routes.grouped("web")
        web.get("index", use: index)
        web.get("personWeb", use: personWeb)
        web.get("crearPersona", use: getCrearPersona)
        web.get("editarPersona", ":id", use: editPersona)
        web.post("editarPersona", use: editPersonPost)
        web.post("crearPersona", use: postCrearPersona)

    }
    
    
    func index(_ req: Request) async throws -> View {
        try await req.view.render("index", ["title": "Hello, World!"])
    }
    
    func personWeb(_ req: Request) async throws -> View {
        let query = try await Person
            .query(on: req.db)
            .all()
            .map {
                PersonWebDTO(id: $0.id, name: $0.name, email: $0.email, address: $0.address)
            }
        
        let context = PeopleWeb(title: "Maestro de Personas", people: query)
        
        return try await req.view.render("people", context)
    }
    
    func getCrearPersona(_ req: Request) async throws -> View {
        try await req.view.render("crearPersona", ["title": "Crear Persona"])
    }
    
    func editPersona(req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Es necesario indicar el ID de la persona.")
        }
        guard let persona = try await Person.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "No existe una persona con este ID.")
        }
        let context = PersonWeb(title: "Editar Persona",
                                 person: PersonWebDTO(id: persona.id,
                                                      name: persona.name,
                                                      email: persona.email,
                                                      address: persona.address))
        return try await req.view.render("editarPersona", context)
    }
    
    func editPersonPost(_ req: Request) async throws -> Response {
        let personRequest = try req.content.decode(PersonWebDTO.self)
        
        guard let person = try await Person.find(personRequest.id, on: req.db) else {
            let context = PersonWeb(title: "Editar Persona",
                                    person: personRequest,
                                    error: "No existe la persona con el ID indicado: \(String(describing: personRequest.id))")
            
            return try await req.view.render("editarPersona", context)
                .encodeResponse(for: req)
        }
        person.name = personRequest.name
        person.email = personRequest.email
        person.address = personRequest.address
        try await person.update(on: req.db)
        
        return req.redirect(to: "personWeb")
    }
    
    func postCrearPersona(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(PersonDTO.self)
        if try await !checkIfEmailExists(targetEmail: dto.email, req) {
            let newPerson = Person(name: dto.name, email: dto.email, address: dto.address)
            try await newPerson.create(on: req.db)
            
            return req.redirect(to: "personWeb")
        } else {
            return try await req.view.render("crearPersona", ["title": "Crear Persona", "error": "El email ya existe"])
                .encodeResponse(for: req)
        }
    }
    
    func checkIfEmailExists(targetEmail: String, _ req: Request) async throws -> Bool {
        let email = try await Person
            .query(on: req.db)
            .filter(\.$email == targetEmail)
            .first()
        
        return email != nil
    }
}
