# @summary Download archived packages from various locations and optionally local install.
#
# A module to download application files from cloud filestores or http/https hosted packages,
# currently compatable with AWS and Azure cloud providers. Package installation features will
# be added in future releases, including running a template to install custom applications
# that cannot use the `package` resource type.
#
# @param application
#   The application name that is being installed, use the exact application
#   string for windows so that the package resource runs idempotent
#
# @param package_file
#   The package name that will be downloaded from cloud storage
#
# @param package_uri
#   The URL of the cloud storage where the package is stored
#
# @param extract
#   set this parameter to extract the package from an archive file,
#   it defaults to true because we expect a compressed file
#
# @param cloud_download
#   The cloud platform that is used to host the application package
#   Accepts 3 different parametes:
#   *- standard: standard download using http://URI https://URI 
#   *- aws_s3: Dowload using s3://URI and optional $install_options
#   *- secure: Download using a secure token, must be used exclusive with token parameter
#
# @param install_file
#   Optional parameter to install the package (this option will be enhanced in the next release)
#
# @param install_options
#   Optional parameter to pass installation options to the package installer
#
# @param token
#   Optional parameter for passing a token to the package URL tested on AZ for now, 
#    token is expected if IAM is configured on the platform
#
# @param aws_region
#   Optional parameter for the AWS region, if this is not set for,
#   windows agents the package uses a default deployed with the sdk
#
# @param installer
#   Optional paramter for executing install scripts on Linux only
#
# @example retrieve an application call invader from s3 storage to linux
#   class { 'cloudfile':
#     application    => 'invader',
#     package_file   => 'invader.tar.gz',
#     package_uri    => 's3://chrislorro',
#     extract        => true,
#     cloud_download => aws_s3,
#     aws_region     => eu-west-2,
#   }
#
# @example retrieve an application call invader from s3 storage and install the application
#   class { 'cloudfile': 
#     application     => 'mcafee',
#     package_file    => 'McAfee.zip',
#     package_uri     => 'https://chrislorro.blob.core.windows.net/puppet,
#     extract         => true,
#     cloud_download  => 'secure',
#     install_package => true,
#     token           => 'sp=rwd&st=2022-01-27T11:46[…]sig=2ytxxRcpND1Khs4UgUL1tfMxOwHsZMMit'
#     install_file    => McAfee.exe,
#     install_options => [ '/SILENT', '/INSTALL=AGENT']
#   }
class cloudfile (
  String             $application     = undef,
  String             $package_file    = undef,
  String             $package_uri     = undef,
  Boolean            $extract         = true,
  Boolean            $install_package = false,
  Enum[ 'standard',
        'aws_s3',
        'secure' ]   $cloud_download  = undef,
  Optional[String]   $package_name    = undef,
  Optional[String]   $token           = undef,
  Optional[String]   $aws_region      = undef,
  Optional[String]   $install_file    = undef,
  Optional[Array]    $install_options = undef,

) {

  $temp_dir = $facts['kernel'] ? {
    default   => '/var/tmp',
    'windows' => 'C:/Windows/TEMP'
  }

  include archive

  cloudfile::getfile { $package_file:
    package_uri => $package_uri,
    application => $application,
    extract     => $extract,
    access_key  => $token,
    cloud_type  => $cloud_download,
    aws_region  => $aws_region,
  }

  if $install_package {

  if ! $application {
    fail('required $application not passed')
  }

  $installer = "${temp_dir}/${application}/${$install_file}"

    case $facts['kernel'] {
      'windows': {
        package { $application:
          ensure          => 'installed',
          source          => $installer,
          install_options => $install_options,
          require         => Cloudfile::Getfile[$package_file]
        }
      }
      'Linux': {

        if !defined($installer) {
          fail('required $installer not passed')
        }

        $_install_command = "${temp_dir}/${application}/${install_file} ${install_options}"
        exec { $application:
          command     =>  $_install_command,
          refreshonly => true,
          path        => $_install_command,
          timeout     => '300',
          require     => Cloudfile::Getfile[$package_file]
        }
      }
      default: {}
    }
  }
}
