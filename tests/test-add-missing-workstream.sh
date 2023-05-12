#!/bin/bash
# Copyright 2023      Red Hat, Inc
echo -n "add_missing_workstream without $XDG_CONFIG_HOME/jira-osp/config... "
XDG_CONFIG_HOME=/path/to/nowhere bin/add-missing-workstream -n >/dev/null
test "$?" -eq "1" || { echo "KO"; exit 1; }
echo "OK"

echo -n "add_missing_workstream with neither $XDG_CONFIG_HOME nor $HOME... "
XDG_CONFIG_HOME='' HOME='' bin/add-missing-workstream -n >/dev/null
test "$?" -eq "1" || { echo "KO"; exit 1; }
echo "OK"

echo -n "add_missing_workstream --help with neither $XDG_CONFIG_HOME nor $HOME... "
XDG_CONFIG_HOME='' HOME='' bin/add-missing-workstream -h >/dev/null
test "$?" -eq "0" || { echo "KO"; exit 1; }
echo "OK"

exit 0
