//
//  SectionTableController.m
//  Wikish
//
//  Created by ENZO YANG on 13-3-1.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "SectionTableController.h"
#import "Constants.h"
#import "WikiPageInfo.h"
#import "WikiSection.h"

@implementation SectionTableController

- (BOOL)canShow {
    if (!self.mainController.pageInfo) return NO;
    if (!self.mainController.pageInfo.sections) return NO;
    if ([self.mainController.pageInfo.sections count] == 0) return NO;
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self canShow]) return 0;
    return [self.mainController.pageInfo.sections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundView = [UIView new];
        cell.backgroundView.backgroundColor = GetTableCellBackgroundColor();
        cell.contentView.backgroundColor    = GetTableBackgourndColor();
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = GetTableHighlightRowColor();
    }
    WikiSection *section = [self.mainController.pageInfo.sections objectAtIndex:indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@ %@", section.index, section.line];
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WikiSection *section = [self.mainController.pageInfo.sections objectAtIndex:indexPath.row];
    [self.mainController scrollTo:section.anchor];
}

@end
