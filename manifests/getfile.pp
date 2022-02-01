# @summary Accepts parameters for downloadind and extracting files.
#
# == Definition: cloudfile::getfile
#
# Parameters:
# @param package_uri
#   $package_uri: $package_uri
#
# @param $application
#   $application: $application
#
# @param $extract
#   $extract: default value true.
#
# @param $ensure
#   $ensure: default value true.
#
# @param $cloud_type
#   $cloud_type: default value standard
#
# @param $access_key
#   $access_key: optional param default undef
#
# @param $aws_region
#   $aws_region: optional param default is undef
#
#  cloudfile::getfile { 'mycloudapp.2.0.tar.gz':
#    application => 'mycloudapp',
#    cloud_type  => 'azure',
#    access_key  => '<azure token key>'
#    package_uri => 'http://clouduri/blob/distro/v2.0',
#  }
#
# Example usage AWS windows installation:
#  cloudfile::getfile { 'putty-64bit-0.76-installer.msi.zip':
#    application => 'PuTTY release 0.76 (64-bit)',
#    cloud_download => 'aws_s3',
#    extract        => true,
#    package_uri    => 's3://chrislorro',
#    aws_region     => 'eu-west2',
#  }
define cloudfile::getfile (

  String                    $package_uri  = $package_uri,
  String                    $application  = $application,
  Boolean                   $extract      = true,
  Enum['present', 'absent'] $ensure       = present,
  String                    $cloud_type   = undef,
  Optional[String]          $access_key   = undef,
  Optional[String]          $aws_region   = $aws_region,

) {

  $temp_dir = $facts['kernel'] ? {
    default   => '/var/tmp',
    'windows' => 'C:/Windows/TEMP'
  }

  $_extract_dir = "${temp_dir}/${application}"
  $_pkg_inst    = "${_extract_dir}/${title}"

  $_pkg_src_uri = $cloud_type ? {
    default   => "${package_uri}/${title}",
    'secure' => "${package_uri}/${title}?${access_key}",
  }

  file { $_extract_dir:
    ensure => directory,
  }


  $archive_params = $facts['kernel'] ? {
    'Linux' => { path        => "${temp_dir}/awscli-bundle.zip",
                  source       => 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip',
                  extract      => true,
                  extract_path => '/opt',
                  creates      => '/opt/awscli-bundle/install',
                  cleanup      => true,
                },
    'windows'   => { path             => "${temp_dir}/awscliv2.msi",
                  source           => 'https://awscli.amazonaws.com/AWSCLIV2.msi',
                  creates          => 'C:/Program Files/Amazon/AWSCLIV2',
                  download_options => ['--region', $aws_region],
                }
  }

  archive { 'Get AWS CLI':
    ensure => present,
    *      => $archive_params,
  }

  if $facts['osfamily'] == 'windows' {

    package { 'AWS Command Line Interface v2':
      ensure          => 'installed',
      source          => 'C:/Windows/TEMP/awscliv2.msi',
      install_options => [ '/qn'],
      require         => Archive['Get AWS CLI'],
      notify          => Archive[$_pkg_inst]
    }

  } else {

    class { 'archive':
      aws_cli_install => true,
      require         => Archive['Get AWS CLI'],
      notify          => Archive[$_pkg_inst]
    }

    file { '/root/.aws':
      ensure => directory,
      mode   => '0755',
      owner  => root,
      before => Class['archive'],
    }

    file { '/root/.aws/config':
      ensure  => file,
      mode    => '0640',
      owner   => root,
      content => epp('cloudfile/awsconfig.epp'),
    }
  }

#    exec { 'install_aws_cli':
#      cwd     => '/opt/awscli-bundle',
#      command => '/opt/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws',
#      creates => '/usr/local/bin/aws',
#      require => Archive['Get AWS CLI'],
#      notify  => Archive[$_pkg_inst]
#    }
#  }

  $download_options = $cloud_type ? {
    aws_s3 => ['--region', $aws_region, '--no-sign-request'],
    default  => undef,
  }

  archive { $_pkg_inst:
    ensure           => $ensure,
    extract          => $extract,
    source           => $_pkg_src_uri,
    extract_path     => $_extract_dir,
    creates          => $_pkg_inst,
    cleanup          => false,
    download_options => $download_options,
  }
}
