/*
   Project: GSNominatim

   A wrapper to the Nominatim Geolocation web API

   Copyright (C) 2023 Free Software Foundation

   Author: Paulo Delgado

   Created: 2023-10-07 by Paulo Delgado

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "GSNominatim.h"


@implementation GSNominatim

static NSString *const NOMINATIM_BASE_URL = @"http://nominatim.openstreetmap.org/";

- (NSString *) freeQuerySearchURL:(NSString *) query {
  return [
    [NSString stringWithFormat:@"%@search?q=%@&format=json", NOMINATIM_BASE_URL, query]
    stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
  ];
}

- (NSString *) structuredQuerySearchURL:(NSDictionary *) query {
  NSString *baseURL = [NSString stringWithFormat:@"%@search?format=json", NOMINATIM_BASE_URL];
  NSMutableString *url = [NSMutableString stringWithString:baseURL];

  NSArray *keys = @[@"city", @"state", @"county", @"country", @"amenity", @"street", @"postalcode"];

  for (NSString *key in keys) {
    NSString *paramValue = query[key];
    if (paramValue) {
      [url appendFormat:@"&%@=%@", key, paramValue];
    }
  }

  return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void) fetch:(NSString *)stringURL completionHandler:(void (^)(NSArray *, NSError *))completionHandler {
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        completionHandler(nil, error);
        return;
      }

      NSError *jsonError;
      NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

      if (jsonError || ![results isKindOfClass:[NSArray class]]) {
            completionHandler(nil, jsonError ?: [self customError]);
      } else {
        NSMutableArray *geolocationData = [NSMutableArray array];

        for (NSDictionary *result in results) {
          double latitude = [result[@"lat"] doubleValue];
          double longitude = [result[@"lon"] doubleValue];
          NSString *displayName = result[@"display_name"];
          NSString *name = result[@"name"];

          NSDictionary *locationInfo = @{@"latitude": @(latitude),
                                        @"longitude": @(longitude),
                                      @"displayName": displayName ?: @"",
                                             @"name": name ?: @""};

          [geolocationData addObject:locationInfo];
        }

        completionHandler([geolocationData copy], nil);
      }
    }];

    [task resume];
}

- (void)fetchGeoLocationByFreeQuery:(NSString *)query completionHandler:(void (^)(NSArray *, NSError *))completionHandler {
  NSString *urlString = [self freeQuerySearchURL:query];
  [self fetch:urlString completionHandler:completionHandler];
}

- (void)fetchGeolocationByStructuredQuery:(NSDictionary *)query completionHandler:(void (^)(NSArray *, NSError *))completionHandler {
  NSString *urlString = [self structuredQuerySearchURL:query];
  [self fetch:urlString completionHandler:completionHandler];
}

- (NSError *)customError {
    return [NSError errorWithDomain:@"GeolocationServiceErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to retrieve geolocation data."}];
}
@end
