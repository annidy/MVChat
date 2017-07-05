//
//  NSObject+Serialization.m
//  MVChat
//
//  Created by Mark Vasiv on 01/07/2017.
//  Copyright © 2017 Mark Vasiv. All rights reserved.
//

#import "NSObject+Serialization.h"
#import <objc/runtime.h>
#import <objc/message.h>

typedef char (*charGetter)(void *, SEL);
typedef int (*intGetter)(void *, SEL);
typedef short (*shortGetter)(void *, SEL);
typedef long (*longGetter)(void *, SEL);
typedef long long (*longLongGetter)(void *, SEL);
typedef unsigned char (*unsignedCharGetter)(void *, SEL);
typedef unsigned int (*unsignedIntGetter)(void *, SEL);
typedef unsigned short (*unsignedShortGetter)(void *, SEL);
typedef unsigned long (*unsignedLongGetter)(void *, SEL);
typedef unsigned long long (*unsignedLongLongGetter)(void *, SEL);
typedef float (*floatGetter)(void *, SEL);
typedef double (*doubleGetter)(void *, SEL);
typedef bool (*boolGetter)(void *, SEL);
typedef id (*objectGetter)(void *, SEL);

typedef void (*charSetter)(void *, SEL, char);
typedef void (*intSetter)(void *, SEL, int);
typedef void (*shortSetter)(void *, SEL, short);
typedef void (*longSetter)(void *, SEL, long);
typedef void (*longLongSetter)(void *, SEL, long long);
typedef void (*unsignedCharSetter)(void *, SEL, unsigned char);
typedef void (*unsignedIntSetter)(void *, SEL, unsigned int);
typedef void (*unsignedShortSetter)(void *, SEL, unsigned short);
typedef void (*unsignedLongSetter)(void *, SEL, unsigned long);
typedef void (*unsignedLongLongSetter)(void *, SEL, unsigned long long);
typedef void (*floatSetter)(void *, SEL, float);
typedef void (*doubleSetter)(void *, SEL, double);
typedef void (*boolSetter)(void *, SEL, bool);
typedef void (*objectSetter)(void *, SEL, id);

//TODO: cache date formatter
//TODO: cleanup
//TODO: support sets (and other collections)
@implementation NSObject (Serialization)
- (NSDictionary *)serialize {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    Class objClass = [self class];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(objClass, &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        SEL getter;
        const char *getterName = property_copyAttributeValue(property, "G");
        if (getterName == NULL) {
            getter = NSSelectorFromString(propertyName);
        } else {
            getter = sel_getUid(getterName);
        }
        
        NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSString *propertyType = [[propertyAttributes componentsSeparatedByString:@","][0] substringFromIndex:1];
        const char *rawPropertyType = [propertyType UTF8String];
        
        if (strcmp(rawPropertyType, @encode(char)) == 0) {
            charGetter func = (charGetter)objc_msgSend;
            char value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
            intGetter func = (intGetter)objc_msgSend;
            int value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(short)) == 0) {
            shortGetter func = (shortGetter)objc_msgSend;
            short value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(long)) == 0) {
            longGetter func = (longGetter)objc_msgSend;
            long value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(long long)) == 0) {
            longLongGetter func = (longLongGetter)objc_msgSend;
            long long value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(unsigned char)) == 0) {
            unsignedCharGetter func = (unsignedCharGetter)objc_msgSend;
            unsigned char value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(unsigned int)) == 0) {
            unsignedIntGetter func = (unsignedIntGetter)objc_msgSend;
            unsigned int value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(unsigned short)) == 0) {
            unsignedShortGetter func = (unsignedShortGetter)objc_msgSend;
            unsigned short value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(unsigned long)) == 0) {
            unsignedLongGetter func = (unsignedLongGetter)objc_msgSend;
            unsigned long value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(unsigned long long)) == 0) {
            unsignedLongLongGetter func = (unsignedLongLongGetter)objc_msgSend;
            unsigned long long value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(float)) == 0) {
            floatGetter func = (floatGetter)objc_msgSend;
            float value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(double)) == 0) {
            doubleGetter func = (doubleGetter)objc_msgSend;
            double value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else if (strcmp(rawPropertyType, @encode(bool)) == 0) {
            boolGetter func = (boolGetter)objc_msgSend;
            bool value = func((__bridge void *)(self), getter);
            [dictionary setObject:@(value) forKey:propertyName];
        } else {
            objectGetter func = (objectGetter)objc_msgSend;
            id value = func((__bridge void *)(self), getter);
            
            if (!value) {
                continue;
            }
            
            id (^handleComplexObject)(id) = ^id (id complexObj){
                if ([complexObj isPrimitiveObject]) {
                    return complexObj;
                } else {
                    return [complexObj serialize];
                }
            };
            
            if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *serialized = [NSMutableArray new];
                for (id complexObj in value) {
                    [serialized addObject:handleComplexObject(complexObj)];
                }
                [dictionary setObject:serialized forKey:propertyName];
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *serialized = [NSMutableDictionary new];
                for (id key in [value allKeys]) {
                    [serialized setObject:handleComplexObject(value[key]) forKey:key];
                }
                [dictionary setObject:serialized forKey:propertyName];
            } else if ([value isKindOfClass:[NSDate class]]) {
                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *stringDate = [dateFormatter stringFromDate:value];
                [dictionary setObject:stringDate forKey:propertyName];
            } else {
                [dictionary setObject:handleComplexObject(value) forKey:propertyName];
            }
        }
    }
    
    free(properties);
    [dictionary setObject:NSStringFromClass([self class]) forKey:@"Class"];
    
    return [dictionary copy];
}

