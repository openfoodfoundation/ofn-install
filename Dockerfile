FROM ubuntu

# install ansible 
RUN apt-get -y update
RUN apt-get install -y python-yaml python-jinja2 git
RUN git clone http://github.com/ansible/ansible.git --recursive /tmp/ansible
ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin:$PATH
ENV ANSIBLE_LIBRARY /tmp/ansible/library
ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH

RUN apt-get -y install openssh-server
RUN mkdir /etc/sudoers.d

ADD . /tmp/ofn-install
WORKDIR /tmp/ofn-install
#RUN ansible-playbook -i inventory --limit=local site.yml
