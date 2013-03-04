class squid::params {
  $localnet_src = '10.0.0.0/8'
  $http_port = 3128
  $cache_mem = '256 MB'
  $maximum_object_size_in_memory = '512 KB'
  $memory_replacement_policy = 'lru'
  $cache_replacement_policy = 'lru'
  $cache_dir_type = 'ufs'
  $cache_dir_size = 1000
  $maximum_object_size = '4096 MB'
  $cache_swap_low = 90
  $cache_swap_high = 95
  $log_fqdn = off
  $cachemgr_passwd = disable
  $visible_hostname = undef
  $snmp_port = undef
  $adzapper = false

  case $operatingsystem {
    centos, redhat: {
      $package = 'squid'
      $service = 'squid'
      $user = 'squid'
      $group = 'squid'
    }
    ubuntu, debian: {
      $package = 'squid3'
      $service = 'squid3'
      $user = 'proxy'
      $group = 'proxy'
    }
  }

  $cache_dir = "/var/spool/${package}"
  $log_dir = "/var/log/${package}"
  $config_file = "/etc/${package}/squid.conf"

}

# vim: set ts=2 sw=2 sts=2 tw=0 et:
