//
//  XDRefreshView.h
//  下拉刷新－自定义
//
//  Created by 窦心东 on 16/9/24.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDRefreshView : UIView

@property (nonatomic ,copy) void(^refreshBlock)();
//结束刷新
- (void)endRefreshing;

@end
