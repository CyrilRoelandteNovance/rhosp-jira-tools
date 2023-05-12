# jira-osp

A collection of scripts to automate common operations in Jira for the Red Hat
OpenStack Storage team.

## Installation
Scripts can either be run from the bin/ directory or be installed on your
system:

```console
$ PREFIX=/path/to/prefix make install
```

They will then be available in /path/to/prefix/bin/.

Uninstalling is just as easy:

```console
$ PREFIX=/path/to/prefix make uninstall
```

## Common requirements

### Configuration
All scripts require a valid JIRA auth token. This token should be available in
$XDG_CONFIG_HOME/jira-osp/config:

```console
$ cat $XDG_CONFIG_HOME/jira-osp/config
[auth]
token=<secret-token>
```

### Environment variables
All scripts expect the $XDG_CONFIG_HOME variable to be set. If it is not set,
it will default to $HOME/.config. If $HOME is not set, all scripts will give
up.

### Software
The following pieces of software are required for all scripts:

* [jq](https://stedolan.github.io/jq/)
* [curl](https://curl.se/)

## Scripts
### add-missing-workstream
Stories should have a "workstream" set. This script goes through all epics for
a given project (Ceph, Cinder, Glance, Manila, Swift) and sets the appropriate
workstream for their child stories.

## License
This project is distributed under the [3-Clause BSD
License](https://opensource.org/licenses/BSD-3-Clause). See the LICENSE file.

## See Also
* [yorabl/Jira_management_tool](https://github.com/yorabl/Jira_management_tool)
