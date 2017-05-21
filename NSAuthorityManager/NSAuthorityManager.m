// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSAuthorityManager.h"

static NSString *const kLocationStatusChangeNotification = @"locationStatusChangeNotification";
static NSString *const kBluetoothStatusChangeNotification = @"bluetoothStatusChangeNotification";
static NSString *const kUserNotificationStatusChangeNotification = @"userNotificationStatusChangeNotification";

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define kStartProgramAuthority [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@""} completionHandler:^(BOOL success) { }];

@interface NSAuthorityManager()
@property (nonatomic,strong) CLLocationManager *locationManager; //定位
@property (nonatomic,copy) NSString *currentLocationStatus; //当前定位权限
@property (nonatomic,assign) BOOL isNotiLocationStatus; //是否在监听定位权限

@property (nonatomic,strong) CBCentralManager *centralManager; //蓝牙
@end

@implementation NSAuthorityManager NSSingletonM(Instance);

#pragma mark - 定位
+(CLAuthorizationStatus)currentLocationStatus{
    NSAuthorityManager *manager = [NSAuthorityManager sharedInstance];
    return [manager statusOfCurrentLocation];
}
+(NSString *)currentLocationStatusString{
    NSAuthorityManager *manager = [NSAuthorityManager sharedInstance];
    return [NSString stringWithFormat:@"%d",[manager statusOfCurrentLocation]];
}
-(CLAuthorizationStatus)statusOfCurrentLocation{
    BOOL isLocation = [CLLocationManager locationServicesEnabled];
    if (!isLocation) {
        DLog(@"定位权限:未起开定位开关(not turn on the location)");
    }
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            DLog(@"定位权限:同意一直使用(Always Authorized)");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            DLog(@"定位权限:使用期间同意使用(AuthorizedWhenInUse)");
            break;
        case kCLAuthorizationStatusDenied:
            DLog(@"定位权限:拒绝(Denied)");
            break;
        case kCLAuthorizationStatusNotDetermined:
            DLog(@"定位权限:未进行授权选择(not Determined)");
            break;
        case kCLAuthorizationStatusRestricted:
            DLog(@"定位权限:未授权(Restricted)");
            break;
        default:
            break;
    }
    return status;
}

+(void)beginLocationNotification:(id<LocationStatusProtocol>)listener{
    NSAuthorityManager *manager = [NSAuthorityManager sharedInstance];
    
    if (manager.isNotiLocationStatus) {
        DLog(@"已经在监听locationStatus");
        [self endLocationNotification:(id<LocationStatusProtocol>)listener];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:listener selector:@selector(locationStatusChangeNotification:) name:kLocationStatusChangeNotification object:manager];
    manager.isNotiLocationStatus = YES;
}
+(void)endLocationNotification:(id<LocationStatusProtocol>)listener{
    NSAuthorityManager *manager = [NSAuthorityManager sharedInstance];
    
    if (!manager.isNotiLocationStatus) {
        DLog(@"locationStatus监听已关闭");
        return;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:listener name:kLocationStatusChangeNotification object:manager];
    manager.isNotiLocationStatus = NO;
}
-(void)locationStatusChangeNotification:(NSNotification *)notification{
    if (notification.name == kLocationStatusChangeNotification && notification.object != nil) {
        self.currentLocationStatus = [self currentLocationStatus];
    }
    
    NSDictionary *userInfo = @{@"currentLocationStatus":@([NSAuthorityManager currentLocationStatus]),
                               @"currentLocationStatusString":[NSAuthorityManager currentLocationStatusString]};
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kLocationStatusChangeNotification object:self userInfo:userInfo];
}

