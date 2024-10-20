# pylint: disable=wrong-import-position
import json
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from k8s.ansible.scripts.inventory import main


def test():
  kube_control_planes = {
    "control-plane-1": {
      "id": "control-plane-1",
      "private_ip": "10.0.0.1",
      "public_ip": "192.168.1.3",
    }
  }

  kube_control_nodes = {
    "control-plane-1": {
      "id": "control-plane-1",
      "private_ip": "10.0.0.1",
      "public_ip": "192.168.1.3",
    },
    "control-plane-2": {
      "id": "control-plane-2",
      "private_ip": "10.0.0.2",
      "public_ip": "192.168.1.5",
    }
  }

  output_file = os.path.join(os.path.dirname(__file__), "hosts.yml")

  main(kube_control_planes, kube_control_nodes, output_file)
