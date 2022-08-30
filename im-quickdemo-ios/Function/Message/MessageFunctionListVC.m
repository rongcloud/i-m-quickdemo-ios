//
//  MessageFunctionListVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/12.
//

#import "MessageFunctionListVC.h"
#import "TextViewCell.h"
#import "RecordVoiceMessageVC.h"
#import "RecordHQVoiceMessageVC.h"

@interface MessageFunctionListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation MessageFunctionListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"消息";
    self.dataSource = [@[
        @"录制发送普通语音消息",
        @"录制发送高清语音消息"
    ] mutableCopy];
}


#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"TextViewCell";
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.txtName.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *msgSb = [UIStoryboard storyboardWithName:@"Message" bundle:nil];
    switch (indexPath.row) {
        case 0:
        {
            // 录制发送普通语音消息
            RecordVoiceMessageVC *vc = [msgSb instantiateViewControllerWithIdentifier:@"RecordVoiceMessageVC"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            // 录制发送高清语音消息
            RecordHQVoiceMessageVC *vc = [msgSb instantiateViewControllerWithIdentifier:@"RecordHQVoiceMessageVC"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
