//
//  TankCycleScrollView.swift
//  TankCarouseFigure(swift)
//
//  Created by yanwb on 16/1/21.
//  Copyright © 2016年 JINMARONG. All rights reserved.
//

import UIKit


enum TankCycleScrollPageContolAliment {
    case right
    case center
};



class TankCycleScrollView:  UIView, UIScrollViewDelegate{
    
    
    //本地图片数组 这两个必选一个
    var cycleImageArray: NSArray! {
        didSet{
            if(cycleImageArray.count == 0 || cycleImageArray == nil) {
                return
            }
            self.cycleCarouselArray = NSMutableArray(array: cycleImageArray)
            
            self.setSubImageViewWithPicArray(cycleImageArray, andURLType: false)
            
            self.configContentView()
        }
    }
    
    //图片路径数组
    var cycleImageUrlArray: NSArray! {
        didSet{
            if cycleImageUrlArray.count == 0 || cycleImageUrlArray == nil {
                return
            }
            
            self.cycleCarouselArray = NSMutableArray(capacity: cycleImageUrlArray.count)
            
            for _ in 0 ..< cycleImageUrlArray.count {
                let image: UIImage = UIImage.init()
                self.cycleCarouselArray.addObject(image)
            }
            
            self.setSubImageViewWithPicArray(cycleImageUrlArray, andURLType: true)
            
            self.configContentView()
        }
    }
    
    // optional
    //预防点击做一些动作 增添这个属性  应与图片数组的数量一致并且一一对应
    var modelArray: NSArray!
    //设定加载失败次数(范围内尝试重新加载)
    var networkFailedCount: NSInteger = 10
    //是否显示pageControl   默认显示
    var showPageControl: Bool = true
    //pageControl显示位置
    var cycleScrollPageControlAliment: TankCycleScrollPageContolAliment = .center
    //pageControl当前颜色
    var cycleCurrentPageIndicatorTintColor: UIColor = UIColor.blueColor()
    //pageControl平常颜色
    var cyclePageIndicatorTintColor: UIColor = UIColor.whiteColor()
    //是否允许拉伸效果  默认无效果
    var enbleStretch: Bool = false
    
    
    //定时器
    private var animationTimer: NSTimer!
    // 滚动视图
    private var cycleScrollView: UIScrollView!
    // 滚动间隔时间
    private var animationDuration: NSTimeInterval = 3
    // 当前显示页
    private var currentPageIndex: NSInteger = 0
    //总页数
    private var totalPageCount: NSInteger!
    //用于显示的图片控件数组
    private var contentViews: NSMutableArray!
    //总图片控件数组
    private lazy var subContentViews: NSMutableArray! = {
        return NSMutableArray()
    }()
    //实际滚动焦点图数组
    private lazy var cycleCarouselArray: NSMutableArray = NSMutableArray()
    //请求失败次数
    private var currentNetWorkFaildCount: NSInteger!
    //页码显示器
    private var pageControl: UIPageControl!
    //初始宽度
    private var orginWidth: CGFloat!
    //初始高度
    private var orginHeight: CGFloat!
    //拉伸显示图片
    private var stretchImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initWithFrame(frame:CGRect, animationDuration:NSTimeInterval) -> TankCycleScrollView{
        self.frame = frame
        self.orginWidth = frame.size.width
        self.orginHeight = frame.size.height
        self.autoresizesSubviews = true
        
        let cycleScrollView = UIScrollView.init(frame: frame)
        cycleScrollView.autoresizingMask = .None
        cycleScrollView.contentMode = .Center
        cycleScrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(cycleScrollView.frame), 0)
        cycleScrollView.delegate = self
        cycleScrollView.contentOffset = CGPointMake(CGRectGetWidth(cycleScrollView.frame), 0)
        cycleScrollView.pagingEnabled = true
        cycleScrollView.showsHorizontalScrollIndicator = true
        self.cycleScrollView = cycleScrollView
        self.addSubview(cycleScrollView)
        self.currentPageIndex = 0
        
        
        let stretchImageView:UIImageView = UIImageView.init(frame: self.cycleScrollView.frame)
        self.stretchImageView = stretchImageView
        stretchImageView.hidden = true
        self.addSubview(stretchImageView)
        
        if(animationDuration > 0.0) {
            self.animationDuration = animationDuration
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(animationDuration, target: self, selector: "animationTimerDidFired:", userInfo: nil, repeats: true)
            
            self.animationTimer.pauseTimer()
        }
        return self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let pageControl = UIPageControl.init()
        pageControl.currentPageIndicatorTintColor = self.cycleCurrentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = self.cyclePageIndicatorTintColor
        pageControl.numberOfPages = self.totalPageCount
        self.pageControl = pageControl
        self.addSubview(pageControl)
        
