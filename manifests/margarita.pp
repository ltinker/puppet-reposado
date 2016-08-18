class reposado::margarita (
  $user                    = $::reposado::params::user,
  $group                   = $::reposado::params::group,
  $server_name             = $::reposado::params::server_name,
  $git_ensure              = $::reposado::params::git_ensure,
  $git_revision            = $::reposado::params::service_dir,
  $margarita_root          = "${::reposado::params::base_dir}/margarita",
  $margarita_git_source    = $::reposado::params::margarita_git_source,
  $margarita_git_revision  = $::reposado::params::margarita_git_revision,
  $manage_flask            = true,
  $manage_margarita        = true,
  $manage_simplejson       = true,
  $preferences_link        = "${margarita_root}/preferences.plist",
  $reposadolib_link        = "${margarita_root}/reposadolib",
  $reposado_root           = $::reposado::params::reposado_root,
  $system_services         = $::reposado::params::system_services,


  {
    if $manage_margarita {

  vcsrepo { $margarita_root:
    ensure   => $git_ensure,
    owner    => $user,
    group    => $group,
    provider => 'git',
    require  => [User[$user], Group[$group]],
    source   => $margarita_git_source,
    revision => $git_revision,
    require => Directory[$margarita_root];
    }
    file {
      [$margarita_root]:
        ensure => 'directory',
        owner  => $user,
        group  => $group,
        mode   => '0755';

      "${system_services}/margarita":
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0755',
        content => template('reposado/margarita.initd.erb'),
        require => Vcsrepo[$margarita_root];

      "$reposadolib_link":
        ensure  => 'link',
        target  => "${reposado_root}/code/reposadolib",
        require => Vcsrepo[$reposado_root];
      "$preferences_link":
        ensure  => 'link',
        target  => "${reposado_root}/code/preferences.plist",
        require => File["${reposado_root}/code/preferences.plist"];
    }
  }

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
