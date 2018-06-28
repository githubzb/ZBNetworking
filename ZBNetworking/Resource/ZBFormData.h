//
//  ZBFormData.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ZBMimeTypeImageOfPNG;
FOUNDATION_EXPORT NSString *const ZBMimeTypeImageOfJPG;
FOUNDATION_EXPORT NSString *const ZBMimeTypeImageOfJPEG;
FOUNDATION_EXPORT NSString *const ZBMimeTypeFileOfGZIP;
FOUNDATION_EXPORT NSString *const ZBMimeTypeFileOfZIP;
FOUNDATION_EXPORT NSString *const ZBMimeTypeFileOfPDF;
FOUNDATION_EXPORT NSString *const ZBMimeTypeAudioOfMP4;

typedef NS_ENUM(NSInteger, ZBFormDataType) {
    
    ZBFormDataTypeFileData = 0,
    ZBFormDataTypeFileURL = 1
};

@interface ZBFormData : NSObject

///文件字段名称
@property (nonatomic, copy) NSString *name;
///文件data
@property (nonatomic, copy) NSData *data;
///文件URL地址
@property (nonatomic, strong) NSURL *fileURL;
///文件名
@property (nonatomic, copy) NSString *fileName;
///mimeType
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, assign, readonly) ZBFormDataType type;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString *)fileName
                    mimeType:(NSString *)mimeType NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFileURL:(NSURL *)url
                           name:(NSString *)name
                       fileName:(NSString *)fileName
                       mimeType:(NSString *)mimeType NS_DESIGNATED_INITIALIZER;

+ (instancetype)formData:(NSData *)data
                    name:(NSString *)name
                fileName:(NSString *)fileName
                mimeType:(NSString *)mimeType;

+ (instancetype)formDataURL:(NSURL *)url
                       name:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType;

@end

ZBFormData * formPngDATA(NSData *data, NSString *name, NSString *fileName);
ZBFormData * formJpgDATA(NSData *data, NSString *name, NSString *fileName);
ZBFormData * formJpegDATA(NSData *data, NSString *name, NSString *fileName);
ZBFormData * formGZipDATA(NSData *data, NSString *name, NSString *fileName);
ZBFormData * formZipDATA(NSData *data, NSString *name, NSString *fileName);
ZBFormData * formPdfDATA(NSData *data, NSString *name, NSString *fileName);
ZBFormData * formMp4DATA(NSData *data, NSString *name, NSString *fileName);

ZBFormData * formPngURL(NSURL *fileURL, NSString *name, NSString *fileName);
ZBFormData * formJpgURL(NSURL *fileURL, NSString *name, NSString *fileName);
ZBFormData * formJpegURL(NSURL *fileURL, NSString *name, NSString *fileName);
ZBFormData * formGZipURL(NSURL *fileURL, NSString *name, NSString *fileName);
ZBFormData * formZipURL(NSURL *fileURL, NSString *name, NSString *fileName);
ZBFormData * formPdfURL(NSURL *fileURL, NSString *name, NSString *fileName);
ZBFormData * formMp4URL(NSURL *fileURL, NSString *name, NSString *fileName);

NS_ASSUME_NONNULL_END
