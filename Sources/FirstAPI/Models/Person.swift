//
//  Person.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 14/5/25.
//

import Vapor
import Fluent

final class Person: Model, @unchecked Sendable {
    static let schema: String = "person"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String //Campo Obligatorio
    @Field(key: "email") var email: String
    @Field(key: "address") var address: String? //Campo Opcional
    
    //En este caso Courses es el padre en la relación Padre - Hijo que existe con People.
    //Ya que una persona, puede estar en un curso, es decir que en People vamos que tener que agregar un valor de Courses
//    @Parent(key: "course") var course: Courses //-> Con esto puedo tener cursos sin personas, pero no personas sin cursos.
    
    @OptionalParent(key: "course") var course: Courses? //-> Ahora puede tener cursos y personas sin tenerlas relacionadas
    
    init() {}
    
    init(id: UUID? = nil, name: String, email: String, address: String?, course: Courses.IDValue? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.address = address
        // la relación siempre va en el valor proyectado
        self.$course.id = course
    }
}

extension Person {
    var toDTO: PersonDTO {
        PersonDTO(name: name, email: email, address: address)
    }
}
