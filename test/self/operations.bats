load "/opt/bats-support/load.bash"
load "/opt/bats-assert/load.bash"

@test "SITE_SPIN_VERSION environment variable is set" {
  [ -n "${SITE_SPIN_VERSION}" ]
}
@test "running under the expected cpu architecture" {
  run uname -m
  echo "output: $output"
  assert_line --partial "x86_64"
  assert_equal "$status" 0
}
@test "ssh client is installed" {
  run ssh
  echo "output: $output"
  assert_line --partial "usage: ssh"
  assert_equal "$status" 255
}
@test "curl is installed" {
  run curl --version
  echo "output: $output"
  assert_line --partial "curl"
  assert_equal "$status" 0
}
@test "git is installed" {
  run git --version
  echo "output: $output"
  assert_output --partial "git version"
  assert_equal "$status" 0
}
@test "AWS CLI runs" {
  run aws --version
  echo "output: $output"
  assert_equal "$status" 0
}
@test "jekyll runs" {
  run jekyll --version
  echo "output: $output"
  assert_equal "$status" 0
}
@test "site-spin command runs" {
  run site-spin help
  echo "output: $output"
  assert_equal "$status" 0
}
