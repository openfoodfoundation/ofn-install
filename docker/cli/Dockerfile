FROM ubuntu:20.04 AS cli-base
ARG user=ubuntu
ARG extra_packages='ssh curl wget ruby sudo unzip python3-pip python3-setuptools python3-dev python3-wheel locales gcc libffi-dev libxml2-dev ruby-dev awscli make jq ansible'

# Common tools
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y ${extra_packages}

# Add an unprivileged user with sudo
RUN apt-get update \
    && apt-get install -y sudo \
    && useradd -m ${user} \
    && adduser ${user} sudo \
    && echo "${user} ALL=NOPASSWD: ALL" > /etc/sudoers.d/${user}

# Terraform
ARG terraform_version='0.15.3'
RUN wget "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" \
    && unzip "terraform_${terraform_version}_linux_amd64.zip" -d /usr/bin/ \
    && rm "terraform_${terraform_version}_linux_amd64.zip"

# Locale setup
RUN /usr/sbin/locale-gen en_US.UTF-8

# Ansible requirements
COPY requirements.txt /tmp/
RUN pip3 install --upgrade pip \
    && pip3 install -r /tmp/requirements.txt

# Ansible
COPY bin/requirements.yml /tmp
RUN /usr/bin/ansible-galaxy install -r tmp/requirements.yml

USER root
ENTRYPOINT ["/opt/ofn-install/bin/cli_wrapper"]
