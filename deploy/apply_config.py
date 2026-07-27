#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

DISABLED_RESOURCES = {
    "addons",
    "mainFunc",
    "vehicleshop",
    "Level",
    "safezones",
    "crafting",
}
REQUIRED_RESOURCES = (
    "carshaders",
    "z_map",
    "skins",
    "models",
    "movehead",
    "(flaker)log_reg_sys",
    "zombieRPG",
    "sounds",
    "ZSolp",
    "zmrpg_telemetry",
)


def parse_xml(path):
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
    return ET.parse(path, parser=parser)


def configure_server(path):
    tree = parse_xml(path)
    root = tree.getroot()

    server_name = root.find("servername")
    if server_name is not None:
        server_name.text = "Zombie Mod RPG (2011)"

    max_players = root.find("maxplayers")
    if max_players is not None:
        max_players.text = "100"

    resources = [node for node in root.findall("resource") if node.get("src")]
    for node in resources:
        if node.get("src") in DISABLED_RESOURCES:
            root.remove(node)

    by_name = {node.get("src"): node for node in root.findall("resource") if node.get("src")}
    for name in REQUIRED_RESOURCES:
        node = by_name.get(name)
        if node is None:
            node = ET.SubElement(root, "resource")
            node.set("src", name)
        node.set("startup", "1")
        node.set("protected", "0")

    ET.indent(tree, space="    ")
    tree.write(path, encoding="utf-8", xml_declaration=False)


def configure_acl(path):
    tree = parse_xml(path)
    root = tree.getroot()
    admin_group = next((node for node in root.findall("group") if node.get("name") == "Admin"), None)
    if admin_group is None:
        raise RuntimeError("Admin ACL group was not found")

    object_name = "resource.zmrpg_telemetry"
    if not any(node.get("name") == object_name for node in admin_group.findall("object")):
        node = ET.SubElement(admin_group, "object")
        node.set("name", object_name)

    ET.indent(tree, space="    ")
    tree.write(path, encoding="utf-8", xml_declaration=False)


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: apply_config.py MTASERVER_CONF ACL_XML")
    server_config = Path(sys.argv[1])
    acl_config = Path(sys.argv[2])
    configure_server(server_config)
    configure_acl(acl_config)


if __name__ == "__main__":
    main()
