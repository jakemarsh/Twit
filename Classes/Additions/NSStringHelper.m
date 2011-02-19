#import "NSStringHelper.h"
#import <CommonCrypto/CommonDigest.h>

int const SSGGCharacterIsNotADigit = 10;

@implementation NSString (SSHelper)

- (BOOL) containsString:(NSString*)string {
	return [self containsString:string options:NSCaseInsensitiveSearch];
}
- (BOOL) containsString:(NSString*)string options:(NSStringCompareOptions)options {
	return [self rangeOfString:string options:options].location == NSNotFound ? NO : YES;
}

#pragma mark Long conversions

- (long) longValue {
	return (long)[self longLongValue];
}
- (long long) longLongValue {
	NSScanner* scanner = [NSScanner scannerWithString:self];
	long long valueToGet;
	if([scanner scanLongLong:&valueToGet] == YES) {
		return valueToGet;
	} else {
		return 0;
	}
}
- (unsigned) digitValue:(unichar)c {
	
	if ((c>47)&&(c<58)) {
        return (c-48);
	}
	
	return SSGGCharacterIsNotADigit;
}
- (unsigned long long) unsignedLongLongValue {
	unsigned n = [self length];
	unsigned long long v,a;
	unsigned small_a, j;
	
	v=0;
	for (j=0;j<n;j++) {
		unichar c=[self characterAtIndex:j];
		small_a=[self digitValue:c];
		if (small_a==SSGGCharacterIsNotADigit) continue;
		a=(unsigned long long)small_a;
		v=(10*v)+a;
	}
	
	return v;
	
}

- (NSString *) stringByDecodingXMLEntities {
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
	
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
	
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
		else if ([scanner scanString:@"&#174" intoString:NULL])
			[result appendString:@"®"];
		else if ([scanner scanString:@"&#169" intoString:NULL])
			[result appendString:@"©"];
		else if ([scanner scanString:@"&#8482" intoString:NULL])
			[result appendString:@"™"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
			
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            if (gotNumber) {
                [result appendFormat:@"%C", charCode];
            }
            else {
                NSString *unknownEntity = @"";
                [scanner scanUpToString:@";" intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                //Log(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
            }
            [scanner scanString:@";" intoString:NULL];
        }
        else {
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
            //Log(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
        }
    }
    while (![scanner isAtEnd]);
	
finish:
    return result;
}

#pragma mark Hashes

// TODO: Add other methods, specifically SHA1

- (NSString *) md5 {
	const char* string = [self UTF8String];
	unsigned char result[16];
	CC_MD5(string, strlen(string), result);
	NSString* hash = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
												result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], 
												result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];

	return [hash lowercaseString];
}

#pragma mark Truncation

- (NSString*) stringByTruncatingToLength:(int)length {
	return [self stringByTruncatingToLength:length direction:NSTruncateStringPositionEnd];
}
- (NSString*) stringByTruncatingToLength:(int)length direction:(NSTruncateStringPosition)truncateFrom {
	return [self stringByTruncatingToLength:length direction:truncateFrom withEllipsisString:@"..."];
}
- (NSString*) stringByTruncatingToLength:(int)length direction:(NSTruncateStringPosition)truncateFrom withEllipsisString:(NSString*)ellipsis {
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	NSString *immutableResult;
	
	if([result length] <= length) {
		[result release];
		return self;
	}
	
	unsigned int charactersEachSide = length / 2;
	
	NSString* first;
	NSString* last;
	
	switch(truncateFrom) {
		case NSTruncateStringPositionStart:
			[result insertString:ellipsis atIndex:[result length] - length + [ellipsis length] ];
			immutableResult  = [[result substringFromIndex:[result length] - length] copy];
			[result release];
			return [immutableResult autorelease];
		case NSTruncateStringPositionMiddle:
			first = [result substringToIndex:charactersEachSide - [ellipsis length]+1];
			last = [result substringFromIndex:[result length] - charactersEachSide];
			immutableResult = [[[NSArray arrayWithObjects:first, last, NULL] componentsJoinedByString:ellipsis] copy];
			[result release];
			return [immutableResult autorelease];
		default:
		case NSTruncateStringPositionEnd:
			[result insertString:ellipsis atIndex:length - [ellipsis length]];
			immutableResult  = [[result substringToIndex:length] copy];
			[result release];
			return [immutableResult autorelease];
	}
}

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue {
	// Explode based on outter glue
	NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
	NSArray *secondExplode;
	
	// Explode based on inner glue
	NSInteger count = [firstExplode count];
	NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
	for (NSInteger i = 0; i < count; i++) {
		secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
		if ([secondExplode count] == 2) {
			[returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
		}
	}
	
	return returnDictionary;
}

- (BOOL) isEmpty {
	return self == nil || ([self respondsToSelector:@selector(length)] && [[self stringByTrimmingWhiteSpace] length] == 0);
}
- (BOOL) isNotEmpty {
    
	BOOL answer = YES;
    
	NSString* stripped = [self stringByTrimmingWhiteSpace];
	
    if([stripped length]==0)
        answer = NO;
    return answer;
}

- (NSString *) stringByTrimmingWhiteSpace {
   	NSString *stripped = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return stripped;
}

- (NSDictionary *) queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
	NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
	NSScanner* scanner = [[[NSScanner alloc] initWithString:self] autorelease];
	
	while (![scanner isAtEnd]) {
		NSString* pairString;
		[scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
		[scanner scanCharactersFromSet:delimiterSet intoString:NULL];
		
		NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
		
		if (kvPair.count == 2) {
			NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
			NSString* value = [[[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];

			[pairs setObject:value forKey:key];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:pairs];
}


- (BOOL) isWhitespace {
	NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	for (NSInteger i = 0; i < self.length; ++i) {
		unichar c = [self characterAtIndex:i];
		if (![whitespace characterIsMember:c]) {
			return NO;
		}
	}
	
	return YES;
}
- (BOOL) isEmptyOrWhitespace {
	if (self == nil) return YES;
	if ([[self class] isEqual: [NSNull class]]) return YES;
	if([[NSString stringWithFormat:@"%@", self] isEqualToString:@"(null)"]) return YES;
	
	return !self.length || ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (NSString *) stringByUnescapingFromURLArgument {
	NSMutableString *resultString = [NSMutableString stringWithString:self];

	[resultString replaceOccurrencesOfString:@"+"
							withString:@" "
							   options:NSLiteralSearch
								range:NSMakeRange(0, [resultString length])];

	return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end