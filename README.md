# framework

Implement the [official Fedora install guide](https://guides.frame.work/Guide/Fedora+37+Installation+on+the+Framework+Laptop/108) from Framework via Ansible. [Using Ansible](md/ansible.md) is from the excellent [Ansible template repo](https://github.com/acch/ansible-boilerplate) by [@acch](https://github.com/acch).

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
ansible-playbook tasks/pkg.yml -b -K --<tags|skip-tags> qa -vvv
```

## TODO
* [Issues](https://github.com/pythoninthegrass/framework/issues)
* Clean up repo based on target audience
