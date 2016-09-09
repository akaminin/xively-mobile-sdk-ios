# Xively SDK for iOS
This is the Xively iOS SDK. It is designed to help facilitate building an iOS application using Xively. It will help facilitate communication with Xively HTTP APIs as well as setup connections to the Xively MQTT broker. 

## Table of Contents
1. Introduction
	- About Xively
	- Download
	- Contents
	- Supported Xively Services
2. Getting Started
	- Prerequisites
	- Install Xively SDK
	- Configure Xively 'Hello World'
	- Run 'Hello World'
3. API Reference
4. Tutorials
	- Using the iOS SDK
	- Login
	- Send a Message
	- Receive Messages
	- List Devices
	- Graph TimeSeries Data
5. Reference Application
	- 
6. Troubleshooting
	- Known Issues
	- Common Problems
	- Getting Help

## Introduction
### About Xively
** TODO **
This documentation will refer to Xively objects such as devices, end users, channels, and more. We will do our best to explain but if you are unsure what these are, you should see the full Xively [API Documentation](http://docs.xively.com/).

For further details see http:\\docs.xively.com
### Download
The internal release of the library can be downloaded from the following location:
https://github.com/xively/xively-mobile-sdk-ios

### Contents
Package structure:

* [src] - the source code of the library
* [javadoc] - API documentation
* CHANGELOG - release history
* COPYING - Copying and redistributing legal info
* LICENSE - License Agreement
* README.md - project readme document

### Supported Xively Services
The SDK currently supports using the following services:

 * Username/Password based authentication to Xively Identity Management(IdM) API
 * Querying the list of devices from Blueprint
 * Querying Time Series records of channels
 * Querying Organization data
 * Querying EndUser data
 * Messaging through the publish-subscribe style (MQTT) interface
 
## Getting Started
This section will help you get the Xively iOS SDK setup in your environment. It will take you through the basic installation as well as a simple example.
 
### Prerequisites
#### Development Environment
The Xively SDK is presented as common-iOS.a library. It can be statically linked to any iOS application.
This guide assumes that the developer using the Xively SDK is familiar with Xcode and iOS development basics.
The expected minimum iOS version is 7.0.

This guide assumes that you have a Xively account already setup, if you don't, click here. It also assumes that you have 'account user' credentials as they will be needed to facilitate the basic connection.

### Install Xively SDK
#### Dependencies and Third Party Content
There are no external dependencies, however the library is based on and uses the following open source software:

* gmock 1.7.0 - https://github.com/google/googlemock
* RapidJSON 1.0.0 - https://github.com/miloyip/rapidjson
* libOCMock 3.0.2  - http://ocmock.org/ios/
* libpaho-sdk - (supplied as a prebuilt binary)

#### 1. Download the SDK
The binaries and the cource code is available on github: https://github.com/xively/xively-mobile-sdk-ios

#### 2. Import the Library
You can find the prebuilt binary file under: build/libxivelycommon-iOS.a. You can also build your own version with Xcode. To use this library you will also need to link with build/libxem-sdk-libpaho-ios.a. It is a precompiled version of an mqtt clinet supplies with this software pack. 
The header are located under build/include.
You can also use the XivelySDK.framework wich is created when you run Build All target, or run the scripts/build_and_test.sh
Copy the xively sdk library libxivelycommon-iOS.a and the supplied libxem-sdk-libpaho-ios.a and the header files folder to your project. Add the header files directory to your project settings, also setup your project to link to 2 archives: libxivelycommon-iOS.a and libxem-sdk-libpaho-ios.a.

### Configure Xively 'Hello World'
The SDK package contains the XivelyHelloWorldObjC project. This projects is embedding the Xively Hello World application. To run this project you need to copy XivelySDKiOS/build/XivelySDK.framework into XivelyHelloWorldObjC/ direcotry. 
This application authenticates a predefined user, opens a Messaging connection, subscribes to a predefined channel, publishes to that channel and displays the received messages.

#### 1. Setup the Configuration
To keep the Hello World application simple the Xively Credentials are defined in the XivelyHelloWorld.m source file.
Please fill in your user and account information before you try to run the application.

*com.logmein.xively.xivelyhelloworld.XivelyUserData.java*

```objectivec
        //////////////XIVELY CONFIGURATION/////////////
        self.accountId = @"G-U-I-D";
        self.username = @"awesome@foo.com";
        self.password = @"hunter2";
        self.messagingChannel = @"awsomeMessagingChannel";
         ///////////////////////////////////////////////
```

### Run it
You're finally ready to build the application. Make sure you have an emulator setup or a physical device connected to your computer and hit the 'Run' button

When pushing the Send Hello World button you should see a message being published to your Xively channel.
You will see this message appear in your Xcode's log view.

Congratulations, you have completed the Xively iOS SDK getting started guide.

## API Reference
The API Reference is included in the [doxygen] folder of the downloaded package. This is an autogenerated document in html format. Look for the *index.html* to open the document's Overview page.

## Tutorials
This section provides brief code snippets that would help someone add the desired Xively functionality - such as message publish and subscribe, authentication etc. - to their existing application.

### Using the iOS SDK
Before starting to use any Xively SDK APIs, the embedding application is expected to perform authentication.
The authentication service is the single entry point of the Xively SDK.
The Authentication service can be instantiated.
It is mandatory to pass the embedding application's XISDKConfig object to the authentication service factory methods:

```objectivec
 XIAuthentication* authentication = [[XIAuthentication alloc] initWithSdkConfig:[XISdkConfig config]];
```

The SDKConfig is required to initialize the SDK and request Authentication.

Optionally you can also specify a custom configuration if you would like to customize connection related properties or the internal log level of the Xively SDK. For details see the corresponding javadoc.
By creating a new instance of the *XiSdkConfig*, the object's properties will reflect the current values of the SDK configuration.

### Login
Everything in the Xively iOS SDK happens in the context of a user. The first thing that must happen is logging into the Xively service in order to do that all we need to do is initialize the library, set the authentication delegate and call the [requestLoginWithUsername:(NSString \*) password:(NSString \*) accountId:(NSStirng \*)] function.

Before you can access the Xively SDK services a user must be authenticated.
Authentication is handled by the *XIAuthentication* service which can be instantiated as shown above.

End users and Account users can authenticate using their Xively credentials and the implementing application has to provide their organization's Xively Account Id.
Authentication results are returned asynchronously using the [authentication:(XIAuthentication \*) didCreateSession:(id<XISession>)] delegate function.

```objectivec
    authentication.delegate = self;
    
    //Start authentication. It is an asynchronous request.
    //The result is called back on the methods defined in XIAuthenticationDelegate
    [authentication requestLoginWithUsername:@"< username >"
                                    password:@"< password >"
                                   accountId:@"< account ID >"];
```

Once you are logged in your user context and JWT is stored and handled by the Xively SDK.

### Send Message
The Xively messaging service makes it easy to communicate back and forth with your devices.
If you want to send messages to your device the first thing you have to do is connect, then you can publish and receive messages.

#### 1. Creating a messaging service
Messaging can be accessed once you have a valid XiSession. First you have to create an *XIMessagingCreator* object and set it's delegate. Once you have done that you could invoke the *createMessaging* function on it. And on success it will call the *messagingCreator:(id<XIMessagingCreator>) didCreateMessaging:(id<XIMessaging>)* function with an initialized XIMessaging object.
If the Messaging is created with clean session on, all subscriptions are canceled if the connection is closed or lost. If the clean session is off, all subscriptions remain alive on connection close or lost. This property is turned on by default. 
Last wills are user defined messages on user defined channels that are sent in case the the user's connection is closed or lost. There is no last will defined by default.
To create a Messaging instance, the Creator can be used as follows:

```objectivec
- (void)authentication:(XIAuthentication *)authentication didCreateSession:(id<XISession>)session {
    self.session = session;
    
    //The Messaging Creator builds up a Messaging connection. It is also asynchronous, therefore
    //its result is called back on the methods defined in XIMessagingCreatorDelegate
    self.messagingCreator = [session.services messagingCreator];
    self.messagingCreator.delegate = self;
    [self.messagingCreator createMessaging];
}

#pragma XIMessagingCreatorDelegate
- (void)messagingCreator:(id<XIMessagingCreator>)creator
      didCreateMessaging:(id<XIMessaging>)messaging {
    //The Messaging successfully connected to the broker.
    //The received Messaging instance is up and running.
    self.messagingCreator = nil;
    NSLog(@"Messaging connected");
    
    //Preserve the messaging instance for later use
    self.messaging = messaging;    
}
```

#### 2. Messaging service state changes
You can add an id<XIMessagingStateListener> object to your messaging service to subscribe for messaging service state changes.

```objectivec
- (void)messagingCreator:(id<XIMessagingCreator>)creator
      didCreateMessaging:(id<XIMessaging>)messaging {
      // ...
      [messaging addStateListener:self];
}

- (void)messaging:(id<XIMessaging>)messaging didChangeStateTo:(XIMessagingState)state{
    NSLog(@"Messaging service state change");
}
```

#### 3. Publish a Message
The following subscribe and publish operations are always available when the service is in the *XIMessagingStateConnected* state:

```objectivec
[self.messaging publishToChannel:self.messagingChannel
                         message:[testMessage dataUsingEncoding:NSUTF8StringEncoding]
                             qos:XIMessagingQoSAtMostOnce];
```

### Receive Messages
Xively uses a publish / subscribe model. This means you can setup a subscription on a specific channel and be notified anytime a new message arrives.
Once a Messaging object instance is created you can register listeners for its events. First you have to register for a subscription listener. It will tell you whether your subscribe requests were successful or unsuccesful asynchronously. Before you send a subscribe request you may register a DataListener object to handle incoming messages form the server.

```objectivec
- (void)messagingCreator:(id<XIMessagingCreator>)creator
        didCreateMessaging:(id<XIMessaging>)messaging {
    // ...   
    //Enable this object to receive if the following subscription succeeds or not
    [messaging addSubscriptionListener:self];

    //Enable this object to receive messages form the subscribed channels
    [self.messaging addDataListener:self];
    
    //Subscribe to a predefined topic. It is also an asynchronous call.
    //Its result needs to be checked on the methods defined in XIMessagingSubscriptionListener
    [self.messaging subscribeToChannel:self.messagingChannel qos:XIMessagingQoSAtMostOnce];
}

- (void)messaging:(id<XIMessaging>)messaging
        didSubscribeToChannel:(NSString *)channel qos:(XIMessagingQoS)qos {
    //Subscription was successfull
    
    //Enable this object to be notified on message arrivals on the subscribed channels.
    //The messages arrive on the methods defined in XIMessagingDataListener
    [self.messaging addDataListener:self];
    
    //Publish once
    [self.messaging publishToChannel:self.messagingChannel
                             message:[testMessage dataUsingEncoding:NSUTF8StringEncoding]
                                 qos:XIMessagingQoSAtMostOnce];
}

- (void)messaging:(id<XIMessaging>)messaging
        didReceiveData:(NSData *)message onChannel:(NSString *)channel {
    //A message was received on a subscribed channel
    if ([channel isEqualToString:self.messagingChannel]) {
        NSString *receivedMessage = [[NSString alloc] initWithData:message
                                                          encoding:NSUTF8StringEncoding];
        NSLog(@"Message received: '%@'", receivedMessage);
    }
}
```

If you don't need the Messaging service any more you should remove all your listeners and invoke *close*.

### List Devices
The SDK provides a service to retrieve a list of devices accesible with your credentials and their details (device id, device name, channels etc.).
The service can be accessed through the *deviceInfoList* API of the XiSession object.

```objectivec
-(void) queryDeviceInfoList {
    // see login
    id<XIDeviceInfoList> deviceInfo = [[session services] deviceInfoList];
    [deviceInfo setDelegate: self];
    [deviceInfo requestList];
}

-(void) deviceInfoList:(id<XIDeviceInfoList>)deviceInfoList
    didReceiveList:(NSArray *)deviceInfos {
    // device info list received
}

-(void) deviceInfoList:(id<XIDeviceInfoList>)deviceInfoList
    didFailWithError:(NSError *)error {
    // device info list request failed with error
}
```

### Graph TimeSeries Data
Xively provides TimeSeries data storage to persist the data of specific device channels (e.g. sensor data). 
Here is an example for how to query it then graph it using the MPAndroidChart library.

#### 1. Query Xively TimeSeries

```objectivec
-(void) queryTimeSeries {
    // request time series items
    id<XITimeSeries> timeSeries = [[session services] timeSeries];
    [timeSeries setDelegate: self];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [timeSeries requestTimeSeriesItemsForChannel: @"channel"
        startDate: [dateFormatter dateFromString: @"2015-03-19 23:59:59"]
        endDate: [dateFormatter dateFromString: @"2015-06-27 23:59:59"]
        groupBy: XITimeSeriesGroupNoGrouping];
}

-(void) timeSeries:(id<XITimeSeries>)timeSeries
    didReceiveItems:(NSArray *)timeSeriesItems {
    // time series received items
    self.timeSeriesData = timeSeriesItems;
}

-(void) timeSeries:(id<XITimeSeries>)timeSeries
    didFailWithError:(NSError *)error {
    // time series failed to receive items with error
}
```

Now we can graph it.

#### 2. Graph it
We will use JBChartView iOS library to graph it, you can download it here: https://github.com/Jawbone/JBChartView


##Troubleshooting
** TODO **

### Known Issues
None.
** TODO **
### Common Problems
### Getting Help
** TODO **

If you are still having trouble you can reach out to Xively by contacting your Sales Engineer.
