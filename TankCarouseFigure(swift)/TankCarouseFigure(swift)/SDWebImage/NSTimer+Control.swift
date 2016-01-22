//
//  NSTimer+Control.swift
//  TankCarouseFigure(swift)
//
//  Created by yanwb on 16/1/21.
//  Copyright © 2016年 JINMARONG. All rights reserved.
//

import Foundation

extension NSTimer {
    public func pauseTimer() ->Void {
        if (!self.valid) {
            return
        }
        self.fireDate = NSDate.distantFuture()
    }
    
    public func resumerTimer() ->Void {
        if (!self.valid) {
            return
        }
        self.fireDate = NSDate()
    }
    
    
    public func resumerTimerAfterTimeInterval(interval:NSTimeInterval) -> Void {
        if (!self.valid) {
            return
        }
        
        self.fireDate = NSDate(timeIntervalSinceNow: interval)
    }
    
}

