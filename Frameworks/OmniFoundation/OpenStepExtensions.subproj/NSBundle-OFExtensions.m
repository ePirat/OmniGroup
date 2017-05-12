// Copyright 2005-2016 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import <OmniFoundation/NSBundle-OFExtensions.h>
#import <OmniFoundation/OFErrors.h>

#if !defined(TARGET_OS_IPHONE) || !TARGET_OS_IPHONE
#import <OmniFoundation/NSFileManager-OFExtensions.h>
#import <Security/Security.h>
#else
#import <OmniFoundation/OFASN1Utilities.h>
#endif

RCS_ID("$Id$");


@implementation NSBundle (OFExtensions)

#if !defined(TARGET_OS_IPHONE) || !TARGET_OS_IPHONE

- (NSDictionary *)codeSigningInfoDictionary:(NSError **)error;
{
    NSURL *bundleURL = [NSURL fileURLWithPath:[self bundlePath]];
    return [[NSFileManager defaultManager] codeSigningInfoDictionaryForURL:bundleURL error:error];
}

- (NSDictionary *)codeSigningEntitlements:(NSError **)error;
{
    NSURL *bundleURL = [NSURL fileURLWithPath:[self bundlePath]];
    return [[NSFileManager defaultManager] codeSigningEntitlementsForURL:bundleURL error:error];
}

#else

- (NSDictionary *)codeSigningEntitlements:(NSError **)error;
{
    NSString *errorDescription = NSLocalizedStringFromTableInBundle(@"Could not parse entitlements from embedded provisioning profile", @"OmniFoundation", OMNI_BUNDLE, @"Provisioning profile parsing error general description");
    
    NSString *embeddedProvisionPath = [self pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (embeddedProvisionPath == nil) {
        NSString *reason = NSLocalizedStringFromTableInBundle(@"Embedded provisioning profile not found", @"OmniFoundation", OMNI_BUNDLE, @"Provisioning profile parsing error reason – no embedded.mobileprovision file");
        OFError(error, OFEmbeddedProvisioningProfileMissingError, errorDescription, reason);
        return nil;
    }
    
    NSData *embeddedProvisionData = [NSData dataWithContentsOfFile:embeddedProvisionPath];
    if (embeddedProvisionData == nil) {
        NSString *reason = NSLocalizedStringFromTableInBundle(@"Embedded provisioning profile not readable", @"OmniFoundation", OMNI_BUNDLE, @"Provisioning profile parsing error reason – embedded.mobileprovision unreadable");
        OFError(error, OFEmbeddedProvisioningProfileUnreadableError, errorDescription, reason);
        return nil;
    }
    
    NSData *contents = OFPKCS7PluckContents(embeddedProvisionData);
    if (contents == nil) {
        NSString *reason = NSLocalizedStringFromTableInBundle(@"Embedded provisioning profile is not a valid PKCS#7 archive", @"OmniFoundation", OMNI_BUNDLE, @"Provisioning profile parsing error reason – invalid PKCS#7 file");
        OFError(error, OFEmbeddedProvisioningProfileMalformedPKCS7Error, errorDescription, reason);
        return nil;
    }
    
    NSError *parseError = nil;
    NSDictionary *provisioning = [NSPropertyListSerialization propertyListWithData:contents options:0 format:NULL error:&parseError];
    if (provisioning == nil) {
        NSString *reason = NSLocalizedStringFromTableInBundle(@"PKCS#7 contents of embedded provisioning profile were not a valid plist", @"OmniFoundation", OMNI_BUNDLE, @"Provisioning profile parsing error reason – invalid plist");
        OFErrorWithInfo(error, OFEmbeddedProvisioningProfileMalformedPlistError, errorDescription, reason, NSUnderlyingErrorKey, parseError, nil);
        return nil;
    }
    
    return provisioning[@"Entitlements"];
}

#endif

@end
