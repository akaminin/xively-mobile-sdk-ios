//
//  MessageViewController.m
//  XivelySDKDemo
//
//  Created by Tamas Korodi on 2016. 10. 07..
//  Copyright © 2016. Xively. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController () {
    id<XIMessaging> messagingObj;
}
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View did load");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (dispatch_queue_t)getMessagingQueue {
    static dispatch_queue_t queue = nil;
    if (queue == nil) {
        queue = dispatch_queue_create("messaging.queue", NULL);
    }
    return queue;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadTimeSeriesData {
    self.timeSeries = [[XivelyService sharedXivelyService] timeSeries];
    [self.timeSeries setDelegate:self];
    [self addMessage:[NSString stringWithFormat:@"Requesting time series for channel: %@", self.channel.channelId]];
    [self.timeSeries requestTimeSeriesItemsForChannel:self.channel.channelId startDate:[NSDate dateWithTimeIntervalSinceNow: -604800.0] endDate:[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self addMessage:@"Connecting to messaging service..."];
    if (self.channel.persistenceType == XIDeviceChannelPersistanceTypeTimeSeries) {
        [self loadTimeSeriesData];
    }
    [self.sendButton setEnabled:false];
    dispatch_async([[self class] getMessagingQueue], ^{
        // Synchronizing messaging creation with deletions
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[XivelyService sharedXivelyService] setDelegate:self];
            [[XivelyService sharedXivelyService] createMessaging];
        });
    });
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"View Will Disappear");
    id<XIMessaging> messaging = self.messaging;
    dispatch_async([[self class] getMessagingQueue], ^{
        // Synchronizing messaging creation with deletions
        if (messaging) {
            [messaging unsubscribeFromChannel:self.channel.channelId];
            [messaging removeStateListener:self];
            [messaging removeDataListener:self];
            [messaging removeSubscriptionListener:self];
            [messaging close];
        }
    });
    [[XivelyService sharedXivelyService] setDelegate:nil];
    self.messaging = nil;
    [super viewWillDisappear:animated];
}

- (IBAction)sendPushed:(id)sender {
    NSData* data = [self.messageInputTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.messaging publishToChannel:self.channel.channelId
                             message:data
                                 qos:(([self.qosSegmentedControl selectedSegmentIndex] == 0) ? XIMessagingQoSAtMostOnce : XIMessagingQoSAtLeastOnce)
                              retain:self.retainSwitch.on];
    self.messageInputTextField.text = @"";
}

- (void)addMessage:(NSString*)message {
    NSLog(@"Message arrived: %@", message);
    self.incomingMessagesTextView.text = [NSString stringWithFormat:@"%@\n%@", message, self.incomingMessagesTextView.text];
}