+(BOOL)isObtainLocationAuthority{
    if ([self currentLocationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse | [self currentLocationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        return YES;
    }else{
        return NO;
    }
}

-(void)obtainCLLocationAlwaysAuthorizedStatus{
    _locationManager = [[CLLocationManager alloc]init];
    [_locationManager requestAlwaysAuthorization];
}
-(void)obtainCLLocationWhenInUseAuthorizedStatus{
    _locationManager = [[CLLocationManager alloc]init];
    [_locationManager requestWhenInUseAuthorization];
}

#pragma mark - 蓝牙
//+(BOOL)isObtainBluetoothAuthority{
//}
-(void)obtainBluetoothAuthorizedStatus{
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    CBManagerState state = [_centralManager state];
    if (state == CBManagerStateUnknown) {
        DLog(@"蓝牙开启权限:未知");
    }else if (state == CBManagerStateUnauthorized){
        DLog(@"蓝牙开启权限:未授权");
    }else{
        DLog(@"蓝牙开启权限:开启");
    }
}
#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //第一次打开或者每次蓝牙状态改变都会调用这个函数
    if(central.state==CBManagerStatePoweredOn){
        NSLog(@"蓝牙状态代理:开着");
    }else{
        NSLog(@"蓝牙状态代理:关着");
//        kStartProgramAuthority
    }
    
}

#pragma mark - 推送
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//+(BOOL)isObtainUserNotificationAuthority{
//    UIUserNotificationSettings *noti = [[UIApplication sharedApplication]currentUserNotificationSettings];
//    if (noti == UIUserNotificationTypeNone) {
//        DLog(@"推送权限:无");
//        return NO;
//    }else if (noti == UIUserNotificationTypeAlert){
//        DLog(@"推送权限:Alert");
//        return YES;
//    }else if (noti == UIUserNotificationTypeBadge){
//        DLog(@"推送权限:Badge");
//        return YES;
//    }else if (noti == UIUserNotificationTypeSound){
//        DLog(@"推送权限:Sound");
//        return YES;
//    }
//    return YES;
//}
//#pragma clang diagnostic pop
-(void)obtainUserNotificationAuthorizedStatus{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if(granted){
                                  NSLog(@"推送开启权限:授权成功");
                              }else{
                                  DLog(@"推送开启权限:授权失败");
                              }
                          }];
}

#pragma mark - 媒体资料库权限
+(BOOL)isObtainMediaAuthority{
    MPMediaLibraryAuthorizationStatus status = [MPMediaLibrary authorizationStatus];
    if (status == MPMediaLibraryAuthorizationStatusNotDetermined) {
        DLog(@"媒体资料库权限:未选择权限(NotDetermined)");
        return NO;
    }else if (status == MPMediaLibraryAuthorizationStatusDenied){
        DLog(@"媒体资料库权限:拒绝(enied)");
        return NO;
    }else if (status == MPMediaLibraryAuthorizationStatusRestricted){
        DLog(@"媒体资料库权限:未授权(Restricted)");
        return NO;
    }
        DLog(@"媒体资料库权限:已授权(Authorized)");
    return YES;
}
-(void)obtainMPMediaAuthorizedStatus{
    MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
    if (authStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (status == MPMediaLibraryAuthorizationStatusNotDetermined) {
                DLog(@"媒体资料库开启权限:未选择权限(NotDetermined)");
            }else if (status == MPMediaLibraryAuthorizationStatusDenied){
                DLog(@"媒体资料库开启权限:拒绝(enied)");
            }else if (status == MPMediaLibraryAuthorizationStatusRestricted){
                DLog(@"媒体资料库开启权限:未授权(Restricted)");
            }else if (status == MPMediaLibraryAuthorizationStatusAuthorized){
                DLog(@"媒体资料库开启权限:已授权(Authorized)");
            }
            
        }];
    }
}

#pragma mark - 语音识别
+(BOOL)isObtainSpeechAuthority{
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        DLog(@"语音识别权限:未选择权限(NotDetermined)");
        return NO;
    }else if (status == SFSpeechRecognizerAuthorizationStatusDenied){
        DLog(@"语音识别权限:用户拒绝App使用(Denied)");
        return NO;
    }else if (status == SFSpeechRecognizerAuthorizationStatusRestricted){
        DLog(@"语音识别权限:未授权(Restricted)");
        return NO;
    }
        DLog(@"语音识别权限:已授权(Authorized)"); //SFSpeechRecognizerAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainSFSpeechAuthorizedStatus{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
            DLog(@"语音识别开启权限:未选择权限(NotDetermined)");
        }else if (status == SFSpeechRecognizerAuthorizationStatusDenied){
            DLog(@"语音识别开启权限:用户拒绝App使用(Denied)");
        }else if (status == SFSpeechRecognizerAuthorizationStatusRestricted){
            DLog(@"语音识别开启权限:未授权(Restricted)");
        }else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized){
            DLog(@"语音识别开启权限:已授权(Authorized)");
        }
    }];
}

#pragma mark - 日历权限
+(BOOL)isObtainEKEventAuthority{
    EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusDenied) {
        DLog(@"日历权限:用户拒绝App使用(Denied)");
        return NO;
    }else if (status == EKAuthorizationStatusNotDetermined){
        DLog(@"相册权限:未选择权限(NotDetermined)");
        return NO;
    }else if (status == EKAuthorizationStatusRestricted){
        DLog(@"相册权限:未授权(Restricted)");
        return NO;
    }
    DLog(@"日历权限:已授权(Authorized)"); //EKAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainEKEventAuthorizedStatus{
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            DLog(@"日历开启权限:已授权(Authorized)");
        }else{
            DLog(@"日历开启权限:拒绝或未授权(Denied or Restricted)");
        }
    }];
}

