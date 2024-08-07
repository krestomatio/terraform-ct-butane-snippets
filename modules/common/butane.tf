data "template_file" "butane_snippet_hostname" {
  count = var.hostname != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    storage:
      files:
        - path: /etc/hostname
          mode: 0644
          contents:
            inline: "${var.hostname}"
  TEMPLATE
}

data "template_file" "butane_snippet_keymap" {
  count = var.keymap != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    storage:
      files:
        - path: /etc/vconsole.conf
          mode: 0644
          contents:
            inline: "KEYMAP=${var.keymap}"
  TEMPLATE
}

data "template_file" "butane_snippet_periodic_updates" {
  count = var.periodic_updates == null ? 0 : 1

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    - path: /etc/zincati/config.d/55-updates-strategy.toml
      contents:
        inline: |
          [updates]
          strategy = "periodic"
          %{~if var.periodic_updates.time_zone != ""~}
          [updates.periodic]
          time_zone = "${var.periodic_updates.time_zone}"
          %{~endif~}
          %{~for periodic_updates_window in var.periodic_updates.windows~}
          [[updates.periodic.window]]
          days = ["${join("\", \"", periodic_updates_window.days)}"]
          start_time = "${periodic_updates_window.start_time}"
          length_minutes = ${periodic_updates_window.length_minutes}
          %{~endfor~}
TEMPLATE
}

data "template_file" "butane_snippet_rollout_wariness" {
  count = var.rollout_wariness != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    storage:
      files:
        - path: /etc/zincati/config.d/51-rollout-wariness.toml
          contents:
            inline: |
              [identity]
              rollout_wariness = ${var.rollout_wariness}
  TEMPLATE
}

data "template_file" "butane_snippet_timezone" {
  count = var.timezone != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    storage:
      links:
        - path: /etc/localtime
          target: ../usr/share/zoneinfo/${var.timezone}
  TEMPLATE
}

data "template_file" "butane_snippet_grub_password_hash" {
  count = var.grub_password_hash != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    # Available until 1.5.0
    version: 1.5.0
    grub:
      users:
        - name: root
          password_hash: ${var.grub_password_hash}
  TEMPLATE
}

data "template_file" "butane_snippet_do_not_countme" {
  count = var.do_not_countme ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    systemd:
      units:
        - name: rpm-ostree-countme.timer
          enabled: false
          mask: true
  TEMPLATE
}

data "template_file" "butane_snippet_etc_hosts" {
  count = length(var.etc_hosts) > 0 || var.etc_hosts_extra != "" ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    - path: /etc/hosts
      overwrite: false
      append:
        - inline: |
            %{~if length(var.etc_hosts) > 0~}
            # hosts
            %{~for host in var.etc_hosts~}
            %{if host.ip == split("/", var.cidr_ip_address)[0]}127.0.0.1%{else}${host.ip}%{endif}%{if host.hostname != ""} ${host.hostname}%{endif} ${host.hostname} ${host.fqdn}
            %{~endfor~}
            %{~endif~}
            %{~if var.etc_hosts_extra != ""~}
            # extra hosts
            ${indent(12, var.etc_hosts_extra)}
            %{~endif~}
TEMPLATE
}

data "template_file" "butane_snippet_core_authorized_key" {
  count = var.ssh_authorized_key != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    passwd:
      users:
        - name: core
          ssh_authorized_keys:
            - ${var.ssh_authorized_key}
  TEMPLATE
}

data "template_file" "butane_snippet_static_interface" {
  count = var.cidr_ip_address != null ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    - path: /etc/NetworkManager/conf.d/noauto.conf
      mode: 0644
      contents:
        inline: |
          [main]
          # Do not do automatic (DHCP/SLAAC) configuration on ethernet devices
          # with no other matching connections.
          no-auto-default=*
    - path: /etc/NetworkManager/system-connections/${var.interface_name}.nmconnection
      mode: 0600
      overwrite: true
      contents:
        inline: |
          [connection]
          id=${var.interface_name}
          interface-name=${var.interface_name}
          type=ethernet
          [ipv4]
          addresses=${var.cidr_ip_address}
          gateway=${cidrhost(var.cidr_ip_address, 1)}
          %{~if length(var.nameservers) > 0~}
          dns=${join(";", var.nameservers)};
          %{~endif~}
          may-fail=false
          method=manual
          [ipv6]
          method=disabled
TEMPLATE
}

