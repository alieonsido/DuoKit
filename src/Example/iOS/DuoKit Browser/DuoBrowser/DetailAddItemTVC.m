//
//  DetailAddItemTVC.m
//  DuoKit Browser
//
//  The MIT License (MIT)
//
//  Copyright © 2017 MediaTek Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DetailAddItemTVC.h"
#import "DetailColorPickerTVC.h"
#import "DetailAddItemDefaultCell.h"
#import "DetailAddItemTypeCell.h"
#import "DetailAddItemColorCell.h"

typedef enum {
    DetailAddItemNone = 0,
    DetailAddItemName,
    DetailAddItemType,
    DetailAddItemPin,
    DetailAddItemMode,
    DetailAddItemInterval,
    DetailAddItemColor
} DetailAddItemKey;

@interface DetailAddItemTVC () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, DetailColorPickerDelegate>

@property (nonatomic, strong) NSMutableArray  *typeDataSource;
@property (nonatomic, strong) UIPickerView    *typePicker;

@property (nonatomic, strong) NSMutableArray  *modeDataSource;
@property (nonatomic, strong) UIPickerView    *modePicker;

@property (nonatomic, strong) UITextField     *nameTextField;
@property (nonatomic, strong) UITextField     *typeTextField;
@property (nonatomic, strong) UITextField     *pinTextField;
@property (nonatomic, strong) UITextField     *modeTextField;
@property (nonatomic, strong) UITextField     *intervalTextField;
@property (nonatomic, strong) UIView          *colorView;

@end

@implementation DetailAddItemTVC

