// Copyright (c) 2013 Joshua Caswell, distributed under an MIT License.
// See header for legal info.
// Code from https://github.com/Koolistov/NSString-HTML was used as a starting
// point. See header for legal info for that code.

#import "NSString+WSSHTMLEntityDecoding.h"


@interface NSMutableString (WSSHTMLEntityDecoding)

- (void)WSSReplaceOccurencesOfHTMLEntity:(NSString *)entity
                        withUnicodePoint:(unsigned short)val;

@end

@implementation NSMutableString (WSSHTMLEntityDecoding)

- (void)WSSReplaceOccurencesOfHTMLEntity:(NSString *)entity
                        withUnicodePoint:(unsigned short)val
{
    [self replaceOccurrencesOfString:entity
                          withString:[NSString stringWithFormat:@"%C", val]
                             options:NSLiteralSearch
                               range:(NSRange){0, [self length]}];
}

@end


@implementation NSString (WSSHTMLEntityConversion)

- (NSString *)WSSStringByDecodingHTMLCharacterEntities {
    
    if( [self rangeOfString:@"&"].location == NSNotFound ){
        return self;
    }
    
    
    NSMutableString * escaped = [NSMutableString stringWithString:self];
    
    NSArray * entitiesFrom160 = @[@"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;",
        @"&curren;", @"&yen;", @"&brvbar;",@"&sect;", @"&uml;", @"&copy;",
        @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;", @"&macr;",
        @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
        @"&para;", @"&middot;", @"&cedil;", @"&sup1;", @"&ordm;", @"&raquo;",
        @"&frac14;", @"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;",
        @"&Aacute;", @"&Acirc;", @"&Atilde;", @"&Auml;", @"&Aring;",
        @"&AElig;", @"&Ccedil;", @"&Egrave;", @"&Eacute;", @"&Ecirc;",
        @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;", @"&ETH;",
        @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;",
        @"&Ouml;", @"&times;", @"&Oslash;", @"&Ugrave;", @"&Uacute;",
        @"&Ucirc;", @"&Uuml;", @"&Yacute;", @"&THORN;", @"&szlig;",
        @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
        @"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;",
        @"&ecirc;", @"&euml;", @"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;",
        @"&eth;", @"&ntilde;", @"&ograve;", @"&oacute;", @"&ocirc;",
        @"&otilde;", @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
        @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;",
        @"&yuml;"];
    
    // The following are not in the 160+ range
    //!!!: Add any other required entities to this dictionary.
    NSDictionary * otherEntities = @{ @"&amp;" : @(38),
                                      @"&lt;" : @(60),
                                      @"&gt;" : @(62),
                                      @"&apos;" : @(39),
                                      @"&quot;" : @(34),
                                      @"&mdash;" : @(8212),
                                      @"&rsquo;" : @(8217),
                                      @"&trade;" : @(8482) };
        
    // Unicode code point of each entity
    unsigned short point = 160;
    for( NSString * entity in entitiesFrom160 ){
        [escaped WSSReplaceOccurencesOfHTMLEntity:entity
                                 withUnicodePoint:point++];
    }
    
    for( NSString * entity in otherEntities ){
        point = [otherEntities[entity] unsignedShortValue];
        [escaped WSSReplaceOccurencesOfHTMLEntity:entity
                                 withUnicodePoint:point];
    }
    
    NSMutableString * fixedUpString = [NSMutableString string];
    NSScanner * scanner = [NSScanner scannerWithString:escaped];
    
    while( ![scanner isAtEnd] ){
        
        // Pick up non-entity characters.
        NSString * collector;
        if( [scanner scanUpToString:@"&#" intoString:&collector] ){
            [fixedUpString appendString:collector];
        }
        
        // Step over the beginning of the entity.
        if( [scanner scanString:@"&#" intoString:nil] ){
        
            // Get entity's int value -- either hex or decimal.
            unsigned short codepoint;
            if( [scanner scanString:@"x" intoString:nil] ){
                [scanner scanHexInt:(unsigned *)&codepoint];
            }
            else {
                [scanner scanInt:(int *)&codepoint];
            }
            // Append that character.
            [fixedUpString appendFormat:@"%C", codepoint];
            
            // Step past closing semicolon and continue.
            [scanner scanString:@";" intoString:nil];
        }
    }
    
    return fixedUpString;
}

@end
