
%hook CredentialPromptsViewController

BOOL isPasswordViewController;
static NSString *preferencesFilePath = @"/private/var/mobile/Library/Preferences/com.ahmad.passConnect.plist";

-(void)viewWillAppear:(BOOL)animated {
	
	NSMutableDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath].mutableCopy;
	if (!preferences) preferences = [[NSMutableDictionary alloc] init];
	
	NSDictionary *userPromptDict = MSHookIvar<NSDictionary *>(self, "userPromptDict");
	NSString *type = userPromptDict[@"PromptEntryArray"][0][@"Name"];
	
	if ([type isEqualToString:@"password"]) {
		
		isPasswordViewController = YES;
		
		if (preferences[@"Password"]) {
			userPromptDict[@"PromptEntryArray"][0][@"Value"] = preferences[@"Password"];
			MSHookIvar<NSDictionary *>(self, "userPromptDict") = userPromptDict;
		}
		
	}
	
	%orig;
	
}

- (void)textFieldDidEndEditing:(UITextField *)arg1 {
	
	if (isPasswordViewController) {
		
		isPasswordViewController = NO;
		
		NSMutableDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath].mutableCopy;
		if (!preferences) preferences = [[NSMutableDictionary alloc] init];
		
		NSString *passwordString = arg1.text;
		[preferences setObject:passwordString forKey:@"Password"];
		[preferences writeToFile:preferencesFilePath atomically:NO];
		
	}
	
	%orig;
	
}

-(void)viewDidAppear:(BOOL)animated {

	NSMutableDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath].mutableCopy;
	if (!preferences) {
		preferences = [[NSMutableDictionary alloc] init];
	}

    NSDictionary *userPromptDict = MSHookIvar<NSDictionary *>(self, "userPromptDict");
    NSString *value = userPromptDict[@"PromptEntryArray"][0][@"Value"];

    if (![value isEqualToString:@""] && [preferences[@"AutoConnect"] isEqualToString:@"YES"]) {
    	[self performSelector:@selector(connect)];
    }

    %orig;

}

%end

%hook HomeViewController

UISwitch *connectSwitch;

-(void)viewDidLoad {
	
	%orig;
	
	connectSwitch = [[UISwitch alloc] init];
	[connectSwitch addTarget:self action:@selector(connectSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	NSMutableDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath].mutableCopy;
	if (!preferences) {
		preferences = [[NSMutableDictionary alloc] init];
	}
	
	if ([preferences[@"AutoConnect"] isEqualToString:@"YES"]) {
		[connectSwitch setOn:YES];
	}
	
}

%new(v@:)
-(void)connectSwitchValueChanged:(UISwitch *)sender {
	
	NSMutableDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath].mutableCopy;
	if (!preferences) {
		preferences = [[NSMutableDictionary alloc] init];
	}
	
	NSString *switchStatus;
	
	if (sender.isOn) {
		switchStatus = @"YES";
	} else {
		switchStatus = @"NO";
	}
	
	[preferences setObject:switchStatus forKey:@"AutoConnect"];
	[preferences writeToFile:preferencesFilePath atomically:NO];
	
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 3) {
		
		UITableViewCell *cell = [[UITableViewCell alloc] init];
		cell.textLabel.text = @"Auto Connect";
		cell.accessoryView = connectSwitch;
		
		return cell;
		
	} else {
		
		return %orig;
		
	}
	
}

%end


