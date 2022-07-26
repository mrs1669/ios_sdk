//
//  ADJSdkPackageSenderPinningDelegate.m
//  Adjust
//
// adapted from:
//  https://github.com/datatheorem/TrustKit/blob/master/TrustKit/Pinning/TSKSPKIHashCache.m
//  https://www.bugsee.com/blog/ssl-certificate-pinning-in-mobile-applications/
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkPackageSenderPinningDelegate.h"

#import <CommonCrypto/CommonDigest.h>

#pragma mark Fields
#pragma mark - Private constants
static const unsigned char kRsa2048Asn1Header[] =
{
    0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
};

static const unsigned char kRsa4096Asn1Header[] =
{
    0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
};

static const unsigned char kEcDsaSecp256r1Asn1Header[] =
{
    0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
    0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
    0x42, 0x00
};

static const unsigned char kEcDsaSecp384r1Asn1Header[] =
{
    0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
    0x01, 0x06, 0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
};

@interface ADJSdkPackageSenderPinningDelegate ()
#pragma mark - Injected dependencies
@property (nullable, readwrite, strong, nonatomic)
    ADJSdkResponseDataBuilder *sdkResponseDataBuilderWeakRef;
@property (nonnull, readonly, strong, nonatomic)
    ADJNonEmptyString *publicKeyHash;
@end

@implementation ADJSdkPackageSenderPinningDelegate
#pragma mark Instantiation
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    publicKeyHash:(nonnull ADJNonEmptyString *)publicKeyHash
{
    self = [super initWithLoggerFactory:loggerFactory
                                 source:@"SdkPackageSenderPinningDelegate"];
    _publicKeyHash = publicKeyHash;

    return self;
}

#pragma mark Public API
- (void)setRequestDataWeakRefWithBuilder:
    (nonnull ADJSdkResponseDataBuilder *)sdkResponseDataBuilder
{
    self.sdkResponseDataBuilderWeakRef = sdkResponseDataBuilder;
}

- (void)clearRequestDataWeakRef {
    self.sdkResponseDataBuilderWeakRef = nil;
}

