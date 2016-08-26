class reposado::margarita {
  $user                     = $::reposado::params::user
  $group                    = $::reposado::params::group
  $server_name              = $::reposado::params::server_name
  $git_ensure               = $::reposado::params::git_ensure
  $margarita_git_revision   = $::reposado::params::margarita_git_revision
  $margarita_root           = "${::reposado::params::base_dir}/margarita"
  $manage_margarita_service = true
  $margarita_git_source     = $::reposado::params::margarita_git_source
  $manage_flask             = true
  $manage_simplejson        = true
  $preferences_link         = "${margarita_root}/preferences.plist"
  $reposadolib_link         = "${margarita_root}/reposadolib"
  $reposado_root            = $::reposado::params::reposado_root


  vcsrepo { $margarita_root:
    ensure   => $git_ensure,
    owner    => $user,
    group    => $group,
    provider => 'git',
    require  => [[User[$user], Group[$group]],
    source   => $margarita_git_source,
    revision => $git_revision;

    }->
    file {
      [$margarita_root]:
        ensure => 'directory',
        owner  => $user,
        group  => $group,
        mode   => '0755';

      "$reposadolib_link":
        ensure  => 'link',
        owner   => $user,
        group   => $group,
        target  => "${reposado_root}/code/reposadolib",
        require => Vcsrepo[$reposado_root];
      "$preferences_link":
        ensure  => 'link',
        owner   => $user,
        group   => $group,
        target  => "${reposado_root}/code/preferences.plist",
        require => File["${reposado_root}/code/preferences.plist"];
    }
  if $manage_margarita_service{
    if $facts['initservice'] == 'initd'{
        $system_services = '/etc/init.d'
        file{"${system_services}/margarita":
          ensure  => 'present',
          owner   => $user,
          group   => $group,
          mode    => '0755',
          content => template('reposado/margarita.initd.erb'),
          require => Vcsrepo[$margarita_root];
        }
    }
  }
    elsif $facts['initservice'] == 'systemd'{
        $system_services = '/etc/systemd/system'
        file{"${system_services}/margarita.service":
          ensure  => 'present',
          owner   => $user,
          group   => $group,
          mode    => '0755',
          content => template('reposado/margarita.systemd.erb'),
          require => Vcsrepo[$margarita_root];
          }
    }
    else {
      warning("The ${module_name} Module does not support management of margarita as a service on ${::osfamily}")
    }


if $manage_flask {
  package { 'flask':
    ensure   => 'present',
    provider => 'pip'; }
}
if $manage_simplejson {
  package { 'simplejson':
    ensure   => 'present',
    provider => 'pip'; }
}
}
