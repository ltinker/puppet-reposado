class reposado::params {
  $user = 'reposado'
  $group = 'reposado'
  $base_dir = '/srv/reposado'
  $cronjob_time = '0:30'
  $cronjob_command = '/srv/reposado/reposado/code/repo_sync'
  $server_name = "${::hostname}.${::domain}"
  $git_source = 'https://github.com/wdas/reposado'
  $git_ensure = 'present'
  $margarita_git_source = 'https://github.com/jessepeterson/margarita.git'
  $margarita_git_revision = undef
  $reposado_root = "${base_dir}/reposado"
}

case $::osfamily {
    'Debian': {
      $system_services          = '/etc/init.d'

    }
    'RedHat': {
      $system_services             = '/etc/init.d'

    }
    'Ubuntu': {
      $system_services             = '/etc/init.d'

    }

    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