#pragma mark messaging state listener
/**
 * @brief The current state of the messaging changed.
 * @param messaging The messaging originating the call.
 * @param state The new state of the messaging.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didChangeStateTo:(XIMessagingState)state
{
    switch(state) {
        case XIMessagingStateConnected:     [self addMessage:@"Messaging connected"]; break;
        case XIMessagingStateReconnecting:  [self addMessage:@"Messaging reconnecting"]; break;
        case XIMessagingStateDisconnecting: [self addMessage:@"Messaging disconnecting"]; break;
        case XIMessagingStateClosed:        [self addMessage:@"Messaging closed"]; break;
        case XIMessagingStateError:         [self addMessage:@"Messaging error"]; break;
    }
}

/**
 * @brief The messaging connection is being ended by an error.
 * @param messaging The messaging originating the call.
 * @param error The arror that causes the connection end. The possible error codes are defined in \link XICommonError.h \endlink and \link XIMessagingError.h \endlink.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging willEndWithError:(NSError *)error
{
    [self addMessage:[NSString stringWithFormat:@"Messaging error occured: %@", [error localizedDescription]]];
}

#pragma mark messaging data listener
/**
 * @brief A message arrived on a given channel.
 * @param messaging The messaging originating the call.
 * @param message The message data that was received.
 * @param channel The channel, the message came from.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didReceiveData:(NSData *)message onChannel:(NSString *)channel
{
    if ([channel isEqualToString:self.channel.channelId]) {
        NSString* messageString = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
        [self addMessage:[NSString stringWithFormat:@"%@: %@", [dateFormatter stringFromDate:[NSDate date]], messageString]];
    }
}

/**
 * @brief A message was successfully sent by the SDK user.
 * @details It only works for \link XIMessagingQoSAtLeastOnce \endlink and \link XIMessagingQoSExactlyOnce \endlink QoS levels.
 * @param messaging The messaging originating the call.
 * @param messageId The ID of the message that was successfully delivered.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didSendDataWithId:(NSInteger)messageId
{
    NSLog(@"A message was sent");
}

#pragma mark messaging subscription listener
/**
 * @brief The messaging successfully subscribed to a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it subscribed to.
 * @param qos The QoS level the server accepted to deliver messages.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didSubscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos
{
    [self addMessage:[NSString stringWithFormat:@"Subscribed to channel: %@", channel]];
}

/**
 * @brief The messaging failed to subscribe to a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it tried to subscribe to.
 * @param error The reason of the error.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didFailToSubscribeToChannel:(NSString *)channel error:(NSError *)error
{
    [self addMessage:[NSString stringWithFormat:@"Subscription failed to channel: %@", channel]];
}

/**
 * @brief The messaging successfully unsubscribed from a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it unsubscribed from.
 
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didUnsubscribeFromChannel:(NSString *)channel
{
    [self addMessage:[NSString stringWithFormat:@"Unsubscribed from channel: %@", channel]];
}

/**
 * @brief The messaging successfully unsubscribed from a channel.
 * @param messaging The messaging originating the call.
 * @param channel The channel it tried to unsubscribe from.
 * @param error The reason of the error.
 * @since Version 1.0
 */
- (void)messaging:(id<XIMessaging>)messaging didFailToUnsubscribeFromChannel:(NSString *)channel error:(NSError *)error
{
    [self addMessage:[NSString stringWithFormat:@"Failed to unsubscribed from channel: %@", channel]];
}

#pragma mark Time Series delegate
/**
 * @brief The time series request finished with success.
 * @param timeSeries The timeSeries instance that initiates the callback.
 * @param timeSeriesItems The result time series items. They are all instances of \link XITimeSeriesItem\endlink.
 * @since Version 1.0
 */
- (void)timeSeries:(id<XITimeSeries>)timeSeries didReceiveItems:(NSArray *)timeSeriesItems
{
    [self addMessage:[NSString stringWithFormat:@"Received %ld timeseries item...", [timeSeriesItems count]]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    for (XITimeSeriesItem* item in timeSeriesItems) {
        NSString* valuesString = [NSString stringWithFormat:@"%@: %@ / %@ / %@",
                                  [dateFormatter stringFromDate:item.time],
                                  (item.category) ? item.category : @"",
                                  (item.stringValue) ? item.stringValue : @"",
                                  (item.numericValue) ? [item.numericValue stringValue] : @""];
        [self addMessage:valuesString];
    }
}

/**
 * @brief The time series request finished with an error.
 * @param timeSeries The timeSeries instance that initiates the callback.
 * @param error The reason of the error. The possible error codes are defined in \link XICommonError.h \endlink and \link XITimeSeriesError.h \endlink.
 * @since Version 1.0
 */
- (void)timeSeries:(id<XITimeSeries>)timeSeries didFailWithError:(NSError *)error
{
    [self addMessage:[NSString stringWithFormat:@"TimeSeries error occured: %@", [error localizedDescription]]];
}


#pragma mark Messaging
- (void)xivelyService:(XivelyService*)xivelyService createdMessaging:(id<XIMessaging>)messaging
{
    [self addMessage:@"Messaging connected."];
    self.messaging = messaging;
    [messaging addStateListener:self];
    [messaging addDataListener:self];
    [messaging addSubscriptionListener:self];
    [messaging subscribeToChannel:self.channel.channelId qos:XIMessagingQoSAtMostOnce];
    [self.sendButton setEnabled:true];
}

- (void)xivelyService:(XivelyService*)xivelyService failedToCreateMessaging:(NSError*)error
{
    [self addMessage:[NSString stringWithFormat:@"Messaging error occured: %@", [error localizedDescription]]];
    self.messaging = nil;
    [self.sendButton setEnabled:false];
}

@end
