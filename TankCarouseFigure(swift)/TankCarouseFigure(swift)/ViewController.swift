//
//  ViewController.swift
//  TankCarouseFigure(swift)
//
//  Created by yanwb on 16/1/21.
//  Copyright © 2016年 JINMARONG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let cycleScrollView:TankCycleScrollView = TankCycleScrollView().initWithFrame(CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 200), animationDuration: 2)

        self.view.addSubview(cycleScrollView)
        
        var imageArray: NSMutableArray = NSMutableArray()
        for (var i:Int = 1 ;i < 4; i++) {
                let imageName:NSString = NSString(format:"h%d.jpg",i)
                let image:UIImage = UIImage(named: imageName as String)!
                imageArray.addObject(image)
            }
        
//        let imageArray:NSArray = [
//        "https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
//        "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
//        "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
//        ];
        cycleScrollView.cycleImageArray = imageArray;
        cycleScrollView.modelArray = imageArray;
        cycleScrollView.testTapSingleImage { (pageIndex, model) in
            NSLog("--------------%d", pageIndex);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