        if(self.cycleScrollPageControlAliment == .center) {
            pageControl.frame = CGRectMake((CGRectGetWidth(self.frame) - 100) * 0.5, CGRectGetHeight(self.frame) - 30, 100, 30);
        } else {
            pageControl.frame = CGRectMake(CGRectGetWidth(self.frame) - 120, CGRectGetHeight(self.frame) - 30, 100, 30);
        }
        
        if(self.showPageControl) {
            if (self.totalPageCount > 1) {
                pageControl.hidden = false;
            } else {
                pageControl.hidden = true;
            }
        } else {
            pageControl.hidden = true
        }
        
        self.pageControl.currentPage = self.currentPageIndex
    }
    
    
    //根据传递类型加载图片
    private  func setSubImageViewWithPicArray(picArray:NSArray, andURLType isURL:Bool) {
        self.totalPageCount = picArray.count
        
        let viewsArray = NSMutableArray()
        
        if(picArray.count > 2) {
            for i in 0 ..< picArray.count {
                let imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, CGRectGetWidth(self.cycleScrollView.frame), CGRectGetHeight(self.cycleScrollView.frame)))
                if(isURL) {
                    self.imageView(imageView, loadingWithUrl: picArray[i] as! NSString, atIndex: i)
                } else {
                    imageView.image = picArray[i] as? UIImage
                }
                viewsArray.addObject(imageView)
            }
        } else if(picArray.count == 2) {
            for i in 0 ..<  picArray.count*2 {
                let imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, CGRectGetWidth(self.cycleScrollView.frame), CGRectGetHeight(self.cycleScrollView.frame)))
                if(isURL) {
                    self.imageView(imageView, loadingWithUrl: picArray[i%2] as! NSString, atIndex: i)
                } else {
                    imageView.image = picArray[i%2] as? UIImage
                }
                viewsArray.addObject(imageView)
                
            }
        } else {
            for i in 0 ..<  picArray.count*4 {
                let imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, CGRectGetWidth(self.cycleScrollView.frame), CGRectGetHeight(self.cycleScrollView.frame)))
                if(isURL) {
                    self.imageView(imageView, loadingWithUrl: picArray[0] as! NSString, atIndex: i)
                } else {
                    imageView.image = picArray[0] as? UIImage
                }
                viewsArray.addObject(imageView)
            }
        }
        self.subContentViews = viewsArray
        
        self.animationTimer.resumerTimer()
    }
    
    
    private func imageView(imageView:UIImageView,loadingWithUrl urlStr:NSString, atIndex index:Int) {
        var url:NSURL
        if urlStr.isKindOfClass(NSString){
            url = NSURL(string: urlStr as String)!
        } else {
            url = urlStr as! NSURL
        }
        
        let image:UIImage? = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(urlStr as String)
        
        if((image) != nil) {
            self.cycleCarouselArray.replaceObjectAtIndex(index, withObject: image!)
            imageView.image = image
        } else {
            imageView.sd_setImageWithURL(url, placeholderImage: nil, completed: { (image:UIImage!, error:NSError!, cacheType:SDImageCacheType, imageURL:NSURL!) -> Void in
                if let tempImage = image {
                    self.cycleCarouselArray.replaceObjectAtIndex(index, withObject: tempImage)
                } else {
                    if (self.currentNetWorkFaildCount > self.networkFailedCount) { return }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(),{
                        self.imageView(imageView, loadingWithUrl: urlStr, atIndex: index)
                    })
                    self.currentNetWorkFaildCount = self.currentNetWorkFaildCount + 1
                    
                }
            })
        }
    }
    
    private func configContentView(){
        (self.cycleScrollView.subviews as NSArray).enumerateObjectsUsingBlock { (view:AnyObject, i:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            view.removeFromSuperview()
        }
        
        self.setScrollViewContentDataSource()
        
        var counter: NSInteger = 0
        
        for i in 0 ..< self.contentViews.count  {
            let contentView:UIView = self.contentViews[i] as! UIView
            contentView.userInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer.init(target: self, action: "contentViewTapAction:")
            contentView.addGestureRecognizer(tapGesture)
            var rightRect = contentView.frame
            rightRect.origin = CGPointMake(CGRectGetWidth(self.cycleScrollView.frame) * (CGFloat)( counter++ ), 0);
            contentView.frame = rightRect;
            self.cycleScrollView.addSubview(contentView)
        }
        
        self.cycleScrollView.setContentOffset(CGPointMake(self.cycleScrollView.frame.size.width, 0), animated: true)
    }
    
    private func getValidNextPageIndexWithPageIndex(currentPageIndex:NSInteger)->NSInteger {
        if (self.totalPageCount > 2) {
            if(currentPageIndex == -1) {
                return self.totalPageCount - 1
            } else if (currentPageIndex == self.totalPageCount) {
                return 0
            } else {
                return currentPageIndex
            }
        } else if (self.totalPageCount == 2){
            if(currentPageIndex == -1) {
                return (self.totalPageCount * 2 - 1)
            } else if (currentPageIndex == self.totalPageCount * 2) {
                return 0
            } else {
                return currentPageIndex
            }
        } else {
            if(currentPageIndex == -1) {
                return (self.totalPageCount * 4 - 1)
            } else if (currentPageIndex == self.totalPageCount * 4) {
                return 0
            } else {
                return currentPageIndex
            }
        }
    }
    
    //设置ScrollView的数据源
    private func setScrollViewContentDataSource() {
        let previousPageIndex:NSInteger = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex-1)
        let rearPageIndex:NSInteger = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
        if (self.contentViews == nil) {
            self.contentViews = NSMutableArray()
        }
        self.contentViews.removeAllObjects()
        if let _:UIView = self.featchContentViewAtIndex(self.currentPageIndex) {
            self.contentViews.addObject(self.featchContentViewAtIndex(previousPageIndex))
            self.contentViews.addObject(self.featchContentViewAtIndex(self.currentPageIndex))
            self.contentViews.addObject(self.featchContentViewAtIndex(rearPageIndex))
        }
        if (self.totalPageCount > 1) {
            self.cycleScrollView.scrollEnabled = true;
        } else {
            self.cycleScrollView.scrollEnabled = false;
        }
        
    }
    
    private func featchContentViewAtIndex(index:NSInteger) -> UIView {
        return self.subContentViews.objectAtIndex(index) as! UIView
    }
    
    //UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if self.totalPageCount > 1 {
            self.animationTimer.pauseTimer()
        }
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.totalPageCount > 1 {
            self.animationTimer.resumerTimerAfterTimeInterval(self.animationDuration)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.cycleCarouselArray.count == 0 {
            return
        }
        
        let contentOffsetX = scrollView.contentOffset.x
        print("%f",contentOffsetX)
        if contentOffsetX >=  (2 * CGRectGetWidth(scrollView.frame)) {
            self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
            if (self.totalPageCount > 2) {
                self.pageControl.currentPage = self.currentPageIndex;
            } else if (self.totalPageCount == 2 ) {
                self.pageControl.currentPage = self.currentPageIndex % 2;
            } else {
                self.pageControl.currentPage = 0;
            }
            self.configContentView()
        }
        
        if contentOffsetX <= 0 {
            self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
            
            if (self.totalPageCount > 2) {
                self.pageControl.currentPage = self.currentPageIndex;
            } else if (self.totalPageCount == 2 ) {
                self.pageControl.currentPage = self.currentPageIndex % 2;
            } else {
                self.pageControl.currentPage = 0;
            }
            self.configContentView()
        }
        
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPointMake(CGRectGetWidth(scrollView.frame), 0), animated: true)
    }
    
    
    // 响应事件
    
    func contentViewTapAction(tap:UIGestureRecognizer) {
        
    }
    
    
    func animationTimerDidFired(timer:NSTimer) {
        let newOffset = CGPointMake(CGRectGetWidth(self.cycleScrollView.frame) + CGRectGetWidth(self.cycleScrollView.frame), self.cycleScrollView.contentOffset.y);
        self.cycleScrollView.setContentOffset(newOffset, animated: true)
    }
    
    func resumerTimer() {
        if (self.totalPageCount > 1) {
            self.animationTimer.resumerTimerAfterTimeInterval(self.animationDuration)
        }
    }
    
    func pauseTimer() {
        self.animationTimer.pauseTimer()
        let newOffset = CGPointMake(CGRectGetWidth(self.cycleScrollView.frame), self.cycleScrollView.contentOffset.y);
        self.cycleScrollView.setContentOffset(newOffset, animated: true)
        
    }
    
    
    func cycleScrollViewStretchingWithOffset(offset:CGFloat) {
        if (!self.enbleStretch) {
            return;
        }
        let whpercent:CGFloat = self.orginWidth/self.orginHeight;
        let height:CGFloat = self.orginHeight - offset;
        let width:CGFloat = self.orginWidth - offset * whpercent;
        if (offset < -1) {
            self.animationTimer.pauseTimer()
            self.cycleScrollView.hidden = true;
            self.stretchImageView.hidden = false;
            self.stretchImageView.image = self.cycleCarouselArray.objectAtIndex(self.currentPageIndex) as! UIImage;
            self.stretchImageView.frame = CGRectMake(offset, offset, width, height);
        } else {
            self.animationTimer.resumerTimerAfterTimeInterval(2)
            self.cycleScrollView.hidden = false;
            self.stretchImageView.hidden = true;
            self.stretchImageView.frame = CGRectZero;
        }
    }
    
    
}