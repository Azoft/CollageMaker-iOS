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

@end

@implementation ICMUserSearchViewController {
    NSMutableDictionary *_searchResults;
    NSString *_currentSearchWord;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_errorLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchResults = [NSMutableDictionary new];
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

#pragma mark - helpers

- (void)setCurrentSearchDataTask:(NSURLSessionDataTask *)currentSearchDataTask {
    [_currentSearchDataTask cancel];
    _currentSearchDataTask = currentSearchDataTask;
}

- (UIView *)headerView {
    const CGFloat footerVerticalPaddings = 15.;
    if (!_headerView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.color = [UIColor blueColor];
        CGRect frame = CGRectZero;
        frame.size.width = self.view.frame.size.width;
        frame.size.height = _activityIndicatorView.frame.size.height + footerVerticalPaddings * 2.;
        _headerView = [[UIView alloc] initWithFrame:frame];
        _headerView.backgroundColor = [UIColor whiteColor];
        [_headerView addSubview:_activityIndicatorView];
        _activityIndicatorView.center = CGPointMake(frame.size.width / 2., frame.size.height / 2.);
        
        _errorLabel = [[UILabel alloc] initWithFrame:_headerView.bounds];
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.textColor = [UIColor blackColor];
        _errorLabel.numberOfLines = 0;
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_errorLabel];
        _errorLabel.hidden = YES;
    }
    return _headerView;
}

- (UITableView *)activeTableView {
    return self.searchDisplayController.isActive ? self.searchDisplayController.searchResultsTableView : self.tableView;
}

- (void)setNeedShowActivityIndicator:(BOOL)needShowActivityIndicator {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNeedShowActivityIndicator:) object:@(NO)];
    _errorLabel.hidden = YES;
    _activityIndicatorView.hidden = NO;
    if (_needShowActivityIndicator != needShowActivityIndicator) {
        _needShowActivityIndicator = needShowActivityIndicator;
        [[self activeTableView] reloadData];
    }
}

- (void)hideActivityIndicatorWithErrorMessage:(NSString *)errorMessage {
    [self performSelector:@selector(setNeedShowActivityIndicator:) withObject:@(NO) afterDelay:2.];
    
    _activityIndicatorView.hidden = YES;
    _errorLabel.hidden = NO;
    _errorLabel.text = errorMessage;
}

- (void)requestUsersWithName:(NSString *)userName {
    self.needShowActivityIndicator = YES;
    
    self.currentSearchDataTask = [ICMUser requestUsersWithUserName:userName
                                                        completion:^(NSArray *users, NSError *error) {
                                                            BOOL isCurrentWord = [userName isEqualToString:_currentSearchWord];
                                                            if (error && isCurrentWord) {
                                                                [self hideActivityIndicatorWithErrorMessage:[error localizedDescription]];
                                                            } else if (users) {
                                                                _searchResults[userName] = users;
                                                                if (isCurrentWord) {
                                                                    self.needShowActivityIndicator = NO;
                                                                    [[self activeTableView] reloadData];
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
        [_activityIndicatorView startAnimating];
        return self.headerView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResults[_currentSearchWord] count];
}

#define ICMUSER(indexPath) (_searchResults[_currentSearchWord][indexPath.row])

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"userCell"] ?: [[UITableViewCell alloc]
                                                                         initWithStyle:UITableViewCellStyleDefault
                                                                         reuseIdentifier:@"userCell"];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ICMUser *user = ICMUSER(indexPath);
    
    cell.textLabel.text = user.username;
    [cell.imageView setImageWithURL:user.photoURL placeholderImage:[UIImage imageNamed:@"AvatarPlaceholder"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.completion) {
        [SVProgressHUD showWithStatus:@"Проверка доступа" maskType:SVProgressHUDMaskTypeGradient];
        __weak ICMUser *user = ICMUSER(indexPath);
        [user checkUserPermissionsWithCompletion:^(BOOL userIsAviable, NSError *error) {
            if (userIsAviable) {
                [SVProgressHUD dismiss];
                if (self.completion) {
                    self.completion(user);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Выбранный пользователь закрыл доступ к своим фотографиям"];
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
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestUsersWithName:) object:_currentSearchWord];
    
    _currentSearchWord = searchString;
    if ([searchString length] == 0 || _searchResults[_currentSearchWord]) {
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
