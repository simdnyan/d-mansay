#!/bin/sh

case $1 in
  "say") d-mansay ${@:4};;
  "think") d-manthink ${@:6};;
esac

