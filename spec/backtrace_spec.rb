require 'spec_helper'

require 'flail/backtrace'

describe Flail::Backtrace do

  SAMPLE_BACKTRACE = [
                      "app/models/user.rb:13:in `magic'",
                      "app/controllers/users_controller.rb:8:in `index'"
                     ]


  it "should parse a backtrace into lines" do
    backtrace = Flail::Backtrace.parse(SAMPLE_BACKTRACE)

    line = backtrace.lines.first
    line.number.should == '13'
    line.file.should == 'app/models/user.rb'
    line.method.should == 'magic'

    line = backtrace.lines.last
    line.number.should == '8'
    line.file.should == 'app/controllers/users_controller.rb'
    line.method.should == 'index'
  end


  it "should parse a windows backtrace into lines" do
    array = [
      "C:/Program Files/Server/app/models/user.rb:13:in `magic'",
      "C:/Program Files/Server/app/controllers/users_controller.rb:8:in `index'"
    ]

    backtrace = Flail::Backtrace.parse(array)

    line = backtrace.lines.first
    line.number.should == '13'
    line.file.should == 'C:/Program Files/Server/app/models/user.rb'
    line.method.should == 'magic'

    line = backtrace.lines.last
    line.number.should == '8'
    line.file.should == 'C:/Program Files/Server/app/controllers/users_controller.rb'
    line.method.should == 'index'
  end

  it "should be equal with equal lines" do
    one = SAMPLE_BACKTRACE
    two = one.dup

    Flail::Backtrace.parse(one).should == Flail::Backtrace.parse(two)
  end

  it "should parse massive one-line exceptions into multiple lines" do
    original_backtrace = Flail::Backtrace.parse(["one:1:in `one'\n   two:2:in `two'\n      three:3:in `three`"])
    expected_backtrace = Flail::Backtrace.parse(["one:1:in `one'", "two:2:in `two'", "three:3:in `three`"])

    expected_backtrace.should == original_backtrace
  end

  it "should remove notifier trace" do
    inside_notifier  = ['lib/flail/exception.rb:13:in `voodoo`']
    outside_notifier = ['users_controller:8:in `index`']

    without_inside = Flail::Backtrace.parse(outside_notifier)
    with_inside    = Flail::Backtrace.parse(inside_notifier + outside_notifier,
                                            :filters => Flail::Backtrace::DEFAULT_FILTERS)

    without_inside.should == with_inside
  end

  it "should run filters on the backtrace" do
    filters = [lambda { |line| line.sub('foo', 'bar') }]

    input = Flail::Backtrace.parse(["foo:13:in `one'",
                                    "baz:14:in `two'"
                                   ], :filters => filters)

    expected = Flail::Backtrace.parse(["bar:13:in `one'",
                                       "baz:14:in `two'"
                                      ])

    expected.should == input
  end
end
