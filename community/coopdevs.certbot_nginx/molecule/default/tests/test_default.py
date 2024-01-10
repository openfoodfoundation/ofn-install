import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_certbot_is_installed(host):
    certbot = host.package("certbot")

    assert certbot.is_installed
    assert certbot.version.startswith("0.31")


def test_certbot_nginx_is_installed(host):
    certbot_nginx = host.package("python-certbot-nginx")

    assert certbot_nginx.is_installed
    assert certbot_nginx.version.startswith("0.31")
