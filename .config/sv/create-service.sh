#!/bin/sh
mkdir "$1" && kak "$1/run" && chmod +x "$1/run"
