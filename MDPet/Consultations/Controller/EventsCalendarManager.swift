//
//  EventsCalendarManager.swift
//  MDPet
//
//  Created by Philippe on 26/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

typealias EventsCalendarManagerResponse = (_ result: Result<Bool, CustomError >, String) -> Void
typealias EventsCalendarManagerCall = (EKEvent, String)

class EventsCalendarManager: NSObject {

    var eventStore: EKEventStore!

    override init() {
        eventStore = EKEventStore()
    }

    // Request access to the Calendar
    private func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }

    // Get Calendar auth status
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }

    // Check Calendar permissions auth status
    // Try to add an event to the calendar if authorized
    func addEventToCalendar(event: EKEvent, eventIdentifier: String,
                            completion : @escaping EventsCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            self.addEvent(event: event, eventIdentifier: eventIdentifier, completion: { (result, idEvent) in
                switch result {
                case .success:
                    completion(.success(true), idEvent)
                case .failure(let error):
                    completion(.failure(error), idEvent)
                }
            })
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.addEvent(event: event, eventIdentifier: eventIdentifier, completion: { (result, idEvent) in
                        switch result {
                        case .success:
                            completion(.success(true), idEvent)
                        case .failure(let error):
                            completion(.failure(error), idEvent)
                        }
                    })
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(.calendarAccessDeniedOrRestricted), "")
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(.calendarAccessDeniedOrRestricted), "")
        @unknown default:
            print("error")
        }
    }

    // Try to save an event to the calendar
    private func addEvent(event: EKEvent, eventIdentifier: String,
                          completion : @escaping EventsCalendarManagerResponse) {
        let eventToAdd = generateEvent(event: event)
        var eventIdentifier = eventIdentifier
        if eventIdentifier.isEmpty {
            if !eventAlreadyExists(event: eventToAdd) {
                do {
                    try eventStore.save(eventToAdd, span: .thisEvent)
                    eventIdentifier = eventToAdd.eventIdentifier
                } catch {
                    // Error while trying to create event in calendar
                    completion(.failure(.eventNotAddedToCalendar), eventIdentifier)
                }
                completion(.success(true), eventIdentifier)
            } else {
                completion(.failure(.eventAlreadyExistsInCalendar), eventIdentifier)
            }
        } else {
            let eventToUpdate = eventStore.event(withIdentifier: eventIdentifier)
            eventToUpdate?.calendar = eventStore.defaultCalendarForNewEvents
            eventToUpdate?.title = eventToAdd.title
            eventToUpdate?.startDate = eventToAdd.startDate
            eventToUpdate?.endDate = eventToAdd.endDate
            eventToUpdate?.location = eventToAdd.location
            // Set default alarm 60 minutes before event
            let alarm = EKAlarm(relativeOffset: -3600)
            eventToUpdate?.addAlarm(alarm)
            do {
                try eventStore.save(eventToUpdate!, span: .thisEvent)
            } catch {
                // Error while trying to create event in calendar
                completion(.failure(.eventNotUpdatedToCalendar), eventIdentifier)
            }
            completion(.success(true), eventIdentifier)
        }
    }

    // Generate an event which will be then added to the calendar
    private func generateEvent(event: EKEvent) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.title
        newEvent.startDate = event.startDate
        newEvent.endDate = event.endDate
        newEvent.location = event.location
        // Set default alarm 60 minutes before event
        let alarm = EKAlarm(relativeOffset: -3600)
        newEvent.addAlarm(alarm)
        return newEvent
    }

    // Check if the event was already added to the calendar
    private func eventAlreadyExists(event eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate,
                                                      end: eventToAdd.endDate,
                                                      calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)

        let eventAlreadyExists = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title
                && event.startDate == eventToAdd.startDate
                && event.endDate == eventToAdd.endDate
        }
        return eventAlreadyExists
    }
   func requestSuppressEvent(eventIdentifier: String,
                             completion : @escaping EventsCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            self.suppressEvent(eventIdentifier: eventIdentifier, completion: { (result, idEvent) in
                switch result {
                case .success:
                    completion(.success(true), idEvent)
                case .failure(let error):
                    completion(.failure(error), idEvent)
                }
            })
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    self.suppressEvent(eventIdentifier: eventIdentifier, completion: { (result, idEvent) in
                        switch result {
                        case .success:
                            completion(.success(true), idEvent)
                        case .failure(let error):
                            completion(.failure(error), idEvent)
                        }
                    })
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(.calendarAccessDeniedOrRestricted), "")
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(.calendarAccessDeniedOrRestricted), "")
        @unknown default:
            print("error")
        }
    }
    func suppressEvent(eventIdentifier: String,
                       completion : @escaping EventsCalendarManagerResponse) {
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if eventToRemove != nil {
            do {
                try eventStore.remove(eventToRemove!, span: .thisEvent, commit: true)
            } catch {
                completion(.failure(.eventNotSuppressedToCalendar), eventIdentifier)
            }
            completion(.success(true), eventIdentifier)
        }
    }
}

// EKEventEditViewDelegate

extension EventsCalendarManager: EKEventEditViewDelegate {

    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

enum CustomError: Error {
    case calendarAccessDeniedOrRestricted
    case eventNotAddedToCalendar
    case eventAlreadyExistsInCalendar
    case eventDoesntExistInCalendar
    case eventNotUpdatedToCalendar
    case eventNotSuppressedToCalendar
}
