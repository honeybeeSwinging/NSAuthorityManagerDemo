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

#import <Foundation/Foundation.h>
#import "NSAuthorityStatus.h"
#import "NSAuthorityProtocol.h"
#import "NSAuthoritySingleton.h"
#import "NSAuthorityManager.h"

@interface NSAuthorityManager : NSObject NSSingletonH(Instance);

#pragma mark - 定位
+(CLAuthorizationStatus)currentLocationStatus;
+(NSString *)currentLocationStatusString;
+(void)beginLocationNotification:(id<LocationStatusProtocol>)listener;
+(void)endLocationNotification:(id<LocationStatusProtocol>)listener;
/**
* @brief 是否开启定位权限
 */
+(BOOL)isObtainLocationAuthority;
-(void)obtainCLLocationAlwaysAuthorizedStatus; //始终访问位置信息
-(void)obtainCLLocationWhenInUseAuthorizedStatus; //使用时访问位置信息

#pragma mark - 蓝牙
//+(CBManagerState)currentBluetoothStatus;
//+(NSString *)currentBluetoothStatusString;
//+(void)beginBluetoothNotification:(id<BluetoothStatusProtocol>)listener;
//+(void)endBluetoothLocationNotification:(id<BluetoothStatusProtocol>)listener;
/**
* @brief 是否开启 蓝牙开启权限
*/
//+(BOOL)isObtainBluetoothAuthority;
-(void)obtainBluetoothAuthorizedStatus;

#pragma mark - 推送
//+(UIUserNotificationSettings*)currentUserNotificaionStatus;
//+(NSString *)currentUserNotificaionStatusString;
//+(void)beginUserNotification:(id<UserNotificationStatusProtocol>)listener;
//+(void)endUserNotificaion:(id<UserNotificationStatusProtocol>)listener;
//+(BOOL)isObtainUserNotificationAuthority;
-(void)obtainUserNotificationAuthorizedStatus;


#pragma mark - 媒体资料库
/**
* @brief 是否开启媒体资料库权限
 */
+(BOOL)isObtainMediaAuthority;
-(void)obtainMPMediaAuthorizedStatus;

#pragma mark - 语音识别
/**
* @brief 是否开启语音识别权限
 */
+(BOOL)isObtainSpeechAuthority;
-(void)obtainSFSpeechAuthorizedStatus;

#pragma mark - 日历权限
/**
 * @brief 是否开启日历权限
 */
+(BOOL)isObtainEKEventAuthority;
-(void)obtainEKEventAuthorizedStatus; //开启日历权限

#pragma mark - 相册权限
/**
 * @brief 是否开启相册权限
 */
+(BOOL)isObtainPhPhotoAuthority;
-(void)obtainPHPhotoAuthorizedStaus; //开启相册权限

#pragma mark - 相机权限
/**
 * @brief 是否开启相机权限
 */
+(BOOL)isObtainAVVideoAuthority;
-(void)obtainAVMediaVideoAuthorizedStatus;

#pragma mark - 通讯录权限
/**
 * @brief 是否开启通讯录权限
 */
+(BOOL)isObtainCNContactAuthority;
-(void)obtainCNContactAuthorizedStatus;

#pragma mark - 麦克风权限
/**
 * @brief 是否开启麦克风权限
 */
+(BOOL)isObtainAVAudioAuthority;
-(void)obtainAVMediaAudioAuthorizedStatus;

#pragma mark - 提醒事项权限
/**
 * @brief 是否开启提醒事项权限
 */
+(BOOL)isObtainReminder;
-(void)obtainEKReminderAuthorizedStatus;

#pragma mark - 运动与健身
/**
 * @brief 开启运动与健身权限(需要的运动权限自己再加,目前仅有"步数"、"步行+跑步距离"、"心率")
 */
-(void)obtainHKHealthAuthorizedStatus;

@end
