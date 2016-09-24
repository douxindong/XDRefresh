# XDRefresh
自定义下拉刷新控件
![http://ww3.sinaimg.cn/mw690/afa9a093gw1f857zyh7ueg208w0gidui.gif](http://ww3.sinaimg.cn/mw690/afa9a093gw1f857zyh7ueg208w0gidui.gif)
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

//
//  XDRefreshView.m
//  下拉刷新－自定义
//
//  Created by 窦心东 on 16/9/24.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import "XDRefreshView.h"
#define XDRefreshViewHeight 60
//三种状态
typedef enum{
    XDRefreshViewStatusNormol,  //正常状态
    XDRefreshViewStatusPuling,  //释放刷新状态
    XDRefreshViewStatusRefreshing   //正在刷新状态

} XDRefreshViewStatus;
@interface XDRefreshView ()

//图片
@property (nonatomic,strong) UIImageView *imageView;
//文字
@property (nonatomic,strong) UILabel *label;
//记录当前状态
@property (nonatomic,assign) XDRefreshViewStatus currenStatus;
//记录父控件，可以滚动的
@property (nonatomic,strong) UIScrollView *superScrollView;
//吃包子动画图片数组
@property (nonatomic,strong) NSArray *refreshImages;
@end

@implementation XDRefreshView

//添加子控件
-(instancetype)initWithFrame:(CGRect)frame{

    if (self=[super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        //设置frame
        self.imageView.frame = CGRectMake(80, 0, 50, 50);
        self.label.frame = CGRectMake(130, 20, 300, 20);
    }
    return self;
}
//监听父控件的滚动
//当控件加到父控件（tableview）时调用此方法
-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
//    NSLog(@"控件加到父控件是%@",newSuperview);//获取到父控件
    //父控件就是我们要监听滚动事件的父控件了
    //只有父控件能滚动的才能去监听
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        //监听父控件的滚动
        //当我们一直拖动tableView的时候scrollView有一个属性一直变化
        //所以说监听父控件的滚动就是监听 self.superScrollView对象的contentOffset的属性的改变
        //ios中用于监听对象属性的机制叫做KVO
        //          KVO： Key-Value-observing  键值监听
        //键值监听KVO作用：就是监听对象一个属性的改变
        //       KVO使用：我们要监听那个对象，就用哪个对象去调方法
        //当监听对象身上的这种属性发生变化时会［（addObserver）调用这个（forKeyPath:options:context:）方法］
        //注意⚠️使用KVO的时候，像使用通知一样需要用完取消在dealloc方法中
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
}
#pragma mark - KVO时 当监听对象身上的这种属性发生变化时会调 用这个方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    NSLog(@"自己监听到父控件的滚动Y值：%f",self.superScrollView.contentOffset.y);
    //根据拖动的程度不同，来切换状态
    
    if (self.superScrollView.isDragging) {
        //手拖动normol->puling，puling->normol
        CGFloat normolPulingOffset = -124;
        if (self.currenStatus ==XDRefreshViewStatusPuling && self.superScrollView.contentOffset.y>normolPulingOffset) {
//            NSLog(@"切换到Normol");
            self.currenStatus = XDRefreshViewStatusNormol;
        }else if (self.currenStatus ==XDRefreshViewStatusNormol && self.superScrollView.contentOffset.y<=normolPulingOffset){
//            NSLog(@"切换到Puling");
            self.currenStatus = XDRefreshViewStatusPuling;
        }
    }else{
         //手松开puling->refreshing
        if (self.currenStatus ==XDRefreshViewStatusPuling) {
//            NSLog(@"切换到Refreshing");
            self.currenStatus = XDRefreshViewStatusRefreshing;
        }
       
    }
}
#pragma mark - 当切换状态时必经此方法getter
- (void)setCurrenStatus:(XDRefreshViewStatus)currenStatus{
    _currenStatus = currenStatus;
    switch (_currenStatus) {
        case XDRefreshViewStatusNormol:
        {
            NSLog(@"切换到Normol");
            //动画停下来
            [self.imageView stopAnimating];
            self.label.text = @"下拉刷新，再往下拖一点点";
            self.imageView.image = [UIImage imageNamed:@"normal"];
        }
            break;
        case XDRefreshViewStatusPuling:
        {
            NSLog(@"切换到Puling");
            self.label.text = @"释放我就可以刷新啦～～";
            self.imageView.image = [UIImage imageNamed:@"pulling"];
        }
            break;
            
        case XDRefreshViewStatusRefreshing:
        {
            NSLog(@"切换到Refreshing");
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM-dd-YY HH:mm"];
            NSString *timestamp = [formatter stringFromDate:[NSDate date]];
            self.label.text = [NSString stringWithFormat:@"数据最后更新时间%@",timestamp];
//            @"正在刷新数据哟......";
            self.imageView.animationImages = self.refreshImages;
            //播多长时间
            self.imageView.animationDuration = 0.1 * self.refreshImages.count;
            //开始播放
            [self.imageView startAnimating];
            //tableView往下走一点
            [UIView animateWithDuration:0.25 animations:^{
                self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top+XDRefreshViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
            }];
            //让控制器做事情
//            Block使用1.定义block 2.传递block3.调用block
            
            //3调用block 时先判断block是否有值，没有的话是会崩溃的
            if (self.refreshBlock) {
                self.refreshBlock();
            }
        }
            break;
            default:
            break;
            
    }

}
//结束刷新
- (void)endRefreshing{
    //refreshing->normol
    if (_currenStatus == XDRefreshViewStatusRefreshing) {
        self.currenStatus = XDRefreshViewStatusNormol;
        //tableView要回去
        [UIView animateWithDuration:0.25 animations:^{
            self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top-XDRefreshViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
        }];

    }
    

    
    
}
#pragma mark - deallco
-(void)dealloc{
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}
#pragma mark - 懒加载
-(UIImageView *)imageView{

    if (_imageView==nil) {
        UIImage *image = [UIImage imageNamed:@"normal"];
        _imageView = [[UIImageView alloc] initWithImage:image];
        
    }
    return  _imageView;
}
-(UILabel *)label{

    if (_label == nil) {
        _label = [[UILabel alloc] init];
        //设置
        _label.textColor = [UIColor darkGrayColor];
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = @"下拉刷新";
    }
    return _label;
}
-(NSArray *)refreshImages{
    if (_refreshImages==nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i=1; i<4; i++) {
            NSString *imagesName = [NSString stringWithFormat:@"refreshing_0%d",i];
            UIImage *image = [UIImage imageNamed:imagesName];
            [arrayM addObject:image];
        }
        _refreshImages = arrayM;
    }
    return _refreshImages;
}

