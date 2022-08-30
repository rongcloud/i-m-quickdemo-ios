//
//  RecordHQVoiceMessageVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/26.
//

#import "RecordHQVoiceMessageVC.h"
#import <AVFoundation/AVFoundation.h>

/**
        IMLib 发送高清语音消息示例。代码仅供参考，具体更细节的逻辑需要您完善。
 */
@interface RecordHQVoiceMessageVC ()<AVAudioRecorderDelegate>
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDictionary *recordSettings;
@property (nonatomic, strong) NSURL *recordTempFileURL;
@end

@implementation RecordHQVoiceMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"高清语音消息";
    self.conversationType = ConversationType_PRIVATE;
    // 录制参数
    self.recordSettings = @{
        AVFormatIDKey : @(kAudioFormatMPEG4AAC_HE),
        AVNumberOfChannelsKey : @1,
        AVEncoderBitRateKey : @(32000)
    };
    
    // 临时语音存放路径
    self.recordTempFileURL =
        [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"HQTempAC.m4a"]];
    NSLog(@"--- self.recordTempFileURL %@", self.recordTempFileURL);
}


- (IBAction)privateButtonAction:(UIButton *)sender {
    if (self.conversationType == ConversationType_PRIVATE) {
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.conversationType = ConversationType_PRIVATE;
        self.groupButton.selected = NO;
    }
}


- (IBAction)groupButtonAction:(UIButton *)sender {
    if (self.conversationType == ConversationType_GROUP) {
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.conversationType = ConversationType_GROUP;
        self.privateButton.selected = NO;
    }
}


// 开始录制
- (IBAction)beginRecordAction:(UIButton *)sender {
    [SVProgressHUD showSuccessWithStatus:@"开始录制"];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];

    NSError *error = nil;

    if (nil == self.recorder) {
        self.recorder =
            [[AVAudioRecorder alloc] initWithURL:self.recordTempFileURL settings:self.recordSettings error:&error];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
    }
    // 准备录音
    [self.recorder prepareToRecord];
    // 开始录音
    [self.recorder record];
}

// 结束录制并发送
- (IBAction)endAndSendAction:(UIButton *)sender {
    if ((self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_GROUP)
        && self.targetIdTextField.text.length > 0) {
        if (!self.recorder.url)
            return;
        NSURL *url = [[NSURL alloc] initWithString:self.recorder.url.absoluteString];
        // 当前录音时长
        NSTimeInterval audioLength = self.recorder.currentTime;
        // 停止录音
        [self.recorder stop];
        // 录音文件 data
        NSData *currentRecordData = [NSData dataWithContentsOfURL:url];
        self.recorder = nil;
        // 将语音从临时路径放到永久路径。
        NSString *path = [self getHQVoiceMessageCachePath];
        [currentRecordData writeToFile:path atomically:YES];
        // 构造高清语音消息
        RCHQVoiceMessage *hqVoiceMsg = [RCHQVoiceMessage messageWithPath:path duration:audioLength];
        // 发送消息
        [[RCIMClient sharedRCIMClient] sendMediaMessage:self.conversationType targetId:self.targetIdTextField.text content:hqVoiceMsg pushContent:nil pushData:nil progress:^(int progress, long messageId) {
            
        } success:^(long messageId) {
            NSLog(@"--- 发送消息成功");
            [SVProgressHUD showSuccessWithStatus:@"发送成功"];
        } error:^(RCErrorCode errorCode, long messageId) {
            NSLog(@"--- 发送消息失败 %ld", errorCode);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发送失败 code: %ld",(long)errorCode]];
        } cancel:^(long messageId) {
            
        }];
    }
}

// 语音消息本地路径
- (NSString *)getHQVoiceMessageCachePath {
    long long currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *path = [RCUtilities rongImageCacheDirectory];
    path = [path
        stringByAppendingFormat:@"/%@/RCHQVoiceCache", [RCIMClient sharedRCIMClient].currentUserInfo.userId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"/Voice_%@.m4a", @(currentTime)];
    path = [path stringByAppendingPathComponent:fileName];
    NSLog(@"--- path %@", path);
    return path;
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
