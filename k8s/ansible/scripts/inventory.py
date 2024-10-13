import json
from collections import defaultdict

import fire
import toml


def main(
  kube_control_planes: str,
  kube_nodes: str,
  kube_etcds: str,
  output_file: str,
):
  kube_control_plane_instances = json.loads(kube_control_planes)
  kube_nodes_instances = json.loads(kube_nodes)
  kube_etcd_instances = json.loads(kube_etcds)

  inventory = defaultdict(list)
  for instance in kube_nodes_instances:
    inventory["all"].append(f"{instance['id']} ansible_host={instance['public_ip']} ansible_user=opc ansible_become=true")
    inventory["kube_nodes"].append(instance["id"])

  for instance in kube_control_plane_instances:
    inventory["kube_control_plane"].append(instance["id"])

  for instance in kube_etcd_instances:
    inventory["etcd"].append(instance["id"])

  inventory["k8s_cluster:children"] = ["kube_control_plane", "kube_nodes"]

  with open(output_file, "w", encoding="utf-8") as f:
    f.write(toml.dumps(inventory))


if __name__ == "__main__":
  fire.Fire(main)
