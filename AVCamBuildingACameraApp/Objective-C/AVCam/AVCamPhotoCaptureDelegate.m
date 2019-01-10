/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the photo capture delegate.
*/


#import "AVCamPhotoCaptureDelegate.h"

@import Photos;

@interface AVCamPhotoCaptureDelegate ()

@property (nonatomic, readwrite) AVCapturePhotoSettings* requestedPhotoSettings;
@property (nonatomic) void (^willCapturePhotoAnimation)(void);
@property (nonatomic) void (^livePhotoCaptureHandler)(BOOL capturing);
@property (nonatomic) void (^completionHandler)(AVCamPhotoCaptureDelegate* photoCaptureDelegate);

@property (nonatomic) NSData* photoData;
@property (nonatomic) NSURL* livePhotoCompanionMovieURL;
@property (nonatomic) NSData* portraitEffectsMatteData;

@end

@implementation AVCamPhotoCaptureDelegate

- (instancetype) initWithRequestedPhotoSettings:(AVCapturePhotoSettings*)requestedPhotoSettings willCapturePhotoAnimation:(void (^)(void))willCapturePhotoAnimation livePhotoCaptureHandler:(void (^)(BOOL))livePhotoCaptureHandler completionHandler:(void (^)(AVCamPhotoCaptureDelegate*))completionHandler
{
    self = [super init];
    if ( self ) {
        self.requestedPhotoSettings = requestedPhotoSettings;
        self.willCapturePhotoAnimation = willCapturePhotoAnimation;
        self.livePhotoCaptureHandler = livePhotoCaptureHandler;
        self.completionHandler = completionHandler;
    }
    return self;
}

- (void) didFinish
{
    if ( [[NSFileManager defaultManager] fileExistsAtPath:self.livePhotoCompanionMovieURL.path] ) {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.livePhotoCompanionMovieURL.path error:&error];
        
        if ( error ) {
            NSLog( @"Could not remove file at url: %@", self.livePhotoCompanionMovieURL.path );
        }
    }
    
    self.completionHandler( self );
}
//通知代理扫描的设置已经配置好，即将开始扫描处理。
//这个photo output 调用这个方法，当他已经提交一个设置，即将开始一个扫描处理，这个方法出现早于你调用
//capturePhotoWithSettings:delegate: 方法，
#pragma mark ---- 图片 11111111111111111111
- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings
{
    NSLog(@"%s",__func__);
    if ( ( resolvedSettings.livePhotoMovieDimensions.width > 0 ) && ( resolvedSettings.livePhotoMovieDimensions.height > 0 ) ) {
        self.livePhotoCaptureHandler( YES );
    }
}
//通知代理photo capture 即将出现
//这个photo output调用这个方法尽可能的接近于扫描的初始化，实时照片捕获禁用快门声音。在某些地区，设备的静音开关可以禁用快门声音。
#pragma mark ---- 图片 22222222222222222222
- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings
{
    NSLog(@"%s",__func__);

    self.willCapturePhotoAnimation();
}
//使用此方法接收照片捕获的结果，而不考虑格式。
//对于要在捕获请求中传递的每个主图像，照片输出调用此方法一次。如果您请求以原始和已处理的格式进行捕获，那么对于每个格式，此方法都会触发一次。如果您请求用多个曝光进行带括号的捕获，则此方法对每个曝光触发一次。
#pragma mark ---- 图片 33333333333333333333
- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishProcessingPhoto:(AVCapturePhoto*)photo error:(nullable NSError*)error
{
    NSLog(@"%s",__func__);

    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        return;
    }
    
    self.photoData = [photo fileDataRepresentation];
    
    // Portrait Effects Matte only gets generated if there is a face
