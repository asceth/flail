Flail is an exception catcher for Rack applications.

##### Supports

* Rails 2.3.x
* Rails 3.x


### Install

###### Rails 3
```
gem :flail
```


###### Rails 2.3.x
```
gem :flail, :require => false
```

When configuring in the initializer as seen in Usage below be sure to add
```
require 'flail/rails'
```

so the proper requires are done for Rails 2.3.x



### Usage


Add an initializer to configure (or call configure during application startup):

```ruby
Flail.configure do
  # configure a custom handler for the error payload
  # don't call if you want to use the default http post handler
  handle do |payload|
  end

  # endpoint for default handler
  url "https://flail.net/swing"

  # environment of application, defaults to Rails.env
  # included in payload
  environment "production"

  # hostname to use of server, defaults to Socket.gethostname
  # included in payload
  host Socket.gethostname

  # arbitrary tag (api key) which can identify
  # your project or be anything else
  tagged "custom_key"
end
```


### Helpful Additions
See flail_web for a Rails 3 application designed to receive flail exceptions so you can inspect them.
https://github.com/asceth/flail_web

### Author


Original author: John "asceth" Long
