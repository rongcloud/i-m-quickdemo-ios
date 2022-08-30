//
//  SelectGroupMemberCell.h
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectGroupMemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@end

NS_ASSUME_NONNULL_END
