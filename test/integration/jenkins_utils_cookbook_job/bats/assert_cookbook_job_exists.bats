@test "cookbook job exists" {
  xmllint /var/lib/jenkins/jobs/chef-openssh/config.xml
}
