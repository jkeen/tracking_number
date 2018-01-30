## tracking_number

This gem identifies valid tracking numbers and the service they're associated with. It can also tell you a little bit about the package purely from the number—there's quite a bit of info tucked away into those numbers, it turns out.

This gem does not do tracking. That is left up to you.

```ruby
t = TrackingNumber.new("MYSTERY_TRACKING_NUMBER")
# => #<TrackingNumber::Unknown MYSTERY_TRACKING_NUMBER>

t.valid? #=> false
t.courier.code #=> :unknown

t = TrackingNumber.new("1Z879E930346834440")
# => #<TrackingNumber::UPS 1Z879E930346834440>

t.valid? #=> true
t.carrier #=> :ups
```
Also can take a block of text and find all the valid tracking numbers within it

```ruby
TrackingNumber.search("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 1Z879E930346834440
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis
aute 9611020987654312345672 dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui
officia deserunt mollit anim id est laborum.")

#=> [#<TrackingNumber::UPS 1Z879E930346834440>, #<TrackingNumber::FedExGround96 9611020987654312345672>]
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

Copyright (c) 2010 Jeff Keen. See LICENSE.txt for
further details.
