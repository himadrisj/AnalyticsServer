//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import MySQLStORM

MySQLConnector.host        = "127.0.0.1"
MySQLConnector.username    = "perfect"
MySQLConnector.password    = "perfect"
MySQLConnector.database    = "perfect_testing"
MySQLConnector.port        = 3306

let setupObj = AnalyticsEvent()
try setupObj.setup()


let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()

func saveEvents(request: HTTPRequest, response: HTTPResponse) {
    
    do {
        guard let json = request.postBodyString,
            let dictArray = try json.jsonDecode() as? [[String: Any]] else {
                response.completed(status: .badRequest)
                return
        }
        
        for dict in dictArray {
            guard let eventType = dict[FieldValue.eventType.rawValue] as? String,
                let appName = dict[FieldValue.appName.rawValue] as? String,
                let appBundleId = dict[FieldValue.appBundleId.rawValue] as? String,
                let timeStamp = dict[FieldValue.timeStamp.rawValue] as? String else {
                    response.completed(status: .badRequest)
                    return
            }
            
            let event = AnalyticsEvent()
            
            //mandatory fields
            event.eventType = eventType
            event.appName = appName
            event.appBundleId = appBundleId
            event.timeStamp = timeStamp
            
            
            event.viewControllerName = dict[FieldValue.viewControllerName.rawValue] as? String ?? ""
            event.title = dict[FieldValue.title.rawValue] as? String ?? ""
            event.controlName = dict[FieldValue.controlName.rawValue] as? String ?? ""
            event.accessibilityIdentifier = dict[FieldValue.accessibilityIdentifier.rawValue] as? String ?? ""
            
            try event.save { id in
                event.id = id as! Int
            }
        }
        
        response.completed(status: .created)
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
            .completed(status: .internalServerError)
        }
}

func all(request: HTTPRequest, response: HTTPResponse) {
    do {
        
        // Get all acronyms as a dictionary
        let getObj = AnalyticsEvent()
        try getObj.findAll()
        var events: [[String: Any]] = []
        for row in getObj.rows() {
            events.append(row.asDictionary())
        }
        
        try response.setBody(json: events)
            .setHeader(.contentType, value: "application/json")
            .completed()
        
    } catch {
        response.setBody(string: "Error handling request: \(error)")
            .completed(status: .internalServerError)
    }
}


routes.add(method: .post, uri: "/save", handler: saveEvents)
routes.add(method: .get, uri: "/all", handler: all)

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

