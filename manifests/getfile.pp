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
  Optional[String]          $username     = Administrator,
  Optional[String]          $aws_region   = $aws_region,

) {

