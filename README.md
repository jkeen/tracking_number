## Tracking Number (v1.x)

This gem identifies valid tracking numbers and can tell you a little bit about the shipment just from the number—there's quite a bit of info tucked away into those numbers, it turns out.

It detects tracking numbers from UPS, FedEx, DHL, USPS, OnTrac, Amazon Logistics, and 160+ countries national postal services (S10 standard).

This gem does not do tracking. That is left up to you.

## Usage

#### Checking an individual tracking number
```ruby
t = TrackingNumber.new("MYSTERY_TRACKING_NUMBER")
# => #<TrackingNumber::Unknown MYSTERY_TRACKING_NUMBER>
t.valid? #=> false

t = TrackingNumber.new("1Z879E930346834440")
# => #<TrackingNumber::UPS 1Z879E930346834440>
t.valid? #=> true
```

#### Searching a block of text
This will return valid tracking numbers contained within a block of text.

```ruby
TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440 nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")

#=> [#<TrackingNumber::UPS 1Z879E930346834440>, #<TrackingNumber::FedExGround96 9611020987654312345672>]
```

#### Courier Info
As of 1.0, the possible courier codes are `[:usps, :fedex, :ups, :ontrac, :dhl, :amazon, :s10, :unknown]`. S10 is the international standard used by local government post offices. When packages are shipped internationally via normal post, it's usually an S10 number.

```ruby
t = TrackingNumber.new("1Z879E930346834440")
# => #<TrackingNumber::UPS 1Z879E930346834440>

t.valid? #=> true
t.courier_code #=> :ups
t.courier_name #=> "UPS"


t = TrackingNumber.new("RB123456785GB")
t.courier_name #=> "Royal Mail Group plc"
t.courier_code #=> :s10

t = TrackingNumber.new("RB123456785US")
t.courier_name #=> "United States Postal Service"
```

#### Service Type
Some tracking numbers indicate their service type

```ruby
t = TrackingNumber.new("1Z879E930346834440")
t.service_type #=> "UPS United States Ground""

t = TrackingNumber.new("1ZXX3150YW44070023")
t.service_type #=> "UPS SurePost - Delivered by the USPS"

t = TrackingNumber.new("RB123456785US")
t.service_type #=> "Letter Post Registered"
```

#### Shipper ID
Some tracking numbers indicate information about their package
```ruby
t = TrackingNumber.new("1Z6072AF0320751583")
t.shipper_id #=> "6072AF" <-- this is Target
```

#### Destination Zip
Some tracking numbers indicate their destination

```ruby
t = TrackingNumber.new("1001901781990001000300617767839437")
t.destination_zip #=> "10003"
```

#### Package Info
Some tracking numbers indicate information about their package

```ruby
t = TrackingNumber.new("012345000000002")
t.package_type #=> "case/carton"
```

#### Decoding
Most tracking numbers have a format where each part of the number has meaning. `decode` splits up the number into its known named parts.
```ruby
  t = TrackingNumber.new("1Z879E930346834440")
  t.decode

  #=> {
  #  :serial_number => "879E93034683444",
  #  :shipper_id => "879E93",
  #  :service_type => "03",
  #  :package_id => "4683444",
  #  :check_digit => "0"
  # }   
```

## ActiveModel validation

For Rails 3 (or any ActiveModel client), validate your fields as a tracking number:
```ruby
class Shipment < ActiveRecord::Base
  validates :tracking, :tracking_number => true
end
```
Sometimes it's helpful to have a "magic" tracking number that isn't valid for any of the real carriers, and maybe will have other side effects (e.g., special treatment of a shipping email.)

```ruby
class Shipment < ActiveRecord::Base
  validates :tracking, :tracking_number => { :except => 'magic-hand-delivery' }
end
```

## Where the data comes from
Starting with the 1.0 release of this gem the data for tracking numbers has been extracted into a separate repository ([tracking_number_data](http://github.com/jkeen/tracking_number_data)) so non-ruby clients can benefit from the detection/documentation that used to be contained deep in the code of this gem. If you want to write a client in some other language, that's the stuff you want.

## Contributing to tracking_number
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2010-2018 Jeff Keen. See LICENSE.txt for
further details.
