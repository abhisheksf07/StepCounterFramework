//
//  HealthStore.swift
//  Alivio
//
//  Created by Abhishek  Singla on 11/10/22.
//

import Foundation
import HealthKit
import UIKit

enum permissionGrantedStatus: String {
    case granted
    case denied
    case notDetermined
}

public class HealthStore {
        
    private var _healthStore: HKHealthStore?
    private var _query:  HKStatisticsCollectionQuery?
    private let _healthAppUrl = "x-apple-health://"
    
    public static let shared = HealthStore()
    
    private init() {
        // to make default constructor private
        if HKHealthStore.isHealthDataAvailable(){
            _healthStore = HKHealthStore()
        } else {
            debugPrint("Health Kit is not available on this device")
        }
    }
    
    func openHealthApp() {
        guard let url = URL(string: _healthAppUrl) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func getAuthorisationStatus()-> permissionGrantedStatus {
        let stepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let authorizationStatus = _healthStore?.authorizationStatus(for: stepCount)
        if (authorizationStatus == .notDetermined) {
            return .notDetermined
        } else if authorizationStatus == .sharingDenied {
            return .denied
        } else {
            return .granted
        }
    }
    
    func requestAuthorisation(completion: @escaping(Bool)-> Void) {
        
        let sleep = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        let energyBurned = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let stepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let heartRate = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let oxygen = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
        let bodyTemp = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
        
        guard let healthStore = self._healthStore else {return completion(false)}
        
        if #available(iOS 12.0, *) {
            
            healthStore.getRequestStatusForAuthorization(toShare: [sleep, energyBurned, stepCount, distanceType, heartRate, oxygen, bodyTemp], read: [sleep, energyBurned, stepCount, distanceType, heartRate, oxygen, bodyTemp ]) { (requestAuthorisationStatus, err) in
                
                if (requestAuthorisationStatus == .shouldRequest) || (requestAuthorisationStatus == .unnecessary) {
                    healthStore.requestAuthorization(toShare: [sleep, energyBurned, stepCount, distanceType, heartRate, oxygen, bodyTemp], read: [sleep, energyBurned, stepCount, distanceType, heartRate, oxygen, bodyTemp]) { (isAuthorised, error) in
                        
                        (self.getAuthorisationStatus() == .denied) ? completion(false) : completion(true)
                        
                    }
                }
            }
        }
    }
    
    func calculateSteps(completion: @escaping (HKStatisticsCollection?, Double?)->Void) {
        var stepsCount = 0.0
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        let startDate = Calendar.current.date(byAdding: .day,value: -7 ,to: Date())
        
        let anchorDate = Date.mondayAt12AM()
        let daily = DateComponents(day: 1)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        _query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)

        _query?.initialResultsHandler = {
            query, statisticsCollection, error in
            
            
            statisticsCollection?.enumerateStatistics(from: startDate ?? Date(), to: Date()) { statstics, stop in
                
                if let stepCountVal = statstics.sumQuantity()?.doubleValue(for: .count()){
                    stepsCount = stepCountVal
                }
                print("Countttttt: \(stepsCount)")
            }
            
            completion(statisticsCollection, stepsCount)
        }

        if let healthStore = _healthStore, let query = self._query {
            healthStore.execute(query)
        }
    }
}

extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
}
