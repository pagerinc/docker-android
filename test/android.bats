#!/usr/bin/env bats

@test "It should use java v1.8.0_131" {
  docker run --rm pagerinc/android java -version | grep 1.8.0_131
}

@test "It should use Node v6.10.3" {
  docker run --rm pagerinc/android node -v | grep 6.10.3
}

@test "It should use npm v5.0.1" {
  docker run --rm pagerinc/android npm -v | grep 5.0.1
}

@test "It should use cordova v7.0.1" {
  docker run --rm pagerinc/android cordova -v | grep 7.0.1
}

