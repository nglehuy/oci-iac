# pylint: disable=wrong-import-position,import-outside-toplevel
import os
import sys
from collections import OrderedDict
from copy import deepcopy

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

import fire
from ruamel.yaml import YAML


def main(
  kube_control_planes: dict,
  kube_nodes: dict,
  output_file: str,
):
  kube_control_planes_hosts = {instance["hostname_label"]: None for instance in kube_control_planes.values()}
  kube_nodes_hosts = {instance["hostname_label"]: None for instance in kube_nodes.values()}
  hosts = {
    instance["hostname_label"]: {
      "ansible_host": instance["public_ip"],
      "ip": instance["private_ip"],
      "access_ip": instance["private_ip"],
    }
    for instance in {
      **kube_control_planes,
      **kube_nodes
    }.values()
  }
  data = {
    "all": {
      "hosts": hosts,
      "children": {
        "kube_control_plane": {
          "hosts": kube_control_planes_hosts,
        },
        "kube_node": {
          "hosts": kube_nodes_hosts,
        },
        "etcd": {
          "hosts": deepcopy(kube_control_planes_hosts),
        },
        "k8s_cluster": {
          "children": {
            "kube_control_plane": None,
            "kube_node": None,
          }
        },
        "calico_rr": {
          "hosts": {},
        },
      }
    }
  }
  yaml = YAML()
  yaml.Representer.add_representer(OrderedDict, yaml.Representer.represent_dict)
  with open(output_file, "w", encoding="utf-8") as f:
    yaml.dump(data, f)


if __name__ == "__main__":
  fire.Fire(main)
