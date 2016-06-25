%hook CredentialPromptsViewController

BOOL isPasswordViewController;
static NSString *preferencesFilePath = @"/private/var/mobile/Library/Preferences/com.ahmad.passConnect.plist";

-(void)viewWillAppear:(BOOL)animated {

	NSDictionary *userPromptDict = MSHookIvar<NSDictionary *>(self, "userPromptDict");
	NSString *type = userPromptDict[@"PromptEntryArray"][0][@"Name"];
	
	if ([type isEqualToString:@"password"]) {
		
		isPasswordViewController = YES;
		
		NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath];
		
		if (preferences) {
			
			userPromptDict[@"PromptEntryArray"][0][@"Value"] = preferences[@"Password"];
			MSHookIvar<NSDictionary *>(self, "userPromptDict") = userPromptDict;
			
		}
		
	}
	
	%orig;
	
}

- (void)textFieldDidEndEditing:(UITextField *)arg1 {
	
	if (isPasswordViewController) {
		
		isPasswordViewController = NO;
		
		NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath];
		
		if (!preferences) {
			preferences = [[NSDictionary alloc] init];
		}
		
		NSString *passwordString = arg1.text;
		preferences = @{@"Password":passwordString};
		
		[preferences writeToFile:preferencesFilePath atomically:NO];
		
	}
	
	%orig;
	
}

%end