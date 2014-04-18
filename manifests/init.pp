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
  $solr_data_dir          = '/data/solr',
  $tomcat_webapps_dir     = '/opt/tomcat/webapps',
  $solr_download_location = 'http://apache.mirror.1000mbps.com/lucene/solr',
){
 
  $path = ['/usr/bin', '/usr/sbin','/bin','/sbin']

  ensure_packages(['tomcat7','openjdk-7-jdk','wget'])

  common::directory_structure{$solr_data_dir:
    user    => 'tomcat7',
    require => Package['tomcat7'],
  }

  common::directory_structure{$tomcat_webapps_dir:
    user    => 'tomcat7',
    require => Package['tomcat7'],
  }

  common::download_extract{"solr-${solr_version}.tgz":
    link        => "${solr_download_location}/${solr_version}/solr-${solr_version}.tgz",
    extract_dir => $solr_data_dir,
    creates     => "${solr_data_dir}/solr-${solr_version}",
    require     => Common::Directory_structure[$solr_data_dir],
  }

  exec{'copy solr lib to tomcat':
    command => "cp -fr ${solr_data_dir}/solr-${solr_version}/example/lib/* /usr/share/tomcat7/lib",
    path    => $path,
    require => [
      Common::Download_extract["solr-${solr_version}.tgz"],
      Package['tomcat7']
    ],
    unless  => "/usr/bin/test -e /usr/share/tomcat7/lib/servlet-api-3.0.jar",
    notify  => Service['tomcat7']
  }

  service{'tomcat7':
    ensure  => 'running',
    require => Package['tomcat7']
  }

  file {"${tomcat_webapps_dir}/solr":
    ensure  => 'directory',
    require => Common::Directory_structure[$tomcat_webapps_dir],
  }

  exec { 'extract solr war file':
    command => "jar -xvf ${solr_data_dir}/solr-${solr_version}/dist/solr-${solr_version}.war",
    cwd     => "${tomcat_webapps_dir}/solr",
    path    => $path,
    require => [
      Package['openjdk-7-jdk'],
      File["${tomcat_webapps_dir}/solr"]
    ],
    notify  => Service['tomcat7']
  }

}
