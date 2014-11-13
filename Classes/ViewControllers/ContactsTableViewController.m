//  Copyright (c) 2014 Evgeny Aleksandrov. All rights reserved.

#import "ContactsTableViewController.h"

static NSString * const ContactCellIdentifier = @"ContactCell";

@interface ContactsTableViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *sectionHeaders;

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"PeerTalk";
    
    self.sections = @[[EAPostmaster sharedInstance].discoveredContacts];
    
    self.sectionHeaders = @{@0 : @"Online",
                            @1 : @"Offline"};
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ContactCellIdentifier];
    
    [[EAPostmaster sharedInstance] setDelegate:self];
    [[EAPostmaster sharedInstance] startWorking];
}

#pragma mark - EAPostmaster delegate

- (void)postmaster:(EAPostmaster *)postmaster foundPeerWithId:(NSString *)contactId {
    self.sections = @[[EAPostmaster sharedInstance].discoveredContacts];
    [self.tableView reloadData];
}

- (void)postmaster:(EAPostmaster *)postmaster lostPeerWithId:(NSString *)contactId {
    self.sections = @[[EAPostmaster sharedInstance].discoveredContacts];
    [self.tableView reloadData];
}

- (void)postmaster:(EAPostmaster *)postmaster recievedMessage:(NSString *)message fromPeerWithId:(NSString *)contactId {
    
}

#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.sections[section]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionHeaders[@(section)];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    
    [cell.textLabel setText:[item objectForKey:displayNameKey]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeItemAtIndexPath:indexPath];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    /*NSInteger newSection = (indexPath.section == 0) ? 1 : 0;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:newSection];
    
    [self insertItem:[self itemAtIndexPath:indexPath] atIndexPath:newIndexPath];
    [self removeItemAtIndexPath:indexPath];
    
    [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];*/
}

#pragma mark - Data helpers

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section][indexPath.row];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *tempArray = [self.sections[indexPath.section] mutableCopy];
    NSMutableArray *tempSections = [self.sections mutableCopy];
    
    [tempArray removeObjectAtIndex:indexPath.row];
    tempSections[indexPath.section] = [tempArray copy];
    self.sections = [tempSections copy];
}

- (void)insertItem:(id)item atIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *tempArray = [self.sections[indexPath.section] mutableCopy];
    NSMutableArray *tempSections = [self.sections mutableCopy];
    
    [tempArray insertObject:item atIndex:indexPath.row];
    tempSections[indexPath.section] = [tempArray copy];
    self.sections = [tempSections copy];
}

@end
