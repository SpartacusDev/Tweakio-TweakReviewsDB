#import "Tweak.h"


@implementation TWTweakReviewsDBApi

- (instancetype)init {
    self = [super init];
    if (self) {
        self.prefsValue = @"com.spartacus.tweakio.tweakreviewsdb";
        self.name = @"TweakReviewsDB";
        self.apiDescription = @"Made by pixelomer. Shows the rating of packages alongside reviews.";
        self.options = nil;
    }
    return self;
}

- (void)search:(Result *)package error:(NSError **)error completionHandler:(void (^)(float, NSArray<TWReview *> *))completionHandler {
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://tweakreviews.pixelomer.com/api/v3/package/%@/any/any/any", package.package]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    if (!data) {
        *error = [[NSError alloc] initWithDomain:@"com.spartacus.tweakio" code:1 userInfo:@{   
            NSLocalizedDescriptionKey: @"Failed to retrieve data",
            NSLocalizedFailureReasonErrorKey: @"Failed to retrive data from TweakReviewsDB",
        }];
        return;
    }

    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];

    NSMutableArray<TWReview *> *reviews = [NSMutableArray array];
    for (NSDictionary *review in results[@"reviews"]) {
        [reviews addObject:[[%c(TWReview) alloc] initWithAuthor:[[review objectForKey:@"username"] class] == NSNull.class ? nil : [review objectForKey:@"username"] title:nil content:review[@"content"] rating:[review[@"stars"] intValue]]];
    }
	completionHandler([results[@"averageStars"] floatValue], [reviews copy]);
}

@end

%ctor {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    class_setSuperclass(TWTweakReviewsDBApi.class, %c(TWBaseRatingsApi));
#pragma clang diagnostic pop
}