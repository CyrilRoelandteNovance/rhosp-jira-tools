# jira-osp

A collection of scripts to automate common operations in Jira for the Red Hat
OpenStack team.

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
a given project (Ceph, Cinder, Glance, Manila, Neutron, Nova, Swift, Vans) and
sets the appropriate workstream for their child stories.

It also adds the appropriate workstream to issues that have a "whiteboard"
value set, but no workstream. This is often the case with issues created
automatically from Bugzilla bugs.

### fzf-jira
An interactive (but limited) interface for Jira. Upon startup, lists all epics
for the project given as an argument (Ceph, Cinder, Glance, Manila, Neutron,
Nova, Swift, Vans).
Being familiar with [fzf](https://github.com/junegunn/fzf) will help using
fzf-jira to its full potential.

Handy shortcuts allow the user to view stories associated with the highlighted
epic, or all stories for the project:

```verbatim
+-----------------+                    +----------------------+
|                 |------ Alt+c ------>|                      |
|  List of epics  |                    | Chidren stories of   |
|                 |                    | the highlighted epic |
|                 |<----- Alt+e -------|                      |
+-----------------+                    +----------------------+
    |       ^                                      |
    |       |                                      |
  Alt+s   Alt+e                                  Alt+s
    |       |                                      |
    v       |                                      |
+-----------------+                                |
|                 |                                |
| List of stories |<-------------------------------/
|                 |
+-----------------+
```

A list of all shortcuts:

| Shortcut | Action                                                      |
| -------- | ----------------------------------------------------------- |
| Alt+c    | List children stories for highlighted epic                  |
| Alt+e    | List all epics                                              |
| Alt+s    | List all stories                                            |
| Alt+p    | Toggle preview                                              |
| Alt+u    | Update highlighted issue                                    |
| Ctrl+o   | Open highlighted entry (or selected entries) in the browser |

It is important to note that:

* The cache is rebuilt every time fzf-jira is started, so the user might be
  viewing outdated information. This is not really an issue, since fzf-jira is
  meant to be used for quick tasks, such as reading info about an epic or
  updating a few fields without using the WebUI.
* The cache is built at startup and is then used to retrieve all info about
  issues, so that it is as fast as possible. Running two instances of fzf-jira
  at the same time will cause the cache to be overwritten, and both instances
  will share the same cache, which makes it impossible to run `fzf-jira Cinder`
  and `fzf-jira Glance` at the same time.

This scrips also requires:

* column(1) from
[util-linux](https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/).
* fold from coreutils
* [fzf](https://github.com/junegunn/fzf)

And optionally:

* xdg-open (or open on Darwin) to open issues in the web browser
* mktemp to update issues

### jira
A tool to edit Jira issues from the command line. It works well with any custom
field defined in the Jira installation. This tool may be used interactively,
but is mostly meant to be used in scripts.

Example usage:

    $ jira edit --set-Story-Points 8 ABC-1337


### jira-linter
A linter for RHOSP issues. It can detect the following problems:

* E-$issuetype-001: a required field is missing
* W-$issuetype-001: an obsolote field is used

## License
This project is distributed under the [3-Clause BSD
License](https://opensource.org/licenses/BSD-3-Clause). See the LICENSE file.

## See Also
* [yorabl/Jira_management_tool](https://github.com/yorabl/Jira_management_tool)
