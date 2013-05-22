class squid::firewall (

  $http_port = 3128,

) {

  @firewall { "0${http_port} Squid Caching Service TCP":
    protocol => 'tcp',
    port     => $http_port,
  }
  @firewall { "0${http_port} Squid Caching Service UDP":
    protocol => 'udp',
    port     => $http_port,
  }

}
