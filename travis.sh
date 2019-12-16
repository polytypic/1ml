#!/bin/bash -e

if [ "$TRAVIS" = true ]; then
  folded() {
    FOLD=$((FOLD+1))
    echo -e "travis_fold:start:cppsm.$FOLD\033[33;1m$1\033[0m"
    travis_time_start
    shift
    echo "$@"
    "$@"
    travis_time_finish
    echo -e "\ntravis_fold:end:cppsm.$FOLD\r"
  }

  if [ "$TRAVIS_OS_NAME" = osx ]; then
    folded "Installing Ocaml" brew install ocaml
  fi
else
  folded() {
    echo
    echo "RUNNING: $1"
    shift
    "$@"
  }
fi

folded "Build 1ML" make

for f in *.1ml; do
  folded "$f" ./1ml -c prelude.1ml "$f"
done
