# Class: cacti
#
# This module manages cacti
# http://www.cacti.net/
#
# Requires:
#   class apache::php
#   class generic
#   class mysql::server
#   class pam
#
class cacti {

    include apache::php
    include generic
    include mysql::server
    include pam

    package {
        "cacti":
            require => Package["net-snmp-utils"];
        "net-snmp-utils":;
    } # package

    # allow the cacti user to run cron jobs
    pam::accesslogin { "cacti": }

    file {
        "/etc/cacti/db.php":
            source  => "puppet:///modules/cacti/db.php",
            require => [ Package["cacti"], Package["httpd"] ],
            owner   => "cacti",
            group   => "apache",
            mode    => 640;
        "/etc/cron.d/cacti":
            content => "*/5 * * * *    cacti   /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1\n",
            require => Package["cacti"];
    } # file

    # setup database 
    mysql::do { "cacti_db_setup":
        source  => "puppet:///modules/cacti/cacti.sql",
    } # mysql::do

} # class cacti