data "template_file" "butane_snippet_disks" {
  count = length(var.disks) > 0 ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  disks:
    %{~for disk in var.disks~}
    - device: ${disk.device}
      %{~if disk.wipe_table != null~}
      wipe_table: ${disk.wipe_table}
      %{~endif~}
      %{~if disk.partitions != null~}
      partitions:
        %{~for partition in disk.partitions~}
        - should_exist: ${partition.should_exist}
          %{~if partition.label != null~}
          label: ${partition.label}
          %{~endif~}
          %{~if partition.number != null~}
          number: ${partition.number}
          %{~endif~}
          %{~if partition.size_mib != null~}
          size_mib: ${partition.size_mib}
          %{~endif~}
          %{~if partition.start_mib != null~}
          start_mib: ${partition.start_mib}
          %{~endif~}
          %{~if partition.type_guid != null~}
          type_guid: ${partition.type_guid}
          %{~endif~}
          %{~if partition.guid != null~}
          guid: ${partition.guid}
          %{~endif~}
          %{~if partition.wipe_partition_entry != null~}
          wipe_partition_entry: ${partition.wipe_partition_entry}
          %{~endif~}
          %{~if partition.resize != null~}
          resize: ${partition.resize}
          %{~endif~}
        %{~endfor~}
      %{~endif~}
    %{~endfor~}
TEMPLATE
}

data "template_file" "butane_snippet_filesystems" {
  count = length(var.filesystems) > 0 ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  filesystems:
    %{~for filesystem in var.filesystems~}
    - device: ${filesystem.device}
      format: ${filesystem.format}
      %{~if filesystem.path != null~}
      # NOTE: all data is expected to be stored inside `/var`
      # REF: https://docs.fedoraproject.org/en-US/fedora-coreos/storage/#_configuration_in_etc_and_state_in_var
      path: ${filesystem.path}
      %{~endif~}
      %{~if filesystem.with_mount_unit != null~}
      with_mount_unit: ${filesystem.with_mount_unit}
      %{~endif~}
      %{~if filesystem.wipe_filesystem != null~}
      wipe_filesystem: ${filesystem.wipe_filesystem}
      %{~endif~}
      %{~if filesystem.label != null~}
      label: ${filesystem.label}
      %{~endif~}
      %{~if filesystem.uuid != null~}
      uuid: ${filesystem.uuid}
      %{~endif~}
      %{~if filesystem.options != null~}
      options: ${filesystem.options}
      %{~endif~}
      %{~if filesystem.mount_options != null~}
      mount_options:
        %{~for mount_option in filesystem.mount_options~}
        - "${mount_option}"
        %{~endfor~}
      %{~endif~}
    %{~endfor~}
TEMPLATE
}

data "template_file" "butane_snippet_additional_rpms" {
  count = var.additional_rpms != null ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    %{~if length(var.additional_rpms.list) > 0~}
    # pkg dependencies to be installed by additional-rpms.service
    - path: /var/lib/additional-rpms.list
      mode: 0644
      overwrite: true
      contents:
        inline: |
          %{~for additional_rpm in var.additional_rpms.list~}
          ${additional_rpm}
          %{~endfor~}
    %{~endif~}
systemd:
  units:
    - name: additional-rpms.service
      enabled: true
      contents: |
        [Unit]
        Description=Layer additional rpms
        Wants=network-online.target
        After=network-online.target
        After=systemd-machine-id-commit.service
        # We run before `zincati.service` to avoid conflicting rpm-ostree transactions.
        Before=zincati.service
        Before=shutdown.target
        ConditionPathExists=/var/lib/additional-rpms.list
        ConditionPathExists=!/var/lib/%N.done
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        %{~for cmd_pre in var.additional_rpms.cmd_pre~}
        ExecStart=${cmd_pre}
        %{~endfor~}
        ExecStart=/bin/sh -c '/usr/bin/rpm-ostree install --idempotent --assumeyes --allow-inactive $$(</var/lib/additional-rpms.list)'
        ExecStart=/bin/touch /var/lib/%N.done
        %{~for cmd_post in var.additional_rpms.cmd_post~}
        ExecStart=${cmd_post}
        %{~endfor~}
        ExecStart=/usr/bin/systemctl --no-block reboot
        [Install]
        WantedBy=multi-user.target
TEMPLATE
}

