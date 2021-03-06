//
//  main.swift
//  PerfectTemplate
//
//  Created by Himadri Jyoti on 2018-02-03.
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

extension MySQLStORM {
    func findAllSorted() throws {
        do {
            let cursor = StORMCursor(limit: 20,offset: 0)
            try select(
                columns: [],
                whereclause: "1",
                params: [],
                orderby: ["timeStamp DESC"],
                cursor: cursor
            )
        } catch {
            throw StORMError.error("\(error)")
        }
    }
}

/*
//Local
MySQLConnector.host        = "127.0.0.1"
MySQLConnector.username    = "perfect1"
MySQLConnector.password    = "perfect1"
MySQLConnector.database    = "perfecttesting"
MySQLConnector.port        = 3306
 */

//Production
MySQLConnector.host        = "perfecttesting.c1dlcbx8snw4.us-east-1.rds.amazonaws.com"
MySQLConnector.username    = "perfect1"
MySQLConnector.password    = "perfect1"
MySQLConnector.database    = "perfecttesting"
MySQLConnector.port        = 3306

let setupObj = AnalyticsEvent()
try setupObj.setup()

func test(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Working!</title><body>Server is up and running!</body></html>")
    // Ensure that response.completed() is called when your processing is done.
    response.completed(status: .ok)
}

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
        try getObj.findAllSorted()
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


let confData = [
        "servers": [
                // Configuration data for one server which:
                //    * Serves the hello world message at <host>:<port>/
                //    * Serves static files out of the "./webroot"
                //        directory (which must be located in the current working directory).
                //    * Performs content compression on outgoing data when appropriate.
                [
                    "name":"localhost",
                    "port":8080,
                    "routes":[
                        ["method":"get", "uri":"/test", "handler":test],
                        ["method":"post", "uri":"/save", "handler":saveEvents],
                        ["method":"get", "uri":"/all", "handler":all],
                        ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
                         "documentRoot":"./webroot",
                         "allowResponseFilters":true]
                    ],
                    "filters":[
                        [
                        "type":"response",
                        "priority":"high",
                        "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                        ]
                    ]
                ]
            ]
    ]

do {
    try HTTPServer.launch(configurationData: confData)
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}



