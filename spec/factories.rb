module Lerk
  FactoryBot.define do
    to_create(&:save)

    # factory :foo, class Foo::Bar do
    # ...
    # end
  end
end