- (instancetype)fillWithData:(NSDictionary *)data {
    Class objClass = [self class];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(objClass, &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        SEL setter;
        const char *setterName = property_copyAttributeValue(property, "S");
        if (setterName == NULL) {
            setter = NSSelectorFromString([[@"set" stringByAppendingString:[[[propertyName substringToIndex:1] uppercaseString] stringByAppendingString:[propertyName substringFromIndex:1]]] stringByAppendingString:@":"]);
        } else {
            setter = sel_getUid(setterName);
        }
        
        NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSString *propertyType = [[propertyAttributes componentsSeparatedByString:@","][0] substringFromIndex:1];
        const char *rawPropertyType = [propertyType UTF8String];
        
        id object = [data objectForKey:propertyName];
        
        if (!object) {
            continue;
        }
        
        if (strcmp(rawPropertyType, @encode(char)) == 0) {
            charSetter func = (charSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object charValue]);
        } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
            intSetter func = (intSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object intValue]);
        } else if (strcmp(rawPropertyType, @encode(short)) == 0) {
            shortSetter func = (shortSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object shortValue]);
        } else if (strcmp(rawPropertyType, @encode(long)) == 0) {
            longSetter func = (longSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object longValue]);
        } else if (strcmp(rawPropertyType, @encode(long long)) == 0) {
            longLongSetter func = (longLongSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object longLongValue]);
        } else if (strcmp(rawPropertyType, @encode(unsigned char)) == 0) {
            unsignedCharSetter func = (unsignedCharSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object unsignedCharValue]);
        } else if (strcmp(rawPropertyType, @encode(unsigned int)) == 0) {
            unsignedIntSetter func = (unsignedIntSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object unsignedIntValue]);
        } else if (strcmp(rawPropertyType, @encode(unsigned short)) == 0) {
            unsignedShortSetter func = (unsignedShortSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object unsignedShortValue]);
        } else if (strcmp(rawPropertyType, @encode(unsigned long)) == 0) {
            unsignedLongSetter func = (unsignedLongSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object unsignedLongValue]);
        } else if (strcmp(rawPropertyType, @encode(unsigned long long)) == 0) {
            unsignedLongLongSetter func = (unsignedLongLongSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object unsignedLongLongValue]);
        } else if (strcmp(rawPropertyType, @encode(float)) == 0) {
            floatSetter func = (floatSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object floatValue]);
        } else if (strcmp(rawPropertyType, @encode(double)) == 0) {
            doubleSetter func = (doubleSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object doubleValue]);
        } else if (strcmp(rawPropertyType, @encode(bool)) == 0) {
            boolSetter func = (boolSetter)objc_msgSend;
            func((__bridge void *)(self), setter, [object boolValue]);
        } else {
            objectSetter func = (objectSetter)objc_msgSend;
            
            NSString* (^classForComplexObj)(id) = ^NSString*(id complexObj) {
                if ([complexObj isKindOfClass:[NSDictionary class]]) {
                    return [complexObj objectForKey:@"Class"];
                }
                return nil;
            };
            
            id (^handleComplexObj)(id) = ^id(id complexObj) {
                if ([complexObj isKindOfClass:[NSDictionary class]]) {
                    NSString *complexClass = classForComplexObj(complexObj);
                    if (complexClass) {
                        return [[NSClassFromString(complexClass) new] fillWithData:complexObj];
                    }
                }
                return complexObj;
            };
            
            if ([object isKindOfClass:[NSArray class]]) {
                NSMutableArray *mutable = [NSMutableArray new];
                for (id obj in object) {
                    [mutable addObject:handleComplexObj(obj)];
                }
                func((__bridge void *)(self), setter, [mutable copy]);
            } else if ([object isKindOfClass:[NSDictionary class]]) {
                if (classForComplexObj(object)) {
                    func((__bridge void *)(self), setter, handleComplexObj(object));
                } else {
                    NSMutableDictionary *serialized = [NSMutableDictionary new];
                    for (id key in [object allKeys]) {
                        [serialized setObject:handleComplexObj([object objectForKey:key]) forKey:key];
                    }
                    func((__bridge void *)(self), setter, [serialized copy]);
                }
            } else if ([object isKindOfClass:[NSString class]]) {
                NSString *propertyClassName = [propertyType substringWithRange:NSMakeRange(2, [propertyType length]-4)];
                if ([propertyClassName isEqualToString:@"NSDate"]) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *date = [dateFormatter dateFromString:object];
                    func((__bridge void *)(self), setter, date);
                } else {
                    func((__bridge void *)(self), setter, object);
                }
            }
            else {
                func((__bridge void *)(self), setter, object);
            }
        }
    }
    free(properties);
    
    return self;
}

- (BOOL)isPrimitiveObject {
    if ([self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSNumber class]] || [self isKindOfClass:[NSValue class]]) {
        return YES;
    }
    
    return NO;
}

@end