#pragma mark - 相册权限
+(BOOL)isObtainPhPhotoAuthority{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        DLog(@"相册权限:用户拒绝开启权限(Denied)");
        return NO;
    }else if (status == PHAuthorizationStatusNotDetermined){
        DLog(@"相册权限:未选择权限(NotDetermined)");
        return NO;
    }else if (status == PHAuthorizationStatusRestricted){
        DLog(@"相册权限:未授权(Restricted)");
        return NO;
    }
       DLog(@"相册权限:已授权(Authorized)"); // PHAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainPHPhotoAuthorizedStaus{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == 3) {
            DLog(@"相册开启权限:获取");
        }else{
            DLog(@"相册开启权限:暂无");
        }
    }];
}

#pragma mark - 相机权限
+(BOOL)isObtainAVVideoAuthority{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        DLog(@"相机权限:未进行授权选择(Denied)");
        return NO;
    }else if (status == AVAuthorizationStatusNotDetermined){
        DLog(@"相机权限:未进行授权选择(NotDetermined)");
        return NO;
    }else if (status == AVAuthorizationStatusRestricted){
        DLog(@"相机权限:未授权(Restricted)");
        return NO;
    }
        DLog(@"相机权限:已授权(Authorized)"); //AVAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainAVMediaVideoAuthorizedStatus{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            DLog(@"相机开启权限:已授权");
        }else{
            DLog(@"相机开启权限:拒绝或未授权");
        }
    }];
}

#pragma mark - 通讯录权限
+(BOOL)isObtainCNContactAuthority{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied) {
        DLog(@"通讯录权限:拒绝(Denied)");
        return NO;
    }else if (status == CNAuthorizationStatusRestricted){
        DLog(@"通讯录权限:未选择(not Determined)");
        return NO;
    }else if (status == CNAuthorizationStatusNotDetermined){
        DLog(@"通讯录权限:未授权(Restricted)");
        return NO;
    }
    DLog(@"通讯录权限:已授权(Authorized)"); //CNAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainCNContactAuthorizedStatus{
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            DLog(@"通讯录开启权限:已授权(Authorized)");
        }else{
            DLog(@"通讯录开启权限:拒绝或未授权(Denied or Restricted)");
        }
    }];
}

#pragma mark - 麦克风权限
+(BOOL)isObtainAVAudioAuthority{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusDenied) {
        DLog(@"麦克风权限:拒绝(Denied)");
        return NO;
    }else if (status == AVAuthorizationStatusNotDetermined){
        DLog(@"麦克风权限:未进行授权选择(NotDetermined)");
        return NO;
    }else if (status == AVAuthorizationStatusRestricted){
        DLog(@"麦克风权限:未授权(Restricted)");
        return NO;
    }
        DLog(@"麦克风权限:已授权(Authorized)"); //AVAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainAVMediaAudioAuthorizedStatus{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {//麦克风权限
        if (granted) {
            DLog(@"麦克风开启权限:获取");
        }else{
            DLog(@"麦克风开启权限:拒绝或未授权");
        }
    }];
}

#pragma mark - 提醒事项权限
+(BOOL)isObtainReminder{
   EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusDenied) {
        DLog(@"备忘录权限:用户拒绝App使用(Denied)");
        return NO;
    }else if (status == EKAuthorizationStatusNotDetermined){
        DLog(@"备忘录权限:未选择权限(NotDetermined)");
        return NO;
    }else if (status == EKAuthorizationStatusRestricted){
        DLog(@"备忘录册权限:未授权(Restricted)");
        return NO;
    }
        DLog(@"备忘录权限:已授权(Authorized)"); //EKAuthorizationStatusAuthorized
    return YES;
}
-(void)obtainEKReminderAuthorizedStatus{
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            DLog(@"提醒事项开启权限:已授权(Authorized)");
        }else{
            DLog(@"提醒事项开启权限:拒绝或未授权(Denied or Restricted)");
        }
    }];
}

#pragma mark - 运动与健身
-(void)obtainHKHealthAuthorizedStatus{
    HKHealthStore *health = [[HKHealthStore alloc]init];
    //、跑步距离、身高体重、
    NSSet *readObjectTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                              [HKObjectType quantityTypeForIdentifier:
                               HKQuantityTypeIdentifierDistanceWalkingRunning],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],nil];
    [health requestAuthorizationToShareTypes:nil readTypes:readObjectTypes completion:^(BOOL success, NSError * _Nullable error) {
        if (success == YES) {
            DLog(@"运动与健身开启权限:成功");
        }else{
            DLog(@"运动与健身开启权限:失败");
        }
    }];
}

@end
