//
//  Utils.h
//  Safelet
//
//  Created by Alex Motoc on 05/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#ifndef Utils_h
#define Utils_h

#import <UIKit/UIKit.h>

@class Alarm;
@class AlarmPulleyContainerViewController;
NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

/**
 *  Dispatches a local notification only if needed. Also remembers how many notifications were sent, such that
 *  we limit them to only 2 notifications (one at 20% and one at 10%)
 *  A local notification is needed when the current battery level drops under 20%, or under 10%.
 *
 *  @param batteryLevel NSInteger representing the current battery level
 */
+ (void)dispatchLocalNotificationForLowBatteryLevel:(NSInteger)batteryLevel;
+ (AlarmPulleyContainerViewController *)createChatAlarmControllerWithAlarm:(Alarm *)alarm shouldShowJoinAlarmButton:(BOOL)showJoinAlarm ;

@end

#pragma mark - Color Utils

@interface UIColor (AppThemeColor)

/**
 *  Returns the color used as theme throughout the app
 *
 *  @return uicolor instance
 */
+ (UIColor *)appThemeColor;

/**
 *  Return the color used in the alarm banner
 *
 *  @return uicolor instance
 */
+ (UIColor *)alarmBannerColor;

+ (UIColor *)bigTableCellColor;

@end

#pragma mark - String Utils

@interface NSString (EmailValidation)

/**
 *	Checks if a string is in a valid email format.
 *  Doesn't check if the email address is registered or not. Just checks the format.
 *
 *	@return YES if string is a valid email format; NO otherwise
 */
- (BOOL)isValidEmailFormat;

@end

@interface NSString (GenericUtils)

/**
 *  Equivalent of [NSString stringWithFormat:], but allows you to add an array of arguments.
 *
 *  @throws Exception if more than 10 arguments are supplied
 *  @param format format of string
 *  @param args   arguments used in format
 *
 *  @return formatted string
 */
+ (NSString *)stringWithFormat:(NSString *)format arguments:(NSArray *)args;

@end

@interface NSString (PhoneNumberUtils)

/**
 *	Custom normalization of phone number. The phone number normalized by this method needs to have a country code
 *  If it doesn't have one (e.g. the phone is "123 456 789" insetead of "+40 123 456 678"), add the provided
 *  default country code to it. The phone number is normalized such that it doesn't have any characters other than digits, and
 *  the "+" sign used at the beginig fot the country code. The normalization standard is E164.
 *
 *	@param countryCode	the default country code to be added in case the phone number doesn't already have one
 *
 *	@return a normalized phone number, corresponding to the above description
 */
- (NSString *)normalizedPhoneNumberWithDefaultCountryCode:(NSString *)countryCode;

@end

#pragma mark - AlertView Utils

@interface UIAlertController (ShortSyntax)

/**
 *	Shows an alert with title "Error"#import <UIKit/UIKit.h> (localized) and dismiss button "OK" (localized)
 *
 *	@param message	NSString * representing the message that will be displayed by the alert
 */
+ (void)showErrorAlertWithMessage:(NSString *)message;

/**
 *	Shows an alert with title "Success" (localized) and dismiss button "OK" (localized)
 *
 *	@param message	NSString * representing the message that will be displayed by the alert
 */
+ (void)showSuccessAlertWithMessage:(NSString *)message;

/**
 *	Shows an alert view for the push notification, containing the following properties:
 *  title = "Alert" - localized
 *  message = provided as parameter
 *  OK button - localized
 *  View button - localized - used to take the user to the screen where the notification happened
 *
 *	@param handler	handler block - has a bool variable indicating if we should show the details screen
 */
+ (void)showPushNotificationAlertWithMessage:(NSString *)message
                                     handler:(void(^)(BOOL shouldShowDetails))handler;


+ (void)showPushNotificationAlertWithMessageForFollowMe:(NSString *)message isShowDismiss:(BOOL)isShowDismiss
handler:(void(^)(BOOL shouldShowDetails))handler;


/**
 *	Shows an alert with title "Alert" (localized) and dismiss button "OK" (localized)
 *
 *	@param message	NSString * representing the message that will be displayed by the alert
 */
+ (void)showAlertWithMessage:(NSString *)message;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

#pragma mark - UIImage Utils

@interface UIImage(ImageUtils)

+ (UIImage *)imageWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END

#endif /* Utils_h */
