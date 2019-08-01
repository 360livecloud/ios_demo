//
//  QHVCGVProtocol.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#ifndef QHVCGVProtocol_h
#define QHVCGVProtocol_h

#define QHVCGVProtocol_Register                 @"/device/register"     // 用户注册
#define QHVCGVProtocol_BindDevice               @"/device/bind"         // 绑定设备
#define QHVCGVProtocol_DeviceList               @"/device/bindList"     // 获取设备列表
#define QHVCGVProtocol_unbindDevice             @"/device/unbind"       // 解除绑定
#define QHVCGVProtocol_ModifyDeviceInfo         @"/device/modify"       // 修改设备信息
#define QHVCGVProtocol_Register                 @"/device/register"     // 用户注册
#define QHVCGVProtocol_Login                    @"/device/login"        // 用户登录
#define QHVCGVProtocol_GetStreamPwd             @"/device/getPwd"       // 获取流加密的密码
#define QHVCGVProtocol_GetCloudRecordList       @"/Device/getBackList"  // 获取用户已绑定的设备云存信息
#define QHVCGVProtocol_DeleteCloudRecord        @"/Device/delBackEvent" // 删除设备回看

#endif /* QHVCGVProtocol_h */
