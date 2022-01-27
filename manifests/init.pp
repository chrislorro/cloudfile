# @summary Download archived packages from various locations and optionally local install.
#
# A module to download application files from cloud filestores or http/https hosted packages,
# currently compatable with AWS and Azure cloud providers. Package installation features will
# be added in future releases, including running a template to install custom applications
# that cannot use the `package` resource type.
#
# @param application
#   The application name that is being installed
#
# @param package_file
#   The package name that will be downloaded from cloud storage
#
# @params package_uri
#   The URL of the cloud storage where the package is stored
#
# @params extract
#   set this parameter to extract the package from an archive file,
#   it defaults to true because we expect a compressed file
#
# @params cloud_type
#   The cloud platform that is used to host the application package
#
# @params install_package
#   Optional parameter to install the package (this option will be enhanced in the next release)
#
# @params install_options
#   Optional parameter to pass installation options to the package installer
# @params token
#   Optional parameter for passing a token to the package URL tested on AZ for now, 
#    token is expected if IAM is configured on the platform
#
# @params aws_region
#   Optional parameter for the AWS region, if this is not set for,
#   windows agents the package uses a default deployed with the sdk
#
# @example retrieve an application call invader from s3 storage to linux
#   class cloudfile {
#     app_name     => 'invader',
#     package_file => 'invader.tar.gz',
#     package_uri  => 's3://chrislorro',
#     extract      => true,
#     cloud_type   => local_s3,
#     aws_region   => eu-west-2,
#   }
#
# @example retrieve an application call invader from s3 storage and install the application
#   class cloudfile {
#     app_name        => 'mcafee',
#     package_file    => 'McAfee.zip',
#     package_uri     => 'https://chrislorro.blob.core.windows.net/puppet,
#     extract         => true,
#     cloud_type      => local_az,
#     token           => 'sp=rwd&st=2022-01-27T11:46[…]sig=2ytxxRcpND1Khs4UgUL1tfMxOwHsZMMit'
#     package_name    => McAfee.exe,
#     install_options => [ '/SILENT', '/INSTALL=AGENT']
#   }
class cloudfile (
  String             $application     = undef,
  String             $package_file    = undef,
  String             $package_uri     = undef,
  Boolean            $extract         = true,
  Enum[ 'local_az',
        'local_s3',
        'std_http' ] $cloud_type      = undef,
  Optional[String]   $package_name    = undef,
  Optional[String]   $token           = undef,
  Optional[String]   $aws_region      = undef,
  Optional[Array]    $install_options = undef,

) {

  $temp_dir = $facts['kernel'] ? {
    default   => '/var/tmp',
    'windows' => 'C:/Windows/TEMP'
  }

  $install_dir = "${temp_dir}/${application}${$package_name}"

  include archive

  cloudfile::getfile { $package_file:
    pkg_uri    => $package_uri,
    app_name   => $application,
    extract    => $extract,
    access_key => $token,
    cloud_type => $cloud_type,
    aws_region => $aws_region,
  }

  if $package_name {
    package { $package_name:
      ensure          => 'installed',
      source          => $install_dir,
      install_options => $install_options,
      require         => Cloudfile::Getfile[$package_file]
    }
  }
}
