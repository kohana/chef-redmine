name             "redmine"
maintainer       "Juanje Ojeda"
maintainer_email "juanje.ojeda@gmail.com"
license          "Apache 2.0"
description      "Install Redmine from Github"
version          "0.1.0"

recipe "redmine", "Install the Redmine application from the source"
recipe "redmine::source", "Install the Redmine application from the source"
recipe "redmine::package", "Install the Redmine application from packages"

%w{ git mysql apt yum database chruby ruby_build unicorn-ng}.each do |dep|
  depends dep
end

%w{ debian ubuntu centos redhat amazon scientific fedora suse }.each do |os|
    supports os
end
