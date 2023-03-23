# frame.work

Implement the [official Fedora install guide](https://guides.frame.work/Guide/Fedora+37+Installation+on+the+Framework+Laptop/108) from Framework via Ansible. [Using Ansible](#using-ansible) and below are from the excellent [Ansible template repo](https://github.com/acch/ansible-boilerplate) by [@acch](https://github.com/acch).

## Quickstart
```bash
# install dependencies
make install
python -m pip install ansible ansible-lint

# run playbook
# * become (sudo)
# * askpass
# * tags: foo,bar
# * verbose
ansible-playbook tasks/pkg.yml -b -K --tags qa -vvv
```

## Using Ansible

Install `ansible` on your laptop and link the `hosts` file from `/etc/ansible/hosts` to the file in your repository. Now you're all set.

To run a single (ad-hoc) task on multiple servers:

```
# Check connectivity
ansible all -m ping -u root

# Run single command on all servers
ansible all -m command -a "cat /etc/hosts" -u root

# Run single command only on servers in specific group
ansible anygroup -m command -a "cat /etc/hosts" -u root

# Run single command on individual server
ansible server1 -m command -a "cat /etc/hosts" -u root
```

As the `command` module is the default, it can also be omitted:

```
ansible server1 -a "cat /etc/hosts" -u root
```

To use shell variables on the remote server, use the `shell` module instead of `command`, and use single quotes for the argument:

```
ansible server1 -m shell -a 'echo $HOSTNAME' -u root
```

The true power of ansible comes with so called *playbooks* &mdash; think of them as scripts, but they're declarative. Playbooks allow for running multiple tasks on any number of servers, as defined in the configuration files (`*.yml`):

```
# Run all tasks on all servers
ansible-playbook site.yml -v

# Run all tasks only on group of servers
ansible-playbook anygroup.yml -v

# Run all tasks only on individual server
ansible-playbook site.yml -v -l server1
```

Note that `-v` produces verbose output. `-vv` and `-vvv` are also available for even more (debug) output.

To verify what tasks would do without changing the actual configuration, use the `--list-hosts` and `--check` parameters:

```
# Show hosts that would be affected by playbook
ansible-playbook site.yml --list-hosts

# Perform dry-run to see what tasks would do
ansible-playbook site.yml -v --check
```

Running all tasks in a playbook may take a long time. *Tags* are available to organize tasks so one can only run specific tasks to configure a certain component:

```
# Show list of available tags
ansible-playbook site.yml --list-tags

# Only run tasks required to configure DNS
ansible-playbook site.yml -v -t dns
```

Note that the above command requires you to have tasks defined with the `tags: dns` attribute.

## Configuration files

The `hosts` file defines all hosts and groups which they belong to. Note that a single host can be member of multiple groups. Define groups for each rack, for each network, or for each environment (e.g. production vs. test).

### Playbooks

Playbooks associate hosts (groups) with roles. Define a separate playbook for each of your groups, and then import all playbooks in the main `site.yml` playbook.

File | Description
---- | -----------
`site.yml` | Main playbook - runs all tasks on all servers
`anygroup.yml` | Group playbook - runs all tasks on servers in group *anygroup*

### Roles

The group playbooks (e.g. `anygroup.yml`) simply associate hosts with roles. Actual tasks are defined in these roles:

```
roles/
├── common/             Applied to all servers
│   ├── handlers/
│   ├── tasks/
│   │   └ main.yml      Tasks for all servers
│   └── templates/
└── anyrole/            Applied to servers in specific group(s)
    ├── handlers/
    ├── tasks/
    │   └ main.yml      Tasks for specific group(s)
    └── templates/
```

Consider adding separate roles for different applications (e.g. webservers, dbservers, hypervisors, etc.), or for different responsibilities which servers fulfill (e.g. infra_server vs. infra_client).

### Tags

Use the following command to show a list of available tags:

```
ansible-playbook site.yml --list-tags
```

Consider adding tags for individual components (e.g. DNS, NTP, HTTP, etc.).

Role | Tags
--- | ---
Common | all,check

## TODO
* Clean up repo based on target audience

## Copyright and license

Copyright 2017 Achim Christ, released under the [MIT license](https://github.com/acch/ansible-boilerplate/blob/master/LICENSE)