@end
//
//  XDRefreshTableViewController.m
//  下拉刷新－自定义
//
//  Created by 窦心东 on 16/9/24.
//  Copyright © 2016年 窦心东. All rights reserved.
//

#import "XDRefreshTableViewController.h"
#import "XDRefreshView.h"
@interface XDRefreshTableViewController ()
//要显示的数据
@property (nonatomic,strong) NSArray *cities;
@property (nonatomic,strong) XDRefreshView *refreahView;
@end

@implementation XDRefreshTableViewController
/**
 * 创建下拉刷新控件
 */
-(XDRefreshView *)refreahView{

    if (_refreahView==nil) {
        _refreahView = [[XDRefreshView alloc] initWithFrame:CGRectMake(0,-60, [UIScreen mainScreen].bounds.size.width, 60)];
//        _refreahView.backgroundColor = [UIColor brownColor];
    }
    return _refreahView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  加载数据
     */
    self.cities = [self loadData];
    //添加刷新控件到tableView上
    [self.tableView addSubview:self.refreahView];
    //1定义block  ： refreahView.refreshBlock
    //2传递block（赋值）：refreahView.refreshBlock = ^()
    self.refreahView.refreshBlock = ^(){
        NSLog(@"告诉控制器进入刷新状态了");
        //由于加载的是plist文件比较快，现在我们用GCD方式添加延时
        ino64_t delayInSeconds = 3;
        __weak XDRefreshTableViewController *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //加载数据
            NSArray *newArray = [weakSelf loadData];
            NSMutableArray *newArrayM = [NSMutableArray arrayWithArray:newArray];
            [newArrayM addObjectsFromArray:weakSelf.cities];
            weakSelf.cities = newArrayM;
            [weakSelf.tableView reloadData];
            //结束刷新
            [weakSelf.refreahView endRefreshing];
        });

    };
    
}
-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    NSLog(@"self.tableView.contentInset.top（tableView的起始位置Y值） =%f",self.tableView.contentInset.top);
}
//加载数据源数据
- (NSArray *)loadData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    return array;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = self.cities[indexPath.row];
    return cell;
}

@end
