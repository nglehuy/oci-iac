# pylint: disable=wrong-import-position,import-outside-toplevel
import os
import sys
from collections import OrderedDict

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

import fire
from ruamel.yaml import YAML


def main(
  nlbs: dict,
  registry_htpasswd: str,
  output_file: str,
):
  os.makedirs(os.path.dirname(output_file), exist_ok=True)
  data = {
    # others
    "helm_enabled": True,

    # volumes
    "local_volume_provisioner_enabled": False,
    "local_volume_provisioner_namespace": "kube-system",
    "local_path_provisioner_enabled": True,
    "local_path_provisioner_namespace": "kube-system",
    "local_path_provisioner_storage_class": "local-ocfs2-path",
    "local_path_provisioner_reclaim_policy": "Delete",
    "local_path_provisioner_claim_root": "/ocfs2/local-path-provisioner/",
    "local_path_provisioner_is_default_storageclass": "true",

    # registry
    "registry_enabled": True,
    "registry_namespace": "kube-system",
    "registry_disk_size": "20Gi",
    "registry_storage_class": "local-ocfs2-path",
    "registry_replica_count": 2,
    "registry_htpasswd": registry_htpasswd,

    # metrics
    "metrics_server_enabled": True,
    "metrics_server_kubelet_insecure_tls": True,

    # ingress
    "ingress_nginx_enabled": True,
    "ingress_nginx_namespace": "kube-system",
    "ingress_nginx_host_network": True,  # to allow nginx-ingress from public nlb works
    "ingress_nginx_service_type": "LoadBalancer",
    "ingress_nginx_extra_args": ["--enable-ssl-passthrough"],

    # certs
    "cert_manager_enabled": True,
    "cert_manager_namespace": "cert-manager",

    # network time protocol
    "ntp_enabled": True,
    "ntp_timezone": "Asia/Ho_Chi_Minh",
    "ntp_manage_config": True,
    "ntp_tinker_panic": True,
    "ntp_force_sync_immediately": True,

    # kube
    "kube_network_plugin": "calico",
    "kube_proxy_strict_arp": True,
    "kube_apiserver_port": 6443,

    # nodelocaldns
    "enable_nodelocaldns": False,
    "enable_nodelocaldns_secondary": False,
    "nodelocaldns_ip": "169.254.25.10",
    "nodelocaldns_image_tag": "1.26.4",

    # load balancers
    "metallb_enabled": True,
    "metallb_speaker_enabled": True,
    "metallb_namespace": "metallb-system",
    "metallb_config": {
      "controller": {
        "nodeselector": {
          "kubernetes.io/os": "linux",
        }
      },
      "tolerations": [{
        "key": "node-role.kubernetes.io/control-plane",
        "operator": "Equal",
        "value": "",
        "effect": "NoSchedule",
      }],
      "address_pools": {
        "primary": {
          "ip_range": [f"{ip['ip_address']}/32" for nlb in nlbs.values() for ip in nlb["ip_addresses"] if str(ip["is_public"]).lower() == "true"]
        }
      },
      "layer2": ["primary"],
    }
  }
  yaml = YAML()
  yaml.Representer.add_representer(OrderedDict, yaml.Representer.represent_dict)
  with open(output_file, "w", encoding="utf-8") as f:
    yaml.dump(data, f)


if __name__ == "__main__":
  fire.Fire(main)
