//
//  ZBFormData.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBFormData.h"

NSString *const ZBMimeTypeImageOfPNG = @"image/png";
NSString *const ZBMimeTypeImageOfJPG = @"image/jpg";
NSString *const ZBMimeTypeImageOfJPEG = @"image/jpeg";
NSString *const ZBMimeTypeFileOfGZIP = @"application/gzip";
NSString *const ZBMimeTypeFileOfZIP = @"application/zip";
NSString *const ZBMimeTypeFileOfPDF = @"application/pdf";
NSString *const ZBMimeTypeAudioOfMP4 = @"audio/mp4";

@implementation ZBFormData

- (instancetype)init{
    return nil;
}

- (instancetype)initWithData:(NSData *)data
                        name:(NSString *)name
                    fileName:(NSString *)fileName
                    mimeType:(NSString *)mimeType
{
    self = [super init];
    if (self) {
        self.name = name;
        self.data = data;
        self.fileName = fileName;
        self.mimeType = mimeType;
        _type = ZBFormDataTypeFileData;
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)url
                           name:(NSString *)name
                       fileName:(NSString *)fileName
                       mimeType:(NSString *)mimeType
{
    self = [super init];
    if (self) {
        self.name = name;
        self.fileURL = url;
        self.fileName = fileName;
        self.mimeType = mimeType;
        _type = ZBFormDataTypeFileURL;
    }
    return self;
}

+ (instancetype)formData:(NSData *)data
                    name:(NSString *)name
                fileName:(NSString *)fileName
                mimeType:(NSString *)mimeType
{
    return [[self alloc] initWithData:data
                                 name:name
                             fileName:fileName
                             mimeType:mimeType];
}

+ (instancetype)formDataURL:(NSURL *)url
                       name:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
{
    return [[self alloc] initWithFileURL:url
                                    name:name
                                fileName:fileName
                                mimeType:mimeType];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{name:@%@, fileName:%@, mimeType:%@, data:%@}", self.name, self.fileName, self.mimeType, [self.data description]];
}

@end

ZBFormData * formPngDATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeImageOfPNG];
}
ZBFormData * formJpgDATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeImageOfJPG];
}
ZBFormData * formJpegDATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeImageOfJPEG];
}
ZBFormData * formGZipDATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeFileOfGZIP];
}
ZBFormData * formZipDATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeFileOfZIP];
}
ZBFormData * formPdfDATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeFileOfPDF];
}
ZBFormData * formMp4DATA(NSData *data, NSString *name, NSString *fileName){
    return [ZBFormData formData:data name:name fileName:fileName mimeType:ZBMimeTypeAudioOfMP4];
}

ZBFormData * formPngURL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeImageOfPNG];
}
ZBFormData * formJpgURL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeImageOfJPG];
}
ZBFormData * formJpegURL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeImageOfJPEG];
}
ZBFormData * formGZipURL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeFileOfGZIP];
}
ZBFormData * formZipURL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeFileOfZIP];
}
ZBFormData * formPdfURL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeFileOfPDF];
}
ZBFormData * formMp4URL(NSURL *fileURL, NSString *name, NSString *fileName){
    return [ZBFormData formDataURL:fileURL name:name fileName:fileName mimeType:ZBMimeTypeAudioOfMP4];
}
