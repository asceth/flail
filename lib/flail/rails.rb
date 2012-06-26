if defined?(Rails)
  if Rails::VERSION::MAJOR == 2
    # override rescue action in public
  else
    # insert middleware
  end
end
