//
//  ICMUserSearchViewController.m
//  InstagramCollageMaker
//
//  Created by  mrhard on 08.04.14.
//  Copyright (c) 2014 Azoft. All rights reserved.
//

#import "ICMUserSearchViewController.h"
#import "ICMUser.h"
#import <SVProgressHUD/SVProgressHUD.h>

#import <AFNetworking/UIImageView+AFNetworking.h>


@interface ICMUserSearchViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic) BOOL needShowActivityIndicator;
@property (nonatomic, strong) NSURLSessionDataTask *currentSearchDataTask;

@property (nonatomic, strong) NSMutableDictionary *searchResults;
@property (nonatomic, strong) NSString *currentSearchWord;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *errorLabel;

@end

@implementation ICMUserSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchResults = [NSMutableDictionary new];
    
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"search", nil);//@"Поиск";
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
}

#pragma mark - helpers

- (void)setCurrentSearchDataTask:(NSURLSessionDataTask *)currentSearchDataTask {
    [self.currentSearchDataTask cancel];
    _currentSearchDataTask = currentSearchDataTask;
}

- (UIView *)headerView {
    const CGFloat footerVerticalPaddings = 15.;
    if (!_headerView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView.color = [UIColor whiteColor];
        CGRect frame = CGRectZero;
        frame.size.width = self.view.frame.size.width;
        frame.size.height = self.activityIndicatorView.frame.size.height + footerVerticalPaddings * 2.;
        _headerView = [[UIView alloc] initWithFrame:frame];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView addSubview:self.activityIndicatorView];
        self.activityIndicatorView.center = CGPointMake(frame.size.width / 2., frame.size.height / 2.);
        
        self.errorLabel = [[UILabel alloc] initWithFrame:_headerView.bounds];
        self.errorLabel.backgroundColor = [UIColor clearColor];
        self.errorLabel.textColor = [UIColor whiteColor];
        self.errorLabel.numberOfLines = 0;
        self.errorLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:self.errorLabel];
        self.errorLabel.hidden = YES;
    }
    return _headerView;
}

- (UITableView *)activeTableView {
    return self.searchDisplayController.isActive ? self.searchDisplayController.searchResultsTableView : self.tableView;
}

- (void)setNeedShowActivityIndicator:(BOOL)needShowActivityIndicator {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNeedShowActivityIndicator:) object:@(NO)];
    self.errorLabel.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    if (self.needShowActivityIndicator != needShowActivityIndicator) {
        _needShowActivityIndicator = needShowActivityIndicator;
        [[self activeTableView] reloadData];
    }
}

- (void)hideActivityIndicatorWithErrorMessage:(NSString *)errorMessage {
    [self performSelector:@selector(setNeedShowActivityIndicator:) withObject:@(NO) afterDelay:2.];
    
    self.activityIndicatorView.hidden = YES;
    self.errorLabel.hidden = NO;
    self.errorLabel.text = errorMessage;
}

- (void)requestUsersWithName:(NSString *)userName {
    self.needShowActivityIndicator = YES;
    
    __weak __typeof(self) this = self;
    
    self.currentSearchDataTask = [ICMUser requestUsersWithUserName:userName
                                                        completion:^(NSArray *users, NSError *error) {
                                                            BOOL isCurrentWord = [userName isEqualToString:this.currentSearchWord];
                                                            if (error && isCurrentWord) {
                                                                [this hideActivityIndicatorWithErrorMessage:[error localizedDescription]];
                                                            } else if (users) {
                                                                this.searchResults[userName] = users;
                                                                if (isCurrentWord) {
                                                                    this.needShowActivityIndicator = NO;
                                                                    [[this activeTableView] reloadData];
                                                                }
                                                            }
                                                        }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.needShowActivityIndicator ?  self.headerView.frame.size.height : 0.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.needShowActivityIndicator) {
        [self.activityIndicatorView startAnimating];
        return self.headerView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults[self.currentSearchWord] count];
}

#define ICMUSER(indexPath) (self.searchResults[self.currentSearchWord][indexPath.row])

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"userCell"] ?: [[UITableViewCell alloc]
                                                                         initWithStyle:UITableViewCellStyleDefault
                                                                         reuseIdentifier:@"userCell"];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ICMUser *user = ICMUSER(indexPath);
    
    cell.backgroundColor = self.tableView.backgroundColor;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.textLabel.text = user.username;
    [cell.imageView setImageWithURL:user.photoURL placeholderImage:[UIImage imageNamed:@"AvatarPlaceholder"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.completion) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"checking access", nil) maskType:SVProgressHUDMaskTypeGradient];
        __weak ICMUser *user = ICMUSER(indexPath);
        [user checkUserPermissionsWithCompletion:^(BOOL userIsAviable, NSError *error) {
            if (userIsAviable) {
                [SVProgressHUD dismiss];
                if (self.completion) {
                    self.completion(user);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"the selected user has restricted access to your photos", nil)];
            }
        }];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchDisplayController setActive:NO animated:YES];
    if (self.needShowActivityIndicator) {
        self.needShowActivityIndicator = NO;
        self.needShowActivityIndicator = YES;
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestUsersWithName:) object:self.currentSearchWord];
    
    self.currentSearchWord = searchString;
    if ([searchString length] == 0 || self.searchResults[self.currentSearchWord]) {
        return YES;
    }
    
    [self performSelector:@selector(requestUsersWithName:) withObject:searchString afterDelay:0.5];
    return NO;
}

#pragma mark - Actions

- (IBAction)onCancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
