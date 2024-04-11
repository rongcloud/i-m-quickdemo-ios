//
//  RecordVoiceMessageVC.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/22.
//

#import "RecordVoiceMessageVC.h"
#import <AVFoundation/AVFoundation.h>
/**
        IMLib 发送普通语音消息示例。代码仅供参考，具体更细节的逻辑需要您完善。
 */
@interface RecordVoiceMessageVC ()<AVAudioRecorderDelegate>
@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, strong) NSURL *urlPlay;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@end

@implementation RecordVoiceMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"普通语音消息";
    self.conversationType = ConversationType_PRIVATE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
// 开始录制
- (IBAction)beginRecordAction:(UIButton *)sender {
    [SVProgressHUD showSuccessWithStatus:@"开始录制"];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatLinearPCM),  // 设置录音格式
                               AVSampleRateKey: @8000.00f, // 设置录音采样率
                               AVNumberOfChannelsKey: @1,  //录音通道数
                               AVLinearPCMBitDepthKey: @16,   //线性采样位数
                               AVLinearPCMIsNonInterleaved: @NO,
                               AVLinearPCMIsFloatKey: @NO,
                               AVLinearPCMIsBigEndianKey: @NO};
    //获取沙盒路径 作为存储录音文件的路径
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempAC.wav"]];
    NSLog(@"路径 %@", url.absoluteString);
    self.urlPlay= url;
   
    if (!self.recorder){
        NSError* error;
        //初始化AVAudioRecorder
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        if(error){
            NSLog(@"创建录音对象时发生错误，错误信息：%@",error.localizedDescription);
        }
    }
        
    if([self.recorder prepareToRecord]){
        [self.recorder record];
        NSLog(@"开始录音");
    }

    
}
// 结束录制并发送
- (IBAction)endAndSendAction:(UIButton *)sender {
    if ((self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_GROUP)
        && self.targetIdTextField.text.length > 0) {
        // 当前的录音时间，录音时有效；停止录音的时候为0
        long voiceSize = self.recorder.currentTime;
        NSLog(@"录音时长 = %ld", voiceSize);
        
        //此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.recorder stop];
        NSLog(@"录音结束");
        if (!self.recorder.url) {
            return;
        }
        NSData *currentRecordData = [NSData dataWithContentsOfURL:self.recorder.url];
       
        self.recorder = nil;
        
        RCVoiceMessage *message = [RCVoiceMessage messageWithAudio:currentRecordData duration:voiceSize];
        [[RCCoreClient sharedCoreClient] sendMessage:self.conversationType targetId:self.targetIdTextField.text content:message pushContent:nil pushData:nil success:^(long messageId) {
            [SVProgressHUD showSuccessWithStatus:@"发送成功"];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"发送失败 code: %ld",(long)nErrorCode]];
        }];
    }
}


@end
