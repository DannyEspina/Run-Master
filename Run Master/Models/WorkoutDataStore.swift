

import HealthKit
import CoreData
import UIKit

class WorkoutDataStore {

    class func save(RunMasterWorkout: RunMasterWorkout, completion: @escaping ((Bool, Error?) -> Swift.Void)) {
        // Setup the Calorie Quantity for total energy burned
        let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(),
                                         doubleValue: RunMasterWorkout.calories)
        
        // Build the workout using data from your Prancercise workout
        let workout = HKWorkout(activityType: .running,
                                start: RunMasterWorkout.startDate!,
                                end: RunMasterWorkout.endDate!,
                                duration: Double(RunMasterWorkout.duration),
                                totalEnergyBurned: calorieQuantity,
                                totalDistance: nil,
                                device: HKDevice.local(),
                                metadata: nil)
        
        // Save your workout to HealthKit
        let healthStore = HKHealthStore()
        
        healthStore.save(workout) { (success, error) in
            completion(success, error)
        }
    
    }
    class func loadRunMasterWorkouts(completion: @escaping (([HKWorkout]?, Error?) -> Swift.Void)){
        
        // Get all workouts with the "Other" activity type.
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        
        // Get all workouts that only came from this app.
        let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
        
        //Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, sourcePredicate])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: compound, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                    
            DispatchQueue.main.async {
                
                //Cast the samples as HKWorkout
                guard let samples = samples as? [HKWorkout],
                    error == nil else {
                        completion(nil, error)
                        return
                }
                
                completion(samples, nil)
            }
        }
        
        HKHealthStore().execute(query)
    }
  
}
