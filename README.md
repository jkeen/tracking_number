[![Ruby](https://github.com/jkeen/tracking_number/actions/workflows/ruby.yml/badge.svg)](https://github.com/jkeen/tracking_number/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/tracking_number.svg)](https://badge.fury.io/rb/tracking_number)
[![Gem](https://img.shields.io/gem/dt/tracking_number.svg)]()

> Hey there tracking number enthusiast! I don't use this project in any production capacity, and really never have. I am not a tracking number expert, and I don't have inside connections to a shipping company—I'm just a guy that once tried to make a package tracking app and this gem is all that survived. When I have absolutely nothing to do it's kinda fun to tinker with, but time has become more and more of a precious resource. Anyway, maintaining this is thankless work, and if this project has been useful for you I sure would appreciate a cup or two of coffee slid my way as a token of appreciation. A PR would also be nice. 
> 
> <a href="https://www.buymeacoffee.com/jeffkeen" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: auto !important;width: 150px !important;" ></a>

## Tracking Number (v1.x)

This gem identifies valid tracking numbers and can tell you a little bit about the shipment just from the number—there's quite a bit of info tucked away into those numbers, it turns out.

It detects tracking numbers from UPS, FedEx, DHL, USPS, OnTrac, Amazon Logistics, and 160+ countries national postal services (S10 standard).

This gem does not do tracking. That is left up to you.

#### New in 1.0

Starting with the 1.0 release the specifications for detecting tracking numbers have been moved into a separate repository ([tracking_number_data](http://github.com/jkeen/tracking_number_data)) that this gem relies on. I did this so a) we can have a single place to document all tracking number types and it can be more of a crowdsourced effort, and b) so clients can be written in other languages easier.

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

#### Tracking URL
Get the tracking url from the shipper
```ruby
t = TrackingNumber.new("1Z6072AF0320751583")
t.tracking_url #=> ""https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6072AF0320751583"
```

#### All the info we have
Get a object of all the info we have on the thing
```ruby
t = TrackingNumber.new("1Z6072AF0320751583")
t.info #=>  @courier=#<TrackingNumber::Info:0x000000010a45fed8 @code=:ups, @name="UPS">,
       #    @decode={:serial_number=>"6072AF032075158", :shipper_id=>"6072AF", :service_type=>"03", :package_id=>"2075158", :check_digit=>"3"},
       #    @destination_zip=nil,
       #    @package_type=nil,
       #    @partners=nil,
       #    @service_description=nil,
       #    @service_type="UPS United States Ground",
       #    @shipper_id="6072AF",
       #    @tracking_url="https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=1Z6072AF0320751583">
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

#### Multiple shippers / Partnerships
Some tracking numbers match multiple carriers, because they belong to multiple carriers. Some shipments like Fedex Smartpost contract the "last mile" out to USPS. 

```ruby
  # Search defaults to only showing numbers that fulfill the carrier side of the relationship 
  # (if a partnership exists at all), as this is the end a consumer would most likely be interested in.

  results = TrackingNumber.search('420112139261290983497923666238') 
  => [#<TrackingNumber::USPS91:0x26ac0 420112139261290983497923666238>]

  all_results = TrackingNumber.search('420112139261290983497923666238', match: :all) 
  => [#<TrackingNumber::FedExSmartPost:0x30624 420112139261290983497923666238>, #<TrackingNumber::USPS91:0x26ac0 420112139261290983497923666238>]

  tn = results.first
  tn.shipper? #=> false
  tn.carrier? #=> true
  tn.partnership? #=> true
  tn.partners
  #=> <struct TrackingNumber::Base::PartnerStruct
  #       shipper=#<TrackingNumber::FedExSmartPost:0x30624 420112139261290983497923666238>,
  #       carrier=#<TrackingNumber::USPS91:0x2f1fc 420112139261290983497923666238>>

  tn.partners.shipper #=> #<TrackingNumber::FedExSmartPost:0x30624 420112139261290983497923666238>
  tn.partners.carrier == tn #=> true
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

## Contributing to tracking_number
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2010-2021 Jeff Keen. See LICENSE.txt for
further details.
