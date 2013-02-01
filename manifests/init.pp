class squid(
  $localnet_src = $squid::params::localnet_src,
  $http_port = $squid::params::http_port,
  $cache_mem = $squid::params::cache_mem,
  $maximum_object_size_in_memory = $squid::params::maximum_object_size_in_memory,
  $memory_replacement_policy = $squid::params::memory_replacement_policy,
  $cache_replacement_policy = $squid::params::cache_replacement_policy,
  $cache_dir = $squid::params::cache_dir,
  $cache_dir_type = $squid::params::cache_dir_type,
  $cache_dir_size = $squid::params::cache_dir_size,
  $maximum_object_size = $squid::params::maximum_object_size,
  $cache_swap_low = $squid::params::cache_swap_low,
  $cache_swap_high = $squid::params::cache_swap_high,
  $log_fqdn = $squid::params::log_fqdn,
  $cachemgr_passwd = $squid::params::cachemgr_passwd,
  $visible_hostname = $squid::params::visible_hostname,
  $snmp_port = $squid::params::snmp_port,
  $adzapper = $squid::params::adzapper,
  $user = $squid::params::user,
  $group = $squid::params::group,
  $package_present = 'present',
) inherits squid::params {

  $package = $squid::params::package
  $service = $squid::params::service
  $config_file = "/etc/${package}/squid.conf"

  package { $package:
    ensure  => $package_present,
  }

  if $adzapper {
    package { 'adzapper':
      ensure  => $package_present,
      require => Package[$package],
    }
  }

  # Handle aclParseIpData: Bad host/IP: '::1'
  # See https://github.com/dezwart/puppet-squid/pull/4
  if $::lsbdistid == 'Ubuntu' and $::lsbmajdistrelease <= 10 {
    $ipv6 = false
  } else {
    $ipv6 = true
  }

  # create config file
  file { $config_file:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("squid/etc/squid3/squid.conf.erb"),
    require => Package[$package],
  }

  # create the user to own the proxy
  user { "${user}":
    ensure => present,
    shell  => "/sbin/nologin",
  }->
  group { "${group}":
    ensure => present,
  }->

  # create the directory for storing the cached data/packages
  file { $cache_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => Package[$package],
  }

  # restart service to use cache dir
  exec { 'Init cache dir':
    path    => '/sbin:/usr/sbin',
    command => "service ${service} stop && /usr/sbin/${service} -z",
    creates => "${cache_dir}/00",
    notify  => Service[$service],
    require => [ File[$cache_dir], File[$config_file] ],
  }

  # setup the service properly
  service { $service:
    ensure    => running,
    enable    => true,
    require   => Package[$package],
    restart   => "/etc/init.d/${service} reload",
    subscribe => File[$config_file],
  }

  firewall { '03129 Squid Caching Service':
    action => 'accept',
    proto  => ['udp','tcp'],
    dport  => $http_port,
    notify  => Exec['persist-firewall'],
    before  => Class['docommon::firewall::post'],
    require => Class['docommon::firewall::pre'],
  }
}

# vim: set ts=2 sw=2 sts=2 tw=0 et:
