//
//  RecordVoiceMessageVC.h
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*!
 录制普通语音消息并发送
 */
@interface RecordVoiceMessageVC : UIViewController
// 单聊
- (IBAction)privateButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *privateButton;


// 群聊
- (IBAction)groupButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *groupButton;

// targetId
@property (weak, nonatomic) IBOutlet UITextField *targetIdTextField;

// 开始录制
- (IBAction)beginRecordAction:(UIButton *)sender;
// 结束录制并发送
- (IBAction)endAndSendAction:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
