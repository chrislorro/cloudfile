# @summary Download archived packages from various locations and optionally ocal install
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
# @params install_package
#   Optinal parameter to install the package (this option will be enhanced in the next release)
# @params token
#   Optional parameter for passing a token to the package URL tested on AZ for now, 
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
  String             $application      = 'invader',
  String             $package_file     = 'invader.zip',
  String             $package_uri      = 's3://clawpupbuck',
  Boolean            $extract          = true,
  Enum[ 'local_az',
        'local_s3',
        'std_http' ] $cloud_type       = 'local_s3',
  Optional[String]   $package_name     = undef,
  Optional[String]   $token            = undef,
  Optional[String]   $aws_region       = 'eu-west-2',
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
