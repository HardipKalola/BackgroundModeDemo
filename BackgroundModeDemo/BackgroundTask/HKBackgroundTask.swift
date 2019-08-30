//
//  HKBackgroundTask.swift
//  BackgroundModeDemo
//
//  Created by sotsys-236 on 30/08/19.
//  Copyright © 2019 sotsys-236. All rights reserved.
//

import UIKit

/**

//-----------------------------------------------------------------------------

static func start() -> BackgroundTask?

Convenience for initializing a task with a default expiration handler;
@return Returns nil if background task time was denied.

//-----------------------------------------------------------------------------

func startWithExpirationHandler(handler: (() -> Void)?) -> Bool

Begins a background task.

@param handler The expiration handler. Optional. Will be called on whatever
thread UIKit pops the expiration handler for the task. The handler should
perform cleanup in a synchronous manner, since it is called when background
time is being brought to a halt.

@return Returns YES if a valid task id was created.

//-----------------------------------------------------------------------------

end()

Ends the background task for `taskId`, if the id is valid.

*/

public class HKBackgroundTask {
    
    // MARK: Public
    
    public static func start() -> HKBackgroundTask? {
        let task = HKBackgroundTask();
        let successful = task.startWithExpirationHandler(handler: nil)
        return (successful) ? task : nil
    }
    
    public func startWithExpirationHandler(handler: (() -> Void)?) -> Bool {
        self.taskId = UIApplication.shared.beginBackgroundTask {
            if let safeHandler = handler { safeHandler() }
            self.end()
        }
        return (self.taskId != UIBackgroundTaskIdentifier.invalid);
    }
    
    public func end() {
        if (self.taskId != UIBackgroundTaskIdentifier.invalid) {
            let taskId = self.taskId
            self.taskId = UIBackgroundTaskIdentifier.invalid
            UIApplication.shared.endBackgroundTask(taskId)
        }
    }
    
    // MARK: Private
    
    private var taskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
}
