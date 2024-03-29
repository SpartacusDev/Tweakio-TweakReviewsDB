#import "Tweak.h"


%subclass TWTweakReviewsDBApi : TWBaseRatingsApi

- (instancetype)init {
    self = %orig;
    if (self) {
        self.prefsValue = @"com.spartacus.tweakio.tweakreviewsdb";
        self.name = @"TweakReviewsDB";
        self.apiDescription = @"Made by pixelomer. Shows the rating of packages alongside reviews.";
        self.options = nil;
    }
    return self;
}

- (void)search:(Result *)package completionHandler:(void (^)(float, NSArray<TWReview *> *, NSError *))completionHandler {
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://tweakreviews.pixelomer.com/api/v3/package/%@/any/any/any", package.package]];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:api];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse *response, NSError *err){
        if (err) {
            completionHandler(-1, nil, err);
            return;
        }

        if (!data) {
            completionHandler(-1, nil, [[NSError alloc] initWithDomain:@"com.spartacus.tweakio" code:1 userInfo:@{   
                NSLocalizedDescriptionKey: @"Failed to retrieve data",
                NSLocalizedFailureReasonErrorKey: @"Failed to retrive data from TweakReviewsDB",
            }]);
            return;
        }

        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];

        NSMutableArray<TWReview *> *reviews = [NSMutableArray array];
        for (NSDictionary *review in results[@"reviews"]) {
            [reviews addObject:[[%c(TWReview) alloc] initWithAuthor:[[review objectForKey:@"username"] class] == NSNull.class ? nil : [review objectForKey:@"username"] title:nil content:review[@"content"] rating:[review[@"stars"] intValue]]];
        }
        completionHandler([results[@"averageStars"] floatValue], [reviews copy], nil);
    }];
    [task resume];
}

%end