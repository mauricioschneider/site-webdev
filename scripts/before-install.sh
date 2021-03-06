#!/usr/bin/env bash

set -e -o pipefail

[[ -z "$NGIO_ENV_DEFS" ]] && . ./scripts/env-set.sh

if [[ -n "$TRAVIS" ]]; then
  ./scripts/env-info-and-check.sh

  travis_fold start before_install.update_apt_get
    (set -x; sudo apt-get update --yes)
  travis_fold end before_install.update_apt_get
fi

# Needed for Jekyll
travis_fold start before_install.ruby
  (set -x; [[ -z "$TRAVIS" ]] || rvm get stable; rvm install 2.3)
travis_fold end before_install.ruby

./scripts/install-dart-sdk.sh

travis_fold start before_install.npm_install
  (set -x; npm install -g firebase-tools gulp superstatic --no-optional)
travis_fold end before_install.npm_install

travis_fold start before_install.linkcheck
  (set -x; pub global activate linkcheck)
travis_fold end before_install.linkcheck

travis_fold start before_install.stagehand
  (set -x; pub global activate stagehand)
travis_fold end before_install.stagehand

travis_fold start before_install.dartdoc
  (set -x; pub global activate dartdoc)
travis_fold end before_install.dartdoc

# Setup required for use of content_shell:
if [[ -n $TRAVIS && $CI_TASK != build* ]]; then
  travis_fold start before_install.content_shell_prereq
    set -x
    sudo sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"
    sudo apt-get install --yes ttf-indic-fonts ttf-mscorefonts-installer ttf-dejavu-core ttf-kochi-gothic ttf-kochi-mincho fonts-tlwg-garuda
    # ttf-thai-tlwg # Package 'ttf-thai-tlwg' has no installation candidate
    set +x
  travis_fold end before_install.content_shell_prereq
fi

./scripts/get-ng-repo.sh
