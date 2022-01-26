#!/bin/sh
set -e

ANSIBLE_ROOT="/examples"
ANSIBLE_INVENTORY="${ANSIBLE_ROOT}/inventory"
ANSIBLE_SERVER_GROUP="clusternodes"

if [ "$1" = 'get-tarball' ]; then
    echo "=> Copy collection tarball outside of container"
    cd /opt && cp -f *.tar.gz ${ANSIBLE_ROOT}/
    exit $?
fi

if [ "$1" = 'run' ]; then
    echo "=> Provision a new cluster"
    ansible-playbook -i ${ANSIBLE_INVENTORY} playbook-provision-cluster.yml --limit ${ANSIBLE_SERVER_GROUP}
    exit $?
fi

if [ "$1" = 'unprovision-cluster' ]; then
    echo "=> Unprovision services and cluster"
    read -p "Are you sure? " -n 1 -r
    echo
    ret=0
    if [[ $REPLY == 'y' ]]
    then
        ansible-playbook -i ${ANSIBLE_INVENTORY} playbook-unprovision-cluster.yml --limit ${ANSIBLE_SERVER_GROUP}
    fi
    exit $ret
fi

if [ "$1" = 'unprovision-services' ]; then
    echo "=> Unprovision services"
    read -p "Are you sure? " -n 1 -r
    echo
    ret=0
    if [[ $REPLY == 'y' ]]
    then
        ansible-playbook -i ${ANSIBLE_INVENTORY} playbook-unprovision-services.yml --limit ${ANSIBLE_SERVER_GROUP}
    fi
    exit $ret
fi

if [ "$1" = 'check' ]; then
    for playbook in $(cd ${ANSIBLE_ROOT} && ls -1 *.yml)
    do
	    echo
	    echo "=> Start syntax checking & linting for playbook $playbook"
	    ansible-playbook -i ${ANSIBLE_INVENTORY} --syntax-check ${ANSIBLE_ROOT}/$playbook --limit ${ANSIBLE_SERVER_GROUP}
	    ansible-lint -v ${ANSIBLE_ROOT}/$playbook 
	    echo "=> End of syntax checking & linting for playbook $playbook"
    done
    for role in $(cd /usr/share/ansible/collections/ansible_collections/opensvc/cluster/roles && ls -1)
    do
	    echo "=> Start syntax linting for role $role"
        ansible-lint /usr/share/ansible/collections/ansible_collections/opensvc/cluster/roles/$role 
        echo "=> End of syntax linting for role $role"
        echo
    done
    exit $?
fi

exec "$@"
