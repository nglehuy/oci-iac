# pylint: disable=wrong-import-position,import-outside-toplevel
import os
import sys
from collections import OrderedDict

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

import fire
from ruamel.yaml import YAML


def main(
  nlbs: dict,
  output_file: str,
):
  os.makedirs(os.path.dirname(output_file), exist_ok=True)
  data = {
    # others
    "helm_enabled": True,

    # volumes
    "local_volume_provisioner_enabled": True,
    "local_volume_provisioner_namespace": "kube-system",

    # registry
    "registry_enabled": True,
    "registry_namespace": "kube-system",
    "registry_disk_size": "10Gi",

    # metrics
    "metrics_server_enabled": True,
    "metrics_server_kubelet_insecure_tls": True,

    # ingress
    "ingress_nginx_enabled": True,
    "ingress_nginx_service_type": "LoadBalancer",

    # certs
    "cert_manager_enabled": True,

    # network time protocol
    "ntp_enabled": True,
    "ntp_timezone": "Asia/Ho_Chi_Minh",
    "ntp_manage_config": True,
    "ntp_tinker_panic": True,
    "ntp_force_sync_immediately": True,

    # kube
    "kube_network_plugin": "cilium",
    "kube_proxy_strict_arp": True,
    "kube_apiserver_port": 6443,

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
