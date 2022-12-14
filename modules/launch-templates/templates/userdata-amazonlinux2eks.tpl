MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

# User-supplied pre userdata code
${pre_userdata}

# Deal with extra new disks
IDX=1
DEVICES=$(lsblk -o NAME,TYPE -dsn | awk '/disk/ {print $1}')
for DEV in $DEVICES
do
  mkfs.xfs /dev/$${DEV}
  mkdir -p /local$${IDX}

  echo /dev/$${DEV} /local$${IDX} xfs defaults,noatime 1 2 >> /etc/fstab

  IDX=$(($${IDX} + 1))
done
mount -a

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh --b64-cluster-ca '${cluster_ca_base64}' --apiserver-endpoint '${cluster_endpoint}' ${bootstrap_extra_args} --kubelet-extra-args "${kubelet_extra_args}" '${eks_cluster_id}'

# User-supplied post userdata code
${post_userdata}

--//--
