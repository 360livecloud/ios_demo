//
//  QHVCShortVideoMacro.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/24.
//  Copyright © 2019 yangkui. All rights reserved.
//

#ifndef QHVCShortVideoMacro_h
#define QHVCShortVideoMacro_h

//block
#define SAFE_BLOCK(block, ...) if((block)) { block(__VA_ARGS__); }

#define SAFE_BLOCK_IN_MAIN_QUEUE(block, ...) if((block)) {\
if ([NSThread isMainThread]) {\
block(__VA_ARGS__);\
}\
else {\
dispatch_async(dispatch_get_main_queue(), ^{\
block(__VA_ARGS__);\
});\
}\
}

//self
#define WEAK_SELF    __weak __typeof(&*self) weakSelf = self;
#define STRONG_SELF  __strong __typeof(&*self) self = weakSelf;

static const NSString* demo_access_key = @"edit_demo";
static const NSString* demo_secret_key = @""; //如果需要体验，请联系我们


#endif /* QHVCShortVideoMacro_h */
