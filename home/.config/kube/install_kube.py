#!/usr/bin/env python3
# pyright: reportExplicitAny=false,reportAny=false
from __future__ import annotations

import argparse
import base64
from dataclasses import dataclass
import datetime
import shutil
from pathlib import Path
from typing import Any, Literal, cast

import yaml


@dataclass(frozen=True, slots=True)
class InputClusterSpec:
    """Cluster connection specification with embedded certificate data."""

    server: str
    certificate_authority_data: str | None


@dataclass(frozen=True, slots=True)
class InputCluster:
    """Named cluster entry."""

    name: str
    spec: InputClusterSpec


@dataclass(frozen=True, slots=True)
class InputUserSpec:
    """User authentication specification with embedded certificate data."""

    client_certificate_data: str | None
    client_key_data: str | None


@dataclass(frozen=True, slots=True)
class InputUser:
    """Named user entry."""

    name: str
    spec: InputUserSpec


@dataclass(frozen=True, slots=True)
class InputContext:
    """Context mapping between cluster and user."""

    name: str
    cluster: str
    user: str


@dataclass(frozen=True, slots=True)
class InputKubeConfig:
    """Parsed single-cluster kubeconfig."""

    cluster: InputCluster
    user: InputUser
    context: InputContext

    @classmethod
    def from_yaml(cls, data: dict[str, Any]) -> InputKubeConfig:
        """Parse and validate a single-cluster kubeconfig.

        Args:
            data: Parsed YAML mapping.

        Returns:
            Parsed and validated input kubeconfig.

        Raises:
            ValueError: If the kubeconfig does not contain exactly one
                cluster, user, and context.
            KeyError: If required fields are missing.
        """
        clusters = data.get("clusters", [])
        users = data.get("users", [])
        contexts = data.get("contexts", [])

        if len(clusters) != 1 or len(users) != 1 or len(contexts) != 1:
            raise ValueError(
                "Input kubeconfig must contain exactly one cluster, one user, and one context"
            )

        cluster_raw = clusters[0]
        user_raw = users[0]
        context_raw = contexts[0]

        cluster_spec = InputClusterSpec(
            server=cluster_raw["cluster"]["server"],
            certificate_authority_data=cluster_raw["cluster"].get(
                "certificate-authority-data"
            ),
        )

        user_spec = InputUserSpec(
            client_certificate_data=user_raw["user"].get("client-certificate-data"),
            client_key_data=user_raw["user"].get("client-key-data"),
        )

        context = InputContext(
            name=context_raw["name"],
            cluster=context_raw["context"]["cluster"],
            user=context_raw["context"]["user"],
        )

        return cls(
            cluster=InputCluster(cluster_raw["name"], cluster_spec),
            user=InputUser(user_raw["name"], user_spec),
            context=context,
        )


def load_yaml(path: Path) -> dict[str, Any]:
    """Load YAML content from a file.

    Args:
        path: Path to the YAML file.

    Returns:
        Parsed YAML mapping.

    Raises:
        ValueError: If the YAML content is not a mapping.
        yaml.YAMLError: If parsing fails.
    """
    with path.open("r", encoding="utf-8") as fh:
        data = yaml.safe_load(fh)

    if not isinstance(data, dict):
        raise ValueError(f"{path} does not contain a valid YAML mapping")

    return cast("dict[str, Any]", data)


def write_yaml(path: Path, data: dict[str, Any]) -> None:
    """Write YAML data to disk.

    Args:
        path: Target file path.
        data: YAML data to write.
    """
    with path.open("w", encoding="utf-8") as fh:
        yaml.safe_dump(data, fh, default_flow_style=False)


def b64_to_file(target: Path, b64_str: str) -> None:
    """Decode base64 data and write it to a file.

    This will also ensure the existence of parent dirs for the target.

    Args:
        target: Destination file path.
        b64_str: Base64-encoded string.
    """
    target.parent.mkdir(parents=True, exist_ok=True)
    raw = base64.b64decode(b64_str)
    with target.open("wb") as fh:
        _ = fh.write(raw)


def load_or_init_kubeconfig(path: Path) -> dict[str, Any]:
    """Load an existing kubeconfig or initialize a new one.

    Args:
        path: Path to the kubeconfig file.

    Returns:
        A valid kubeconfig mapping.
    """
    if path.exists():
        return load_yaml(path)

    return {
        "apiVersion": "v1",
        "kind": "Config",
        "clusters": [],
        "users": [],
        "contexts": [],
        "current-context": "",
    }


def backup_file(path: Path) -> Path:
    """Create a timestamped backup of a file.

    The backup will be placed in the same location as the original file,
    suffixed by `.bak.{timestamp}`.

    Args:
        path: File to back up.

    Returns:
        Path to the backup file.
    """
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = path.with_name(f"{path.name}.bak.{timestamp}")
    _ = shutil.copy2(path, backup_path)
    return backup_path


