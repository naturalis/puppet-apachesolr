# == Class: apachesolr
#
# Full description of class apachesolr here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { apachesolr:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class apachesolr (
  $solr_version           = '4.7.2',
  $solr_download_location = 'http://apache.mirror.1000mbps.com/lucene/solr',
){
 
  $path = ['/usr/bin', '/usr/sbin','/bin','/sbin']

  ::ensure_package{['tomcat7','openjdk-7-jre','wget']:}
  #::ensure_package{'wget':}
  exec{'download solr':
    command => "wget ${solr_download_location}/${solr_version}/solr-${solr_version}.tgz -O /tmp/solr-${solr_version}",
    unless  => "test -f /tmp/solr-${solr_version}",
    path    => $path,
    require => Package['wget'],
  }


  


  



  define ensure_package(){
    if !defined(Package[$name]) {
      package{ $name :
        ensure => 'latest',
      }
    }
  }

}
