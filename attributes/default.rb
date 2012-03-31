# generic attribs
default["redmine"]["env"]       = 'production'
default["redmine"]["repo"]      = 'git://github.com/redmine/redmine.git'
default["redmine"]["revision"]  = '1.3.2'
default["redmine"]["deploy_to"] = '/opt/redmine'
default["redmine"]["path"]      = '/var/www/redmine'
default["redmine"]["owner"]     = 'www-data' # for Debian and Ubuntu
default["redmine"]["group"]     = 'www-data' # for Debian and Ubuntu

# databases
default["redmine"]["databases"]["production"]["adapter"]  = 'mysql'
default["redmine"]["databases"]["production"]["database"] = 'redmine'
default["redmine"]["databases"]["production"]["username"] = 'redmine'
default["redmine"]["databases"]["production"]["password"]  = 'password'

# packages
# packages are separated to better tracking
default["redmine"]["packages"]["mysql"]   = %w{ libmysqlclient-dev }
default["redmine"]["packages"]["apache"]  = %w{ apache2-prefork-dev libapr1-dev libaprutil1-dev libcurl4-openssl-dev }
default["redmine"]["packages"]["rmagick"] = %w{ libmagickcore-dev libmagickwand-dev librmagick-ruby }
#TODO: SCM packages should be installed only if they are goin to be used
#NOTE: git will be installed with a recipe because is needed for the deploy resource
default["redmine"]["packages"]["scm"]     = %w{ subversion bzr mercurial darcs cvs }

# gems
default["redmine"]["gems"]["rake"]      = '0.9.2'
default["redmine"]["gems"]["rack"]      = '1.1.3'
default["redmine"]["gems"]["rails"]     = '2.3.14'
default["redmine"]["gems"]["mysql"]     = ''
default["redmine"]["gems"]["passenger"] = ''
default["redmine"]["gems"]["rmagick"]   = ''