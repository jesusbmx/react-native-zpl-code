#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ZplCode, NSObject)

RCT_EXTERN_METHOD(imageToZpl:
    (NSDictionary *) props
    resolve: (RCTPromiseResolveBlock) resolve
    reject: (RCTPromiseRejectBlock) reject
)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
