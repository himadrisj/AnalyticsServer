//
//  EventModel.swift
//  HTServerPackageDescription
//
//  Created by Himadri Sekhar Jyoti on 04/02/18.
//

import Foundation
import StORM
import MySQLStORM

enum FieldValue: String {
    case id = "id"
    case eventType = "event_type"
    case appName = "app_name"
    case appBundleId = "app_bundle_id"
    case timeStamp = "time_stamp"
    case viewControllerName = "view_controller_name"
    case title = "title"
    case controlName = "control_name"
    case accessibilityIdentifier = "accessibility_identifier"
}

class AnalyticsEvent: MySQLStORM {
    var id: Int = 0
    var eventType: String = ""
    var appName: String = ""
    var appBundleId: String = ""
    var timeStamp: String = ""
    var viewControllerName: String = ""
    var title: String = ""
    var controlName: String = ""
    var accessibilityIdentifier: String = ""
    
    // The name of the database table
    override open func table() -> String { return "analytics_sdk_events" }
    
    // The mapping that translates the database info back to the object
    // This is where you would do any validation or transformation as needed
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        eventType = this.data["eventType"] as? String ?? ""
        appName = this.data["appName"] as? String ?? ""
        appBundleId = this.data["appBundleId"] as? String ?? ""
        timeStamp = this.data["timeStamp"] as? String ?? ""
        viewControllerName = this.data["viewControllerName"] as? String ?? ""
        title = this.data["title"] as? String ?? ""
        controlName = this.data["controlName"] as? String ?? ""
        accessibilityIdentifier = this.data["accessibilityIdentifier"] as? String ?? ""
    }
    
    func rows() -> [AnalyticsEvent] {
        var rows = [AnalyticsEvent]()
        for i in 0..<self.results.rows.count {
            let row = AnalyticsEvent()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        return [
            FieldValue.eventType.rawValue: self.eventType,
            FieldValue.appName.rawValue: self.appName,
            FieldValue.appBundleId.rawValue: self.appBundleId,
            FieldValue.timeStamp.rawValue: self.timeStamp,
            FieldValue.viewControllerName.rawValue: self.viewControllerName,
            FieldValue.title.rawValue: self.title,
            FieldValue.controlName.rawValue: self.controlName,
            FieldValue.accessibilityIdentifier.rawValue: self.accessibilityIdentifier,
        ]
    }
}
