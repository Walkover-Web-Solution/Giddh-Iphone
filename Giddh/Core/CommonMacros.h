//
//  CommonMacros.h
//  Giddh
//
//  Created by Admin on 15/04/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#ifndef Giddh_CommonMacros_h
#define Giddh_CommonMacros_h

#define DECLARE_SINGLETON_METHOD(classname, sharedInstanceMethodName) \
+ (classname *)sharedInstanceMethodName;

#define SYNTHESIZE_SINGLETON_METHOD(classname, sharedInstanceMethodName) \
\
+ (classname *)sharedInstanceMethodName \
{ \
static classname *_##sharedInstanceMethodName = nil; \
static dispatch_once_t oncePredicate; \
dispatch_once(&oncePredicate, ^{ \
_##sharedInstanceMethodName = [[classname alloc] init]; \
}); \
\
return _##sharedInstanceMethodName; \
}


#endif