data "template_file" "butane_snippet_sync_time_with_host" {
  count = var.sync_time_with_host ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    storage:
      files:
        - path: /etc/modules-load.d/90-ptp_kvm.conf
          mode: 0644
          contents:
            inline: ptp_kvm
        - path: /etc/chrony.conf
          overwrite: false
          append:
            - inline: |
                refclock PHC /dev/ptp0 poll 2
  TEMPLATE
}

data "template_file" "butane_snippet_systemd_pager" {
  count = var.systemd_pager != "" ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    storage:
      files:
        - path: /etc/profile.d/systemd-pager.sh
          mode: 0644
          contents:
            inline: |
              export SYSTEMD_PAGER=${var.systemd_pager}
  TEMPLATE
}

data "template_file" "butane_snippet_sysctl" {
  count = var.sysctl != null ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    - path: /etc/sysctl.d/10-tuning.conf
      mode: 0644
      contents:
        inline: |
          %{~for key, value in var.sysctl~}
          ${key} = ${value}
          %{~endfor~}
TEMPLATE
}

data "template_file" "butane_snippet_init_config_script" {
  count = var.init_config_script != "" ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    - path: /usr/local/bin/init-config.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          ${indent(10, var.init_config_script)}
systemd:
  units:
    - name: init-config-script.service
      enabled: true
      contents: |
        [Unit]
        Description=Install Init Config Script
        # We run before `zincati.service` to avoid conflicting rpm-ostree
        # transactions.
        Before=zincati.service
        Wants=network-online.target
        After=network-online.target
        After=additional-rpms.service
        ConditionPathExists=/usr/local/bin/init-config.sh
        ConditionPathExists=!/var/lib/%N.done

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=on-failure
        ExecStart=/usr/local/bin/init-config.sh
        ExecStart=/bin/touch /var/lib/%N.done

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}

data "template_file" "butane_snippet_disable_zincati" {
  count = var.disable_zincati ? 1 : 0

  template = <<-TEMPLATE
    ---
    variant: fcos
    version: 1.4.0
    systemd:
      units:
        - name: zincati.service
          enabled: false
          mask: true
  TEMPLATE
}

data "template_file" "butane_snippet_kernel_arguments" {
  count = length(var.kernel_arguments) != null ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
kernel_arguments:
  %{~if var.kernel_arguments.should_exist != []~}
  should_exist:
    %{~for should_exist_argument in var.kernel_arguments.should_exist~}
    - ${should_exist_argument}
    %{~endfor~}
  %{~endif~}
  %{~if var.kernel_arguments.should_not_exist != []~}
  should_not_exist:
    %{~for should_not_exist_argument in var.kernel_arguments.should_not_exist~}
    - ${should_not_exist_argument}
    %{~endfor~}
  %{~endif~}
TEMPLATE
}

data "template_file" "butane_snippet_rpm_ostree_rebase" {
  count = var.rpm_ostree_rebase != "" ? 1 : 0

  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
systemd:
  units:
    - name: rpm-ostree-rebase.service
      enabled: true
      contents: |
        [Unit]
        Description=Rebase rpm-ostree
        Wants=network-online.target
        After=network-online.target
        After=systemd-machine-id-commit.service
        # We run before `zincati.service` to avoid conflicting rpm-ostree transactions.
        Before=zincati.service
        Before=shutdown.target
        Before=additional-rpms.service
        ConditionPathExists=!/var/lib/%N.done
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/bin/rpm-ostree rebase ${var.rpm_ostree_rebase}
        ExecStart=/bin/touch /var/lib/%N.done
        ExecStart=/usr/bin/systemctl --no-block reboot
        [Install]
        WantedBy=multi-user.target
TEMPLATE
}
