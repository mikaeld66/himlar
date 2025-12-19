#
class profile::logging::fluent-bit(
  $manage_fluent-bit  = false,
  $package_name       = 'fluent-bit',
  $service_name       = 'fluent-bit',
  $manage_service     = true,
  $config_dir         = '/etc/fluent-bit',
  $config_file        = 'fluent-bit.conf',
  $config_file_parser = 'uio-parsers.conf',
  $config_file_dns    = 'UIO_input_tail-dns-bind9-hostmaster.conf',
  $config_file_filter = 'UIO_filter-sysinfo-all.conf_enable',
  $config_file_output = 'UIO_PROD_output-dataops-http-receiver-5000-uio-logs.conf',
) {


  if $manage_fluent-bit  {

    profile::base::yumrepo::repo_hash::fluent-bit::ensure = 'present'

    if $manage_service {
      service { $service_name:
        ensure  => running,
        require => Package[$package_name]
      }
    }

    if $package_name {
      package { $package_name:
        ensure => installed,
      }
    }

    file { '/var/log/fluent-bit' :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { '/var/lib/fluent-bit' :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file { '/var/lib/fluent-bit/storage' :
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { "$config_dir/$config_file" :
      ensure => 'file',
      source => "puppet:///modules/${module_name}/logging/fluent-bit/${config_file}"
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service["$service_name"],
    }
    file { "$config_dir/$config_file_parser" :
      ensure => 'file',
      source => "puppet:///modules/${module_name}/logging/fluent-bit/${config_file_parser}"
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      notify => Service["$service_name"],
    }

    file { "$config_dir/fluent-bit.conf.d" :
      ensure => 'directory',
      source => "puppet:///modules/${module_name}/logging/fluent-bit/fluent-bit.conf.d",
      recurse=> true,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      notify => Service["$service_name"],
    }
    file { "${config_dir}/fluent-bit.conf.d/${config_file_dns}_enable" :
      ensure => 'link',
      target => "$config_file_dns",
      notify => Service["$service_name"],
    }
    file { "${config_dir}/fluent-bit.conf.d/${config_file_filter}_enable" :
      ensure => 'link',
      target => "$config_file_filter",
      notify => Service["$service_name"],
    }
    file { "${config_dir}/fluent-bit.conf.d/${config_file_output}_enable" :
      ensure => 'link',
      target => "$config_file_output",
      notify => Service["$service_name"],
    }
  }

}
