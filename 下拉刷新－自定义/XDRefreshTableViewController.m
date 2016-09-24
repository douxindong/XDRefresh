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