//    if ( photo.portraitEffectsMatte != nil ) {
//        CGImagePropertyOrientation orientation = [[photo.metadata objectForKey:(NSString*)kCGImagePropertyOrientation] intValue];
//        AVPortraitEffectsMatte* portraitEffectsMatte = [photo.portraitEffectsMatte portraitEffectsMatteByApplyingExifOrientation:orientation];
//        CVPixelBufferRef portraitEffectsMattePixelBuffer = [portraitEffectsMatte mattingImage];
//        CIImage* portraitEffectsMatteImage = [CIImage imageWithCVPixelBuffer:portraitEffectsMattePixelBuffer options:@{ kCIImageAuxiliaryPortraitEffectsMatte : @(YES) }];
//        CIContext* context = [CIContext context];
//        CGColorSpaceRef linearColorSpace = CGColorSpaceCreateWithName( kCGColorSpaceLinearSRGB );
//        self.portraitEffectsMatteData = [context HEIFRepresentationOfImage:portraitEffectsMatteImage format:kCIFormatRGBA8 colorSpace:linearColorSpace options:@{ (id)kCIImageRepresentationPortraitEffectsMatteImage : portraitEffectsMatteImage} ];
//    }
//    else {
//        self.portraitEffectsMatteData = nil;
//    }
}
// 通知代理,一个LivePhoto的内容已经完成了记录
// photo outPut 扫描完一个a Live Photo里的所有电影数据，调用这个方法，然而这时，这个电影的内容并没有被处理或者写入到储存，（所有的电影文件已经被完成写入并且准备消费，通过实现这个方法通知我们- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL *)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(NSError *)error;
//使用这个方法决定，当适当的改变你的UI去表明LivePhoto 电影扫描不在被处理，例如
//例如照相机app当用户处理shutter button，当电影扫描完成之后隐藏它，展示‘LIVE’icon
//这个电影输出调用这个方法仅仅一次，对于每一个LivePhoto扫描
//）
- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL*)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings
{
    NSLog(@"%s",__func__);

    self.livePhotoCaptureHandler(NO);
}

#pragma mark --使用这个方法接收一个livePhoto capture扫描的结果，当这个照片输出调用这个方法，这个电影已经组件已经被写入到特定的位置，（为了接收一个持续的图片组件，实现- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error;-----为了添加一个被扫描的LivePhotos到用户的PhotosLibrary 使用PHAssetCreationRequest class 为了使用LivePhotos 来自Photos library 使用PHLivePhoto 和 PHLivePhotoView的类，为了在web中展示LivePhoto的内容，使用LivePhotoKit JS framework.如果你不是正在请求LivePhoto扫描，你不需要实现这个方法；如果你请求一个Live Photo 扫描，你必须实现这个方法（通过设置livePhotoMovieFileURL属性你的photosettingsobject）如果不实现这个方法就会抛出一个异常。
- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL*)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings error:(NSError*)error
{
    NSLog(@"%s",__func__);

    if ( error != nil ) {
        NSLog( @"Error processing Live Photo companion movie: %@", error );
        return;
    }
    
    self.livePhotoCompanionMovieURL = outputFileURL;
}
#pragma mark -- 通知代理扫描处理完成了 当整个扫描处理已经完成了，photo output调用这个方法，并且代理不会再被发送扫描请求，使用这个方法的同时清除所有与扫描请求相连接的资源
#pragma mark ---- 图片 44444444444444444444444444444
- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings error:(NSError*)error
{
    NSLog(@"%s",__func__);
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        [self didFinish];
        return;
    }
    
    if ( self.photoData == nil ) {
        NSLog( @"No photo data resource" );
        [self didFinish];
        return;
    }
    
    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
        if ( status == PHAuthorizationStatusAuthorized ) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetResourceCreationOptions* options = [[PHAssetResourceCreationOptions alloc] init];
                options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType;
                PHAssetCreationRequest* creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:self.photoData options:options];
                
                if ( self.livePhotoCompanionMovieURL ) {
                    PHAssetResourceCreationOptions* livePhotoCompanionMovieResourceOptions = [[PHAssetResourceCreationOptions alloc] init];
                    livePhotoCompanionMovieResourceOptions.shouldMoveFile = YES;
                    [creationRequest addResourceWithType:PHAssetResourceTypePairedVideo fileURL:self.livePhotoCompanionMovieURL options:livePhotoCompanionMovieResourceOptions];
                }
                
                // Save Portrait Effects Matte to Photos Library only if it was generated
                if ( self.portraitEffectsMatteData ) {
                    PHAssetCreationRequest* creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:self.portraitEffectsMatteData options:nil];
                }
                
            } completionHandler:^( BOOL success, NSError* _Nullable error ) {
                if ( ! success ) {
                    NSLog( @"Error occurred while saving photo to photo library: %@", error );
                }
                
                [self didFinish];
            }];
        }
        else {
            NSLog( @"Not authorized to save photo" );
            [self didFinish];
        }
    }];
}

@end
