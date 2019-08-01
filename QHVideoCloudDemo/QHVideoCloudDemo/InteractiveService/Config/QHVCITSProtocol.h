//
//  QHVCITSProtocol.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#ifndef QHVCITSProtocol_h
#define QHVCITSProtocol_h

#define QHVCITSPROTOCOL_USER_LOGIN                        @"/api/userLogin"//用户登录
#define QHVCITSPROTOCOL_GET_ROOM_LIST                     @"/api/getRoomList"//返回房间列表
#define QHVCITSPROTOCOL_GET_ROOM_INFO                     @"/api/getRoomInfo"//获取房间信息
#define QHVCITSPROTOCOL_CREATE_ROOM                       @"/api/createRoom"//创建房间
#define QHVCITSPROTOCOL_JOIN_ROOM                         @"/api/joinRoom"//加入房间
#define QHVCITSPROTOCOL_GET_ROOM_USER_LIST                @"/api/getRoomUserList"//获取房间用户列表
#define QHVCITSPROTOCOL_CHANGE_USER_IDENTITY              @"/api/changeUserIdentity"//改变 嘉宾/观众 身份标识
#define QHVCITSPROTOCOL_USER_LEAVE_ROOM                   @"/api/userLeaveRoom"//用户离开房间
#define QHVCITSPROTOCOL_DISMISS_ROOM                      @"/api/dismissRoom"//主播解散房间
#define QHVCITSPROTOCOL_USER_HEART                        @"/api/userHeart"//用户心跳(暂未实现)
#define QHVCITSPROTOCOL_JOIN_LINK_ROOM                    @"/api/joinLinkRoom"//加入互动房间
#define QHVCITSPROTOCOL_LEAVE_LINK_ROOM                   @"/api/leaveLinkRoom"//退出互动房间
#define QHVCITSPROTOCOL_SEND_USER_MESSAGE                 @"/api/sendUserMessage"//给单个用户推送消息
#define QHVCITSPROTOCOL_SEND_ROOM_MESSAGE                 @"/api/sendRoomMessage"//给房间用户推送消息

#endif /* QHVCITSProtocol_h */