def _assert_no_name_collision(
    base_cfg: dict[str, Any],
    kind: Literal["clusters", "users", "contexts"],
    name: str,
) -> None:
    """Ensure no existing entry with the given name exists.

    Args:
        base_cfg: Existing kubeconfig.
        kind: One of 'clusters', 'users', or 'contexts'.
        name: Name to check.

    Raises:
        ValueError: If a collision is detected.
    """
    existing = {cast("str", item["name"]) for item in base_cfg.get(kind, [])}

    if name in existing:
        raise ValueError(
            f"{kind[:-1].capitalize()} '{name}' already exists in kubeconfig"
        )


def integrate_cluster(
    base_cfg: dict[str, Any],
    input_cfg: InputKubeConfig,
    key_root: Path,
    target_name: str | None = None,
    server_override: str | None = None,
) -> None:
    """Integrate a parsed input cluster into an existing kubeconfig.

    Embedded certificate data is written to disk and replaced
    with file references.

    Args:
        base_cfg: Existing kubeconfig to extend.
        input_cfg: Parsed single-cluster input kubeconfig.
        key_root: Root directory for extracted certificates.
        target_name:
            Name that should be used for the cluster, user & context.

            If not set, the names from the input config will be used, otherwise,
            this will override those.
        server_override:
            Server address of the cluster to be used instead of the one in input_cfg.

            If not set, the server address from input_cfg will be used.
    """
    cluster = input_cfg.cluster
    user = input_cfg.user
    context = input_cfg.context

    # We want to validate that the input_cfg uses consistent naming
    # (This check is currently here even if we override the name, just to be sure
    # that the imported YAML is internally consistent and actually talks about a
    # single linked cluster, user & context.)
    if not (cluster.name == user.name == context.name):
        raise ValueError("The cluster, user & context names should be matching")

    target_name = target_name if target_name is not None else cluster.name

    _assert_no_name_collision(base_cfg, "clusters", target_name)
    _assert_no_name_collision(base_cfg, "users", target_name)
    _assert_no_name_collision(base_cfg, "contexts", target_name)

    cluster_dir = key_root / target_name

    if cluster.spec.certificate_authority_data:
        b64_to_file(cluster_dir / "ca.crt", cluster.spec.certificate_authority_data)

    if user.spec.client_certificate_data:
        b64_to_file(cluster_dir / "client.crt", user.spec.client_certificate_data)

    if user.spec.client_key_data:
        b64_to_file(cluster_dir / "client.key", user.spec.client_key_data)

    server = server_override if server_override is not None else cluster.spec.server

    base_cfg.setdefault("clusters", []).append(
        {
            "name": target_name,
            "cluster": {
                "server": server,
                "certificate-authority": str(cluster_dir / "ca.crt"),
            },
        }
    )

    base_cfg.setdefault("users", []).append(
        {
            "name": target_name,
            "user": {
                "client-certificate": str(cluster_dir / "client.crt"),
                "client-key": str(cluster_dir / "client.key"),
            },
        }
    )

    base_cfg.setdefault("contexts", []).append(
        {
            "name": target_name,
            "context": {
                "cluster": target_name,
                "user": target_name,
            },
        }
    )

    if not base_cfg.get("current-context"):
        base_cfg["current-context"] = target_name


@dataclass(frozen=True, slots=True)
class Args:
    input: Path
    kubeconfig: Path
    keys: Path
    name: str | None
    server: str | None


def parse_args() -> Args:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Merge a single-cluster kubeconfig into ~/.kube/config"
    )
    _ = parser.add_argument(
        "input",
        type=Path,
        help="Path to kubeconfig containing exactly one cluster",
    )
    _ = parser.add_argument(
        "--kubeconfig",
        type=Path,
        default=Path.home() / ".kube" / "config",
        help="Target kubeconfig to extend",
    )
    _ = parser.add_argument(
        "--keys",
        type=Path,
        default=Path.home() / ".kube" / "keys",
        help="Directory for extracted certificates",
    )
    _ = parser.add_argument(
        "--name",
        type=str,
        help="Override cluster, user and context name when importing",
    )
    _ = parser.add_argument(
        "--server",
        type=str,
        help=(
            "Override the cluster API server address "
            "(useful if the kubeconfig points to localhost)"
        ),
    )
    ns = parser.parse_args()
    return Args(
        input=ns.input,
        kubeconfig=ns.kubeconfig,
        keys=ns.keys,
        name=ns.name,
        server=ns.server,
    )


def main() -> None:
    """CLI entry point."""
    args = parse_args()

    input_yaml = load_yaml(args.input)
    input_cfg = InputKubeConfig.from_yaml(input_yaml)

    base_cfg = load_or_init_kubeconfig(args.kubeconfig)

    if args.kubeconfig.exists():
        backup_path = backup_file(args.kubeconfig)
        print(f"Backup created at {backup_path}")

    integrate_cluster(base_cfg, input_cfg, args.keys, args.name, args.server)
    args.kubeconfig.parent.mkdir(parents=True, exist_ok=True)
    write_yaml(args.kubeconfig, base_cfg)

    print("Cluster added successfully.")


if __name__ == "__main__":
    main()
