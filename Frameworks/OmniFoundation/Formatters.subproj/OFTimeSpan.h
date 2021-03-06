// Copyright 2006-2017 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import <Foundation/NSObject.h>

@class OFTimeSpanFormatter;

@interface OFTimeSpan : NSObject <NSCopying>
{
    OFTimeSpanFormatter *createdByFormatter;
    struct {
        float years, months, weeks, days, hours, minutes, seconds;
    } _components;
    BOOL elapsed;
}

- initWithTimeSpanFormatter:(OFTimeSpanFormatter *)aFormatter;

- (void)setYears:(float)aValue;
- (void)setMonths:(float)aValue;
- (void)setWeeks:(float)aValue;
- (void)setDays:(float)aValue;
- (void)setHours:(float)aValue;
- (void)setMinutes:(float)aValue;
- (void)setSeconds:(float)aValue;
- (void)setElapsed:(BOOL)aBool;

- (float)years;
- (float)months;
- (float)weeks;
- (float)days;
- (float)hours;
- (float)minutes;
- (float)seconds;
- (BOOL)elapsed;

- (float)floatValue;
- (float)floatValueInSeconds;
- (NSDateComponents *)dateComponentsValue;

- (BOOL)isZero;

@end
