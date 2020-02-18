# Changelog

All notable changes to this project will be documented in this file.

Changelog is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
It adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2019-10-13

Note that this release contains breaking changes. Hence the major version bump.

### Added

- Support for TF v0.12
- Support for Network Load Balancers
- Variable `instance_type` added.
- Variable `additional_security_group_ids` added to support more flexibility with security groups.
- Variable `eip_id` added to pass in an EIP object
- `autoscaling_group_min_size`, `autoscaling_group_max_size`, and `autoscaling_group_desired_capacity` variables for autoscaling groups.
- Variable `wireguard_persistent_keepalive` to set keepalive in seconds. Set to 0 to disable.

### Changed

- Variable `public_subnet_ids` renamed to `subnet_ids`
- Ubuntu AMI used will now default to the latest.

### Removed

- An EIP is no longer created in this module, in order to support the option to use a ELB. Instead, a EIP ID must be passed in, if that is the desired configuration.

## [0.0.2] - 2019-03-02

### Added

- Multi-client support via the module variable.
- This CHANGELOG

### Removed

- Single-client public key via AWS SSM as it now conflicts with the module variable method.

## [0.0.1] - 2019-02-24

### Added

- Working module to deploy WireGuard with single client support.
