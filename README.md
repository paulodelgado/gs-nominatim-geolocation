# gs-nominatim-geolocation

This is a (very thin) ObjectiveC wrapper for the Nominatim Geolocation API.  It requires GNUstep `libs-base`.

# Installation
Ensure you have `libs-base` from either your package manager or source.  On Debian (and its variants)
its usually just a matter of running

`sudo apt install libgnustep-base-dev`


```
git clone https://github.com/paulodelgado/gs-nominatim-geolocation.git
cd gs-nominatim-geolocation
make
make install # or sudo make install
```

# Usage

### Free form query:
```
GSNominatim *geolocationService = [[GSNominatim alloc] init];

NSString *queryString = @"Cupertino, CA";

[geolocationService fetchGeolocationByFreeQuery:queryString completionHandler:^(NSArray *geolocationData, NSError *error) {
  if (error) {
    NSLog(@"Error fetching geolocation data: %@", error);
  } else {
    NSLog(@"Geolocation Data: %@", geolocationData);
    // Do something with your geo location data.
  }
}];
```

### Structured Query

```
GSNominatim *geolocationService = [[GSNominatim alloc] init];

NSDictionary *structuredQuery = @{@"city": @"Sevilla"};

[geolocationService fetchGeolocationByStructuredQuery:structuredQuery completionHandler:^(NSArray *geolocationData, NSError *error) {
  if (error) {
    NSLog(@"Error fetching geolocation data: %@", error);
  } else {
    NSLog(@"Geolocation Data: %@", geolocationData);
    // Do something with your geoLocationData
  }
}];
```