- (void)loadView
{
    [super loadView];
    
    UIBarButtonItem *addButton
    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                    target:self
                                                    action:@selector(addButtonAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *backButton
    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                    target:self
                                                    action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _layout = [NSMutableArray arrayWithArray:@[@(DetailAddItemName),
                                               @(DetailAddItemType),
                                               @(DetailAddItemPin),
                                               @(DetailAddItemMode),
                                               @(DetailAddItemInterval),
                                               @(DetailAddItemColor)
                                               ]];
    
    
    _typeDataSource = [NSMutableArray arrayWithArray:@[@"Digital", @"Analog"]];
    _typePicker = [UIPickerView new];
    _typePicker.dataSource = self;
    _typePicker.delegate = self;
    _typePicker.showsSelectionIndicator = YES;
    [_typePicker selectRow:0 inComponent:0 animated:NO];
    
    _modeDataSource = [NSMutableArray arrayWithArray:@[@"Ouput", @"Input"]]; // , @"Input Pullup"
    _modePicker = [UIPickerView new];
    _modePicker.dataSource = self;
    _modePicker.delegate = self;
    _modePicker.showsSelectionIndicator = YES;
    [_modePicker selectRow:1 inComponent:0 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_editIndex >= 0 && _editLayout) {
        self.navigationItem.title = [NSString stringWithFormat:@"Edit \"%@\"", _editLayout.name ? _editLayout.name : @"--"];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"General";
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _layout.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([[_layout objectAtIndex:indexPath.row] integerValue]) {
        case DetailAddItemName: {
            DetailAddItemDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailAddItemDefaultCellIdentifer
                                                                             forIndexPath:indexPath];
            cell.title.text = @"Name";
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            _nameTextField = cell.textField;
            _nameTextField.delegate = self;
            if (_editIndex >= 0 && _editLayout) {
                _nameTextField.text = _editLayout.name ? _editLayout.name : @"";
            }
            return cell;
        }
        case DetailAddItemType: {
            DetailAddItemTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailAddItemTypeCellIdentifer
                                                                          forIndexPath:indexPath];
            cell.textField.hideCaret = YES;
            
            cell.title.text = @"Type";
            cell.textField.text = _typeDataSource[0];
            [cell.textField setInputView:_typePicker];
            _typeTextField = cell.textField;
            _typeTextField.delegate = self;
            if (_editIndex >= 0 && _editLayout) {
                [_typePicker selectRow:_editLayout.type == DuoUISwitch ? 0 : 1 inComponent:0 animated:NO];
                _typeTextField.text = _typeDataSource[_editLayout.type == DuoUISwitch ? 0 : 1];
            }
            
            UIBarButtonItem *flexibleItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                            target:nil
                                                            action:nil];
            UIBarButtonItem *doneButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dissmissTypeInputView)];
            UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                                   self.tableView.contentSize.width,
                                                                                   44.f)];
            [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
            cell.textField.inputAccessoryView = inputToolbar;
            return cell;
        }
        case DetailAddItemPin: {
            DetailAddItemDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailAddItemDefaultCellIdentifer
                                                                             forIndexPath:indexPath];
            cell.title.text = @"Pin Number";
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            _pinTextField = cell.textField;
            _pinTextField.delegate = self;
            if (_editIndex >= 0 && _editLayout) {
                _pinTextField.text = _editLayout.pin ? [NSString stringWithFormat:@"%ld", (long)_editLayout.pin] : @"";
            }
            UIBarButtonItem *flexibleItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                            target:nil
                                                            action:nil];
            UIBarButtonItem *doneButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dissmissInputView:)];
            UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                                   self.tableView.contentSize.width,
                                                                                   44.f)];
            
            [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
            cell.textField.inputAccessoryView = inputToolbar;
            return cell;
        }
        case DetailAddItemMode: {
            DetailAddItemTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailAddItemTypeCellIdentifer
                                                                          forIndexPath:indexPath];
            cell.textField.hideCaret = YES;
            
            cell.title.text = @"Current Pin Mode";
            cell.textField.text = _modeDataSource[1];
            [cell.textField setInputView:_modePicker];
            _modeTextField = cell.textField;
            _modeTextField.delegate = self;
            if (_editIndex >= 0 && _editLayout) {
                [_modePicker selectRow:_editLayout.type == DuoUIGetter ? 0 : 1 inComponent:0 animated:NO];
                _modeTextField.text = _modeDataSource[_editLayout.type == DuoUIGetter ? 0 : 1];
            }
            
            UIBarButtonItem *flexibleItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                            target:nil
                                                            action:nil];
            UIBarButtonItem *doneButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dissmissModeInputView)];
            UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                                   self.tableView.contentSize.width,
                                                                                   44.f)];
            [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
            cell.textField.inputAccessoryView = inputToolbar;
            return cell;
        }
        case DetailAddItemInterval: {
            DetailAddItemDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailAddItemDefaultCellIdentifer
                                                                             forIndexPath:indexPath];
            cell.title.text = @"Reload Interval (secs)";
            cell.textField.text = @"10";
            cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            _intervalTextField = cell.textField;
            _intervalTextField.delegate = self;
            if (_editIndex >= 0 && _editLayout) {
                _intervalTextField.text = _editLayout.reloadInterval ? [NSString stringWithFormat:@"%.f", MAX(3.f, _editLayout.reloadInterval)] : @"";
            }
            
            UIBarButtonItem *flexibleItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                            target:nil
                                                            action:nil];
            UIBarButtonItem *doneButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(dissmissInputView:)];
            UIToolbar *inputToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(.0f, .0f,
                                                                                   self.tableView.contentSize.width,
                                                                                   44.f)];
            
            [inputToolbar setItems:@[flexibleItem, doneButton] animated:NO];
            cell.textField.inputAccessoryView = inputToolbar;
            return cell;
        }
        case DetailAddItemColor: {
            DetailAddItemColorCell *cell = [tableView dequeueReusableCellWithIdentifier:kDetailAddItemColorCellIdentifer
                                                                           forIndexPath:indexPath];
            cell.title.text = @"Color";
            cell.colorView.backgroundColor = kColorUIDefault;
            _colorView = cell.colorView;
            if (_editIndex >= 0 && _editLayout) {
                _colorView.backgroundColor = _editLayout.color ? _editLayout.color : kColorUIDefault;
            }
            return cell;
        }
        default:
            break;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([[_layout objectAtIndex:indexPath.row] integerValue]) {
        case DetailAddItemColor:
            [self performSegueWithIdentifier:kDetailColorPickerSegueIdentifer sender:self];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:kDetailColorPickerSegueIdentifer]) {
        DetailColorPickerTVC *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.color = _colorView.backgroundColor;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _typePicker) {
        return _typeDataSource.count;
    } else if (pickerView == _modePicker) {
        return _modeDataSource.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _typePicker) {
        return _typeDataSource[row];
    } else if (pickerView == _modePicker) {
        return _modeDataSource[row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _typePicker) {
        _typeTextField.text = _typeDataSource[row];
    } else if (pickerView == _modePicker) {
        _modeTextField.text = _modeDataSource[row];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _typeTextField ||
        textField == _modeTextField) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self checkTextFields];
    return YES;
}