#pragma mark - NSURLSessionDelegate
- (void)
    URLSession:(nonnull NSURLSession *)session
    didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge
    completionHandler:
        (void (^_Nonnull)
            (NSURLSessionAuthChallengeDisposition disposition,
             NSURLCredential * _Nullable credential))completionHandler
{
    if (! [challenge.protectionSpace.authenticationMethod
                isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // TODO should perform default handling or cancel challange?
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        //completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
        return;
    }

    // Get remote certificate
    SecTrustRef _Nonnull serverTrust = challenge.protectionSpace.serverTrust;
    //CFRetain(serverTrust);

    BOOL useCredential = [self useCredentialWithServerTrust:serverTrust];

    //CFRelease(serverTrust);

    if (useCredential) {
        NSURLCredential *_Nonnull serverCredential =
            [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, serverCredential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark Internal Methods
- (BOOL)useCredentialWithServerTrust:(nonnull SecTrustRef)serverTrust {
    if (! [self canEvaluateWithTrust:serverTrust]) {
        return NO;
    }

    [self.logger debug:@"Server trust validated with %d certificates",
        (int)SecTrustGetCertificateCount(serverTrust)];

    SecCertificateRef _Nullable serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0);

    if (! serverCertificate) {
        [self logErrorWithMessage:@"Cannot retrieve first server certificate"
                          nsError:nil];
        return NO;
    }

    SecKeyRef _Nullable serverPublicKey = SecCertificateCopyPublicKey(serverCertificate);

    if (! serverPublicKey) {
        [self logErrorWithMessage:@"Cannot retrieve public key from first server certificate"
                          nsError:nil];
        return NO;
    }

    BOOL useCredential = [self useCredentialWithServerPublicKey:serverPublicKey];

    CFRelease(serverPublicKey);

    return useCredential;
}

- (BOOL)useCredentialWithServerPublicKey:(SecKeyRef _Nonnull)serverPublicKey {
    CFErrorRef errorRef;

    // TODO maybe use __bridge_transfer / CFBridgingRelease instead of CFRelease
    CFDataRef _Nullable serverPublicKeyData =
        SecKeyCopyExternalRepresentation(serverPublicKey, &errorRef);

    if (errorRef) {
        NSError *error = (__bridge NSError *)errorRef;

        [self logErrorWithMessage:@"Cannot retrieve public key data with NSError"
                          nsError:error];

        CFRelease(errorRef);
        return NO;
    }

    if (! serverPublicKeyData) {
        [self logErrorWithMessage:@"Cannot retrieve public key data without NSError"
                          nsError:nil];

        return NO;
    }

    BOOL useCredential =
        [self useCredentialWithServerPublicKeyData:(__bridge NSData *)serverPublicKeyData
                                   serverPublicKey:serverPublicKey];

    CFRelease(serverPublicKeyData);

    return useCredential;
}

- (BOOL)useCredentialWithServerPublicKeyData:(nonnull NSData *)serverPublicKeyNSData
                             serverPublicKey:(SecKeyRef _Nonnull)serverPublicKey
{
    // TODO maybe use __bridge_transfer / CFBridgingRelease instead of CFRelease
    // Obtain the SPKI header based on the key's algorithm
    CFDictionaryRef _Nullable publicKeyAttributes = SecKeyCopyAttributes(serverPublicKey);

    if (! publicKeyAttributes) {
        [self logErrorWithMessage:@"Cannot retrieve keychain attributes of the server public key"
                          nsError:nil];
        return NO;
    }

    BOOL useCredential = [self useCredentialWithPublicKeyAttributes:publicKeyAttributes
                                                serverPublicKeyData:serverPublicKeyNSData];

    CFRelease(publicKeyAttributes);

    return useCredential;
}

- (BOOL)useCredentialWithPublicKeyAttributes:(CFDictionaryRef _Nonnull)publicKeyAttributes
                         serverPublicKeyData:(nonnull NSData *)serverPublicKeyNSData
{
    CFTypeRef _Nullable publicKeyTypeRef =
        CFDictionaryGetValue(publicKeyAttributes, kSecAttrKeyType);

    if (publicKeyTypeRef == nil) {
        [self logErrorWithMessage:@"Cannot retrieve public key type from keychain attributes"
                          nsError:nil];
        return NO;
    }

    if (CFGetTypeID(publicKeyTypeRef) != CFStringGetTypeID()) {
        [self logErrorWithMessage:
            @"Retrieved public key type from keychain attributes is not of string type"
                          nsError:nil];
        return NO;
    }

    NSString *_Nonnull publicKeyType = (__bridge NSString *)((CFStringRef)publicKeyTypeRef);

    CFTypeRef _Nullable publicKeySizeRef =
        CFDictionaryGetValue(publicKeyAttributes, kSecAttrKeySizeInBits);

    if (publicKeySizeRef == nil) {
        [self logErrorWithMessage:@"Cannot retrieve public key size from keychain attributes"
                          nsError:nil];
        return NO;
    }

    if (CFGetTypeID(publicKeySizeRef) != CFNumberGetTypeID()) {
        [self logErrorWithMessage:
            @"Retrieved public key size from keychain attributes is not of number type"
                          nsError:nil];
        return NO;
    }

    NSNumber *_Nonnull publicKeySize = (__bridge NSNumber *)((CFNumberRef)publicKeySizeRef);

    char *_Nullable asn1HeaderBytes = NULL;
    unsigned int asn1HeaderSize = 0;

    if ([publicKeyType isEqualToString:(NSString *)kSecAttrKeyTypeRSA]
        && publicKeySize.integerValue == 2048)
    {
        asn1HeaderBytes = (char *)kRsa2048Asn1Header;
        asn1HeaderSize = sizeof(kRsa2048Asn1Header);
    }
    else if ([publicKeyType isEqualToString:(NSString *)kSecAttrKeyTypeRSA]
        && publicKeySize.integerValue == 4096)
    {
        asn1HeaderBytes = (char *)kRsa4096Asn1Header;
        asn1HeaderSize = sizeof(kRsa4096Asn1Header);
    }
    else if ([publicKeyType isEqualToString:(NSString *)kSecAttrKeyTypeECSECPrimeRandom]
        && publicKeySize.integerValue == 256)
    {
        asn1HeaderBytes = (char *)kEcDsaSecp256r1Asn1Header;
        asn1HeaderSize = sizeof(kEcDsaSecp256r1Asn1Header);
    }
    else if ([publicKeyType isEqualToString:(NSString *)kSecAttrKeyTypeECSECPrimeRandom]
             && publicKeySize.integerValue == 384)
    {
        asn1HeaderBytes = (char *)kEcDsaSecp384r1Asn1Header;
        asn1HeaderSize = sizeof(kEcDsaSecp384r1Asn1Header);
    }

    if (asn1HeaderSize == 0 || ! asn1HeaderBytes) {
        [self logErrorWithMessage:
            @"Public key algorithm or length is not supported"
                          nsError:nil];
        return NO;
    }

    NSString *_Nonnull serverPublicKeyHash =
        [self sha256WithServerPublicKeyData:serverPublicKeyNSData
                            asn1HeaderBytes:asn1HeaderBytes
                             asn1HeaderSize:asn1HeaderSize];

    if (! [serverPublicKeyHash isEqualToString:self.publicKeyHash.stringValue]) {
        [self logErrorWithMessage:@"Server certificate public key hash does not match expected"
                          nsError:nil];
        return NO;
    }

    return YES;
}

- (nonnull NSString *)sha256WithServerPublicKeyData:(nonnull NSData *)serverPublicKeyNSData
                                     asn1HeaderBytes:(char *_Nonnull)asn1HeaderBytes
                                      asn1HeaderSize:(unsigned int)asn1HeaderSize
{
    // Generate a hash of the subject public key info
    NSMutableData *_Nonnull subjectPublicKeyInfoHash =
        [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_CTX shaCtx;
    CC_SHA256_Init(&shaCtx);

    // Add the missing ASN1 header for public keys to re-create the subject public key info
    CC_SHA256_Update(&shaCtx, asn1HeaderBytes, asn1HeaderSize);

    // Add the public key
    CC_SHA256_Update(&shaCtx,
                     [serverPublicKeyNSData bytes],
                     (unsigned int)[serverPublicKeyNSData length]);
    CC_SHA256_Final((unsigned char *)[subjectPublicKeyInfoHash bytes], &shaCtx);

    return [subjectPublicKeyInfoHash base64EncodedStringWithOptions:
            NSDataBase64Encoding64CharacterLineLength];
}

- (BOOL)canEvaluateWithTrust:(nonnull SecTrustRef)trust {
    SecTrustResultType result = kSecTrustResultInvalid;

    if (@available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, macCatalyst 13.0, *)) {
        CFErrorRef errorRef;
        if (SecTrustEvaluateWithError(trust, &errorRef)) {
            if (errorRef) {
                NSError *error = (__bridge NSError *)errorRef;
                [self logErrorWithMessage:
                    @"Evaluated trust from SecTrustEvaluateWithError but had NSError"
                                  nsError:error];
                CFRelease(errorRef);
                return NO;
            }
        } else {
            if (errorRef) {
                NSError *error = (__bridge NSError *)errorRef;
                [self logErrorWithMessage:
                    @"Cannot evaluate trust from SecTrustEvaluateWithError with NSError"
                                  nsError:error];
                CFRelease(errorRef);
            } else {
                [self logErrorWithMessage:
                    @"Cannot evaluate trust from SecTrustEvaluateWithError without NSError"
                                  nsError:nil];
            }
            return NO;
        }
    } else {
        OSStatus evaluateReturn = SecTrustEvaluate(trust, &result);
        if (evaluateReturn != errSecSuccess) {
            [self logErrorWithMessage:
                [NSString stringWithFormat:
                    @"Cannot evaluate trust from SecTrustEvaluate with OSStatus: %d",
                    (int)evaluateReturn]
                              nsError:nil];
            return NO;
        }
    }

    if (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed) {
        return YES;
    }

    [self logErrorWithMessage:[NSString stringWithFormat:
                               @"Cannot validate trust with result: %d", (int)result]
                      nsError:nil];
    return NO;
}

- (void)logErrorWithMessage:(nonnull NSString *)errorMessage
                    nsError:(nullable NSError *)nsError
{
    ADJSdkResponseDataBuilder *sdkResponseDataBuilder = self.sdkResponseDataBuilderWeakRef;

    if (sdkResponseDataBuilder != nil) {
        [sdkResponseDataBuilder logErrorWithLogger:self.logger
                                           nsError:nsError
                                      errorMessage:errorMessage];
    } else {
        if (nsError != nil) {
            [self.logger errorWithNSError:nsError message:@"%@", errorMessage];
        } else {
            [self.logger error:@"%@", errorMessage];
        }
    }
}

@end
