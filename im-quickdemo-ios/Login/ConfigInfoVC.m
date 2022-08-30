//
//  ConfigInfoVC.m
//  support-im-ios-debugdemo
//
//  Created by pengwenxin on 2022/7/19.
//

#import "ConfigInfoVC.h"
#import "ConfigNaviAndFileController.h"
#import "ConfigInfoConversationVC.h"

@interface ConfigInfoVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic,   copy) NSArray     * datasArr;

@end

@implementation ConfigInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"配置页面";
    [self setNavigationItem];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 100);
    NSArray * arr  = @[
            @{
                @"title":@"配置导航和文件服务",
            },
            @{
                @"title":@"配置会话列表页面参数",
            }];
    
    self.datasArr = arr;
    [self.tableView reloadData];
}

- (void)setNavigationItem{
    UIImage *leftImage = [[UIImage imageNamed:@"nav_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem * leftBarItem = [[UIBarButtonItem alloc] initWithImage:leftImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.datasArr.count <=0) {
        return [[UITableViewCell alloc] init];
    }
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
     NSDictionary * dict = self.datasArr[indexPath.row];
     cell.textLabel.text = [dict objectForKey:@"title"];
     return cell;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.datasArr.count <=0) {return;}
   
    if (indexPath.row == 0) {
        ConfigNaviAndFileController * vc = [[ConfigNaviAndFileController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.row == 1){
        ConfigInfoConversationVC * vc = [[ConfigInfoConversationVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - UILazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = NO;
        _tableView.estimatedRowHeight = 0.f;
        _tableView.delaysContentTouches = NO;
    }
    return _tableView;
}
@end
