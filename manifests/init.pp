# @summary Download archived packages from various locations to prepare for local installation
#
# A module to download application files from cloud filestores or http/https hosted packages,
# currently compatable with AWS and Azure cloud providers
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
# @params az_token
#   Optional parameter for retreive Azure filestore packages, 
#    token is expected if IAM is configured on the platform
#
# @params aws_region
#   Optional parameter for the AWS region, if this is not set for,
#   windows agents the package uses a default deployed with the sdk
#
# @example retrieve an application call invader from s3 storage
#   class cloudfile::getfile {
#     app_name     => 'invader',
#     package_file => 'invader.tar.gz',
#     package_uri  => 's3://chrislaw',
#     extract      => true,
#     cloud_type   => local_s3,
#     aws_region   => undef,
#   }
#
class cloudfile (
  String              $application  = undef,
  String              $package_file = undef,
  String              $package_uri  = undef,
  Boolean             $extract      = true,
  Enum[ 'local_az',
        'local_s3',
        'std_http' ]  $cloud_type   = std_http,
  Optional[String]    $token        = undef,
  Optional[String]    $aws_region   = undef,
) {

  include archive

  cloudfile::getfile { $package_file:
    pkg_uri    => $package_uri,
    app_name   => $application,
    extract    => $extract,
    access_key => $token,
    cloud_type => $cloud_type,
    aws_region => $aws_region,
  }
}
