m4_define(m4_author, `Paul Huygen')m4_dnl
m4_define(m4_docname, `my_wpdocker')m4_dnl
m4_define(m4_doctitle, `My Wordpress-Docker')m4_dnl
m4_changequote(`<!',`!>')m4_dnl
m4_dnl
m4_define(m4_long_ubuntuversion, <!14.04.5 LTS, Trusty Tahr!>)m4_dnl
m4_define(m4_docker_template, <!ubuntu:14.04!>)m4_dnl
m4_define(m4_docker_image, <!ubuntu_docker!>)m4_dnl
m4_define(m4_expose_port, <!80!>)m4_dnl
m4_dnl
m4_dnl backup resources
m4_dnl
m4_define(m4_backup_host, <!paulhuygen.hopto.org!>)
m4_define(m4_backup_user, <!pi!>)
m4_define(m4_remote_location, <!/srv/dev-disk-by-uuid-0AF2C3FFF2C3ECCF/bu_paul/cltl_nl/image!>)
m4_define(m4_backup_mountpoint, <!/home/paul/mnt/b2l!>)m4_dnl
m4_define(m4_local_b2l_repo, <!/backup!>)m4_dnl
m4_define(m4_host_b2l_repo, <!/home/paul/mnt/b2l!>)m4_dnl
m4_define(m4_bak_config_file, <!cltl_bak.conf!>)m4_dnl
m4_dnl
m4_dnl mysql resources
m4_dnl
m4_define(m4_db_dumpfile, <!wordpress_db.sql!>)m4_dnl