- (void)dissmissInputView:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self checkTextFields];
}

- (void)dissmissTypeInputView
{
    NSInteger selected = [_typePicker selectedRowInComponent:0];
    _typeTextField.text = _typeDataSource[selected];
    [_typeTextField resignFirstResponder];
    [self checkTextFields];
}

- (void)dissmissModeInputView
{
    NSInteger selected = [_modePicker selectedRowInComponent:0];
    _modeTextField.text = _modeDataSource[selected];
    [_modeTextField resignFirstResponder];
    [self checkTextFields];
}

- (void)checkTextFields
{
    if (!_nameTextField.text.length) {
        [_nameTextField becomeFirstResponder];
    } else if (!_typeTextField.text.length) {
        [_typeTextField becomeFirstResponder];
    } else if (!_pinTextField.text.length || [_pinTextField.text integerValue] < 0) {
        _pinTextField.text = @"";
        [_pinTextField becomeFirstResponder];
    } else if ([_modePicker selectedRowInComponent:0] < DuoPinOutput || [_modePicker selectedRowInComponent:0] > DuoPinInputPullup) {
        [_modeTextField becomeFirstResponder];
    } else if ([_intervalTextField.text integerValue] != 0 && [_intervalTextField.text integerValue] < 3) {
        _intervalTextField.text = @"";
        [_intervalTextField becomeFirstResponder];
    }
}

#pragma mark - DetailColorPickerDelegate

- (void)colorChanged:(UIColor *)color
{
    if (color) {
        if (_editIndex >= 0 && _editLayout) {
            _editLayout.color = color;
        }
        _colorView.backgroundColor = color;
    }
}

#pragma mark - IBAction

- (IBAction)addButtonAction:(id)sender
{
    NSString *error;
    UITextField *errorTextField;
    
    if (!_nameTextField.text.length) {
        error = @"You must give this control a name!";
        errorTextField = _nameTextField;
    } else if (!_typeTextField.text.length) {
        error = @"You must select a Pin type!";
        errorTextField = _typeTextField;
    } else if (!_pinTextField.text.length || [_pinTextField.text integerValue] < 0) {
        error = @"Invalid Pin number!";
        errorTextField = _pinTextField;
    } else if ([_modePicker selectedRowInComponent:0] < DuoPinOutput || [_modePicker selectedRowInComponent:0] > DuoPinInputPullup) {
        error = @"Invalid Pin mode!";
        errorTextField = _modeTextField;
    } else if ([_intervalTextField.text integerValue] != 0 && [_intervalTextField.text integerValue] < 3) {
        error = @"Reload interval must either be 0 or longer than 3 secs!";
        errorTextField = _intervalTextField;
    }
    
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:error
                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      if (errorTextField) {
                                                                          [errorTextField becomeFirstResponder];
                                                                      };
                                                                  });
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    DuoUI *newUI = [DuoUI new];

    newUI.type  = [_modePicker selectedRowInComponent:0] == DuoPinOutput ? DuoUIGetter : [_typePicker selectedRowInComponent:0] == DuoSetPinDigital ? DuoUISwitch : DuoUISlider;
    newUI.name  = _nameTextField.text;
    newUI.pin   = [_pinTextField.text integerValue];
    switch (newUI.type) {
        case DuoUISlider:
            newUI.minimumValue = 0;
            newUI.maximumValue = 0xFF;
            break;
        case DuoUIGetter:
            newUI.valueType = DuoIntType;
            break;
        default:
            break;
    }
    newUI.reloadInterval = [_intervalTextField.text integerValue];
    newUI.color = _colorView.backgroundColor ? _colorView.backgroundColor : kColorUIDefault;
    
    if (_editIndex >= 0) {
        [_delegate itemEdited:newUI atIndex:_editIndex];
    } else {
        [_delegate newItemAdded:newUI];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
