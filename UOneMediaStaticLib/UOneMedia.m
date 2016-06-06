//
//  UOneMedia.m
//  UOneMedia
//
//  Created by wuxin on 5/24/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "UOneMedia.h"

@implementation UOneMedia

+ (void)start {
    
    /* * *
     force linker Not to strip ObjC Class
     http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
     
     * * * * * * * * * */
    //[NSBundle UOneMediaBundle];
    [UOneDownloadTableViewCell forceLinkerLoad];
}

@end

