# pylint: disable=wrong-import-position,import-outside-toplevel
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

import fire


def main(
  kube_control_planes: dict,
  kube_nodes: dict,
  output_file: str,
):
  all_instances = {**kube_control_planes, **kube_nodes}
  hosts = [",".join([instance["id"], instance["public_ip"], instance["private_ip"]]) for _, instance in all_instances.items()]
  kube_control_hosts = len(kube_control_planes)

  os.environ["CONFIG_FILE"] = output_file
  os.environ["KUBE_CONTROL_HOSTS"] = str(kube_control_hosts)

  from kubespray.contrib.inventory_builder import inventory
  inventory.main(hosts)


if __name__ == "__main__":
  fire.Fire(main)
