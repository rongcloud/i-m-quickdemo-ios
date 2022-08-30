//
//  SelectGroupMemberVC.h
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectGroupMemberVC : UIViewController
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, copy) void (^sendMessageBlock)(NSMutableArray *);
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// mentioned ： @消息  directional：定向消息
@property (nonatomic, strong) NSString *type;
@end

NS_ASSUME_NONNULL_END
    
