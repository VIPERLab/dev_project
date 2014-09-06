//
//  DataItem.m
//  KwSing
//
//  Created by 熊 改 on 12-11-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "DataItem.h"
#import "HotSongsView.h"

@implementation DataItem

@synthesize uid,title,pic,uname,view,conmment,flower,sid,parentParserDelegate;

-(id)init
{
    self=[super init];
    if (self) {
    }
    return self;
}
-(void)dealloc
{
    [uid release];
    [title release];
    [pic release];
    [uname release];
    [view release];
    [comment release];
    [flower release];
    [sid release];
    [parentParserDelegate release];
    [super dealloc];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"id"]) {
        currentString=[[NSMutableString alloc] init];
        [self setUid:currentString];
    }
    else if ([elementName isEqualToString:@"title"]){
        currentString=[[NSMutableString alloc] init];
        [self setTitle:currentString];
    }
    else if ([elementName isEqualToString:@"pic"]){
        currentString=[[NSMutableString alloc] init];
        [self setPic:currentString];
    }
    else if ([elementName isEqualToString:@"uname"]){
        currentString=[[NSMutableString alloc] init];
        [self setUname:currentString];
    }
    else if ([elementName isEqualToString:@"view"]){
        currentString=[[NSMutableString alloc] init];
        [self setView:currentString];
    }
    else if ([elementName isEqualToString:@"comment"]){
        currentString=[[NSMutableString alloc] init];
        [self setConmment:currentString];
    }
    else if ([elementName isEqualToString:@"flower"]){
        currentString=[[NSMutableString alloc] init];
        [self setFlower:currentString];
    }
    else if ([elementName isEqualToString:@"sid"]){
        currentString=[[NSMutableString alloc] init];
        [self setSid:currentString];
    }
    else if([elementName isEqualToString:@"type"]){
        currentString=[[NSMutableString alloc] init];
        [self setType:currentString];
    }
    else if ([elementName isEqualToString:@"url"]){
        currentString =[[NSMutableString alloc] init];
        [self setUrl:currentString];
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [currentString release];
    currentString=nil;
    
    if ([elementName isEqualToString:@"list"]) {
        [(HotSongsView*)[self parentParserDelegate] addItem:self];
        [parser setDelegate:parentParserDelegate];
    }
}

@end
