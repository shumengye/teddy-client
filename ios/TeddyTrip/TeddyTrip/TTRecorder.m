//
//  TTRecorder.m
//  TeddyTrip
//
//  Created by continuous integration on 01/12/13.
//
//

#import "TTRecorder.h"

@implementation TTRecorder
{
    BOOL _isRecording;
    NSMutableArray *_trace;
}

- (NSArray *)trace
{
    return _trace;
}

- (id)initWithLocationProvider:(TTLocationProvider *)locationProvider
{
    self = [super init];
    
    if (self) {
        _trace = [[NSMutableArray alloc] init];
        [locationProvider setDelegate:self];
    }
    return self;
}

- (BOOL)isRecording
{
    return _isRecording;
}

- (double)distanceMeters
{
    double distance = 0.0;
    if ([_trace count] > 1) {
        for (uint i = 1; i < [_trace count]; ++i) {
            distance += [[_trace objectAtIndex:i] distanceFromLocation:[_trace objectAtIndex:(i - 1)]];
        }
    }
    return distance;
}

- (void)start
{
    if (!_isRecording) {
        _isRecording = YES;
        [_trace removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidStartRecordingNotification object:self];
        [self postCurrentDistance];
    }
}

- (void)stop
{
    if (_isRecording) {
        _isRecording = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidStopRecordingNotification object:self];
    }
}

- (void)postCurrentDistance
{
    NSDictionary *distanceData = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:[self distanceMeters]] forKey:kUserInfoDistanceKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDistanceDidChangeNotification object:self userInfo:distanceData];
}

- (void)didReceiveLocation:(CLLocation*)location
{
    if (_isRecording) {
        [_trace addObject:location];
        [self postCurrentDistance];
    }
}

@end
