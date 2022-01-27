# @summary Accepts parameters for downloadind and extracting files.
#
# == Definition: cloudfile::getfile
#
# Parameters:
#
# - *$pkg_uri: $package_uri
# - *$app_name: $applicarion
# - *$extract: default value true.
# - *$ensure: default value true.
# - *$cloud_type: default value std_http
# - *$access_key: optional param default undef
# - *$aws_region: optional param default is undef
#
#  cloudfile::getfile { 'mycloudapp.2.0.tar.gz':
#    app_name   => 'mycloudapp',
#    cloud_type => 'azure',
#    access_key => '<azure token key>'
#    pkg_uri    => 'http://clouduri/blob/distro/v2.0',
#  }
#
# Example usage:
#  cloudfile::getfile { 'mycloudapp.2.0.tar.gz':
#    app_name   => 'mycloudapp',
#    cloud_type => 'aws',
#    extract    => false,
#    pkg_uri    => 'http://clouduri/blob/distro/v2.0',
#    aws_region => 'eu-west2',
#  }
define cloudfile::getfile (

  String                    $pkg_uri      = $package_uri,
  String                    $app_name     = $application,
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

  $_extract_dir = "${temp_dir}/${app_name}"
  $_pkg_inst    = "${_extract_dir}/${title}"

  $_pkg_src_uri = $cloud_type ? {
    default   => "${pkg_uri}/${title}",
    'local_az' => "${pkg_uri}/${title}?${access_key}",
  }

  file { $_extract_dir:
    ensure => directory,
  }

  case $cloud_type {
    default: {
      archive { $_pkg_inst:
        ensure       => $ensure,
        extract      => $extract,
        source       => $_pkg_src_uri,
        extract_path => $_extract_dir,
        creates      => $_pkg_inst,
      }
    }

    local_s3: {

      $archive_params = $facts['kernel'] ? {
        'Linux' => { path        => "${_extract_dir}/awscli-bundle.zip",
                      source       => 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip',
                      extract      => true,
                      extract_path => '/opt',
                      creates      => '/opt/awscli-bundle/install',
                      cleanup      => true,
                    },
        'windows'   => { path             => "${_extract_dir}/awscliv2.msi",
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
          source          => 'C:/Windows/TEMP/invader/awscliv2.msi',
          install_options => [ '/qn'],
          require         => Archive['Get AWS CLI'],
          notify          => Exec[$_pkg_inst]
        }

      } else {

        exec { 'install_aws_cli':
          cwd     => '/opt/awscli-bundle',
          command => '/opt/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws',
          creates => '/usr/local/bin/aws',
          require => Archive['Get AWS CLI'],
          notify  => Exec[$_pkg_inst]
        }
      }

      $aws_options = '--no-sign-request'

      $aws_cmd = $facts['osfamily'] ? {
        default => '/usr/local/bin',
        windows => 'C:\\Program Files\\Amazon\\AWSCLIV2'
      }

      exec { $_pkg_inst:
        cwd       => $_extract_dir,
        command   => "aws s3 cp ${_pkg_src_uri} ${_extract_dir} ${aws_options}",
        path      => $aws_cmd,
        logoutput => true,
        creates   => $_pkg_inst,
      }

      $_extract = $extract

      if $_extract == 'true' {
        archive { $_pkg_inst:
          ensure       => $ensure,
          extract      => true,
          extract_path => $_extract_dir,
          require      => Exec[$_pkg_inst],
        }
      }
    }

    local_az: {
      archive { $_pkg_inst:
        ensure       => $ensure,
        extract      => $extract,
        source       => $_pkg_src_uri,
        extract_path => $_extract_dir,
        creates      => $_pkg_inst,
      }
    }
  }
}
