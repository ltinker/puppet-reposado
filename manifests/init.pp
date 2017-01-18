# == Class: reposado
#
# Base class to set up a Reposado service.
#
# === Authors
#
# Gerard Kok
#
# === Copyright
#
# Copyright 2015 Gerard Kok.
#
class reposado (
  $user                    = $::reposado::params::user,
  $group                   = $::reposado::params::group,
  $base_dir                = $::reposado::params::base_dir,
  $git_source              = $::reposado::params::git_source,
  $git_ensure              = $::reposado::params::git_ensure,
  $git_revision            = undef,
  $cronjob_time            = $::reposado::params::cronjob_time,
  $cronjob_command         = $::reposado::params::cronjob_command,
  $server_name             = $::reposado::params::server_name,
  $manage_user             = true,
  $manage_group            = true,
  $manage_git              = false,
  $manage_cronjob          = true,
  $apple_catalogs          = [],
  $additional_curl_options = [],
  $preferred_localizations = [],
  $curl_path               = undef,
  $local_catalog_url_base  = "http://${server_name}",
  $reposado_root           = $::reposado::params::reposado_root,
  $metadata_dir            = "${base_dir}/metadata",
  $document_root           = "${base_dir}/html",
  $repo_sync_log_file      = undef) inherits ::reposado::params {
  $catalog_urls            = catalog_urls($apple_catalogs)

  if $manage_group {
    group { $group: ensure => 'present'; }
  }

  if $manage_user {
    user { $user:
      ensure => 'present',
      shell  => '/bin/bash',
      home   => $base_dir,
      gid    => $group;
    }
  }

  if $manage_git {
    package { 'git': ensure => 'present'; }
  }

  if $manage_cronjob {
    $cronjob_time_as_array = split($cronjob_time, ':')
    $cronjob_hour = $cronjob_time_as_array[0]
    $cronjob_minute = $cronjob_time_as_array[1]

    cron { 'repo_sync':
      command => $cronjob_command,
      user    => $user,
      hour    => $cronjob_hour,
      minute  => $cronjob_minute;
    }
  }

  vcsrepo { $reposado_root:
    ensure   => $git_ensure,
    owner    => $user,
    group    => $group,
    provider => 'git',
    require  => [User[$user], Group[$group]],
    source   => $git_source,
    revision => $git_revision;
  }

  file {
    [
      $base_dir,
      $metadata_dir]:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0755';

    "${reposado_root}/code/preferences.plist":
      ensure  => 'present',
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => template('reposado/preferences.plist.erb'),
      require => Vcsrepo[$reposado_root];

    $document_root:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0775';
  }
