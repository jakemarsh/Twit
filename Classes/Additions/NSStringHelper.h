#import <Foundation/Foundation.h>
//Short hand NSLocalizedString, doesn't need 2 parameters
#define LocalizedString(s) NSLocalizedString(s,s)
//LocalizedString with an additionl parameter for formatting
#define LocalizedStringWithFormat(s,...) [NSString stringWithFormat:NSLocalizedString(s,s),##__VA_ARGS__]

enum {
	NSTruncateStringPositionStart=0,
	NSTruncateStringPositionMiddle,
	NSTruncateStringPositionEnd
}; typedef int NSTruncateStringPosition;

@interface NSString (SSHelper)

//Checks to see if the string contains the given string, case insenstive
- (BOOL)containsString:(NSString*)string;

//Checks to see if the string contains the given string while allowing you to define the compare options
- (BOOL)containsString:(NSString*)string options:(NSStringCompareOptions)options;

//Returns the MD5 value of the string
- (NSString*)md5;

//Returns the long value of the string
- (long)longValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;

//Truncate string to length
- (NSString*)stringByTruncatingToLength:(int)length;
- (NSString*)stringByTruncatingToLength:(int)length direction:(NSTruncateStringPosition)truncateFrom;
- (NSString*)stringByTruncatingToLength:(int)length direction:(NSTruncateStringPosition)truncateFrom withEllipsisString:(NSString*)ellipsis;

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;

- (BOOL) isEmpty;
- (BOOL) isNotEmpty;

- (NSString *) stringByDecodingXMLEntities;
- (NSString *) stringByTrimmingWhiteSpace;

- (NSDictionary *) queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

- (BOOL) isWhitespace;
- (BOOL) isEmptyOrWhitespace;

- (NSString *) stringByUnescapingFromURLArgument;

@end