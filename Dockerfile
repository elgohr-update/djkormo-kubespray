FROM centos:7
ENV KUBESPRAY_VERSION="v2.14.1"
ENV ANSIBLE_JINJA2_NATIVE=True
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_FORKS 40
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN yum update -y -v && \
    yum upgrade -y && \
    yum install -y langpacks-en glibc-all-langpacks epel-release && \
    yum install -y  python3-pip  python3 rsync git sed gcc python3-devel unzip sshpass jq && \
    yum clean all && rm -rf /var/cache/yum/* && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.conf

# run as non-root
RUN groupadd --gid 5107 containeruser \
    && useradd --home-dir /home/containeruser --create-home --uid 5107 \
    --gid 5107 --shell /bin/sh --skel /dev/null containeruser
USER containeruser
WORKDIR /home/containeruser
RUN mkdir .ssh
RUN git clone http://github.com/kubernetes-sigs/kubespray.git && \
    cd kubespray && \
    git checkout tags/"$KUBESPRAY_VERSION"

RUN cd /home/containeruser/kubespray && \
    pip3 install --user apypie hvac ply && \
    pip3 install --user -r requirements.txt && \
    pip3 install --user -r contrib/inventory_builder/requirements.txt && \
    pip3 install --user -r tests/requirements.txt && \
    /home/containeruser/.local/bin/ansible-playbook mitogen.yml
    
    
