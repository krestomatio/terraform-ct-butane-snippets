locals {
  kubectl_server_option              = var.origin_server != "" ? "--server ${var.origin_server}" : ""
  k3s_shutdown_cordon_state_file     = "${var.data_dir}/k3s-uncordon.todo"
  k3s_service_name                   = var.mode == "agent" ? "k3s-agent.service" : "k3s.service"
  k3s_install_service_env_file       = "/etc/systemd/system/${var.install_service_name}.env"
  k3s_shutdown_service_name          = "shutdown-${local.k3s_service_name}"
  k3s_shutdown_uncordon_service_name = "shutdown-uncordon-${local.k3s_service_name}"
  k3s_kubelet_kubeconfig             = "${var.data_dir}/agent/kubelet.kubeconfig"
  k3s_etcd_dir                       = "${var.data_dir}/server/db/etcd"
  k3s_secret_encryption_path         = "${var.data_dir}/server/cred/encryption-config.json"
  is_server_bootstrap                = var.mode == "bootstrap"
  is_server                          = contains(["bootstrap", "server"], var.mode)
  is_server_not_bootstrap            = var.mode == "server"
  is_agent                           = var.mode == "agent"
  k3s_opt_data_dir                   = "/var/opt/rancher/k3s"
  oidc_sc_signing_key_dir            = "${local.k3s_opt_data_dir}/server/tls"
  oidc_sc_signing_key_file           = "${local.oidc_sc_signing_key_dir}/oidc-sc-signing.key"
  oidc_sc_key_file                   = "${local.oidc_sc_signing_key_dir}/service.key"
  k3s_installer_file                 = "/usr/local/bin/k3s-installer.sh"
}

data "template_file" "butane_snippet_install_k3s" {
  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  %{~if local.is_server && var.oidc_sc != null~}
  directories:
    - path: ${local.k3s_opt_data_dir}/server/tls
      mode: 0700
  %{~endif~}
  files:
    - path: /usr/local/bin/k3s-pre-installer.sh
      mode: 0700
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -eu
          %{~if var.selinux~}
          /usr/local/bin/k3s-installer-selinux-data-dir.sh
          %{~endif~}
          %{~if local.is_server && var.oidc_sc != null~}
          /usr/local/bin/k3s-installer-service-account-key.sh
          %{~endif~}
          %{~if !local.is_server_bootstrap~}
          /usr/local/bin/k3s-installer-wait-bootstrap-server.sh
          %{~endif~}
          %{~if var.fleetlock != null && local.is_server_bootstrap~}
          /usr/local/bin/fleetlock-addon-installer.sh
          %{~endif~}
          %{~if var.pre_install_script_snippet != ""~}
          ${indent(10, var.pre_install_script_snippet)}
          %{~endif~}
    %{~if var.secret_encryption_key != "" && local.is_server~}
    - path: /usr/local/bin/k3s-write-secret-encryption.sh
      mode: 0700
      overwrite: true
      contents:
        inline: |
          #!/bin/bash
          # Disable xtrace to prevent secret leaking in logs
          { set +x; } 2>/dev/null

          dest="${local.k3s_secret_encryption_path}"

          if [ ! -f "$dest" ]; then
            mkdir -p "$(dirname "$dest")"
            # Pre-create with restricted permissions before secret is written
            install -m 0600 /dev/null "$dest"
            printf '%s\n' '${sensitive("{\"kind\":\"EncryptionConfiguration\",\"apiVersion\":\"apiserver.config.k8s.io/v1\",\"resources\":[{\"resources\":[\"secrets\"],\"providers\":[{\"aescbc\":{\"keys\":[{\"name\":\"aescbckey\",\"secret\":\"${base64encode(var.secret_encryption_key)}\"}]}},{\"identity\":{}}]}]}")}'  > "$dest"
          fi
    %{~endif~}
    - path: /usr/local/bin/install-k3s.sh
      mode: 0700
      overwrite: true
      contents:
        inline: |
          #!/bin/bash

          # vars
          export K3S_DATA_DIR=$$${K3S_DATA_DIR:-${var.data_dir}}
          %{~for envvar in var.script_envvars~}
          export ${envvar}
          %{~endfor~}
          %{~if var.channel != ""~}
          export INSTALL_K3S_CHANNEL=$$${INSTALL_K3S_CHANNEL:-${var.channel}}
          %{~endif~}
          %{~if var.mode != "agent"~}
          %{~if var.token != ""~}
          export K3S_TOKEN=$$${K3S_TOKEN:-${var.token}}
          %{~endif~}
          %{~if var.agent_token != ""~}
          export K3S_AGENT_TOKEN=$$${K3S_AGENT_TOKEN:-${var.agent_token}}
          %{~endif~}
          %{~else~}
          %{~if var.agent_token != ""~}
          export K3S_TOKEN=$$${K3S_TOKEN:-${var.agent_token}}
          %{~else~}
          export K3S_TOKEN=$$${K3S_TOKEN:-${var.token}}
          %{~endif~}
          %{~endif~}
          %{~if local.is_server_bootstrap~}
          if [[ -d "${local.k3s_etcd_dir}" && "$(ls -A "${local.k3s_etcd_dir}")" ]]; then
            export K3S_URL=$$${K3S_URL:-${var.origin_server}}
          else
            export K3S_CLUSTER_INIT=true
          fi
          %{~else~}
          export K3S_URL=$$${K3S_URL:-${var.origin_server}}
          %{~endif~}
          %{~if var.selinux~}
          export K3S_SELINUX=$$${K3S_SELINUX:-true}
          %{~endif~}

          if rpm -q k3s-selinux &>/dev/null; then
            export INSTALL_K3S_SKIP_SELINUX_RPM=$$${INSTALL_K3S_SKIP_SELINUX_RPM:-true}
          fi

          if [ -d "/usr/bin/k3s" ]; then
            echo "Copying already installed k3s binaries"
            cp -p /usr/bin/k3s/* /usr/local/bin/
          fi

          if ! [ "$(getenforce)" = "Disabled" ]; then
            echo "Restoring SELinux context for /usr/local/bin"
            restorecon -Rv /usr/local/bin
          fi

          if [ -f "/usr/local/bin/k3s" ]; then
            export INSTALL_K3S_SKIP_DOWNLOAD=$$${INSTALL_K3S_SKIP_DOWNLOAD:-true}
          fi

          if [ ! -f ${local.k3s_installer_file} ]; then
            echo "Downloading k3s installer"
            K3S_INSTALLER_SHA256_CHECKSUM="${var.install_script.sha256sum}"
            curl -sSL "${var.install_script.url}" -o ${local.k3s_installer_file}
            chmod 0700 ${local.k3s_installer_file}
            echo "$K3S_INSTALLER_SHA256_CHECKSUM ${local.k3s_installer_file}" | sha256sum --check --status
          fi

          %{~if var.install_script_snippet != ""~}
          # install snippet
          ${indent(10, var.install_script_snippet)}
          %{~endif~}

          if [ -n "$K3S_NODE_NAME" ]; then
            sed -i "s@^K3S_NODE_NAME=.*@K3S_NODE_NAME=$K3S_NODE_NAME@" \
              /usr/local/bin/k3s-shutdown.sh /usr/local/bin/k3s-uncordon-node.sh
          fi
          %{~if var.secret_encryption_key != "" && local.is_server~}
          /usr/local/bin/k3s-write-secret-encryption.sh
          %{~endif~}

          ${local.k3s_installer_file} ${local.is_server ? "server" : "agent"} \
            %{~if var.kubelet_config.content != ""~}
            --kubelet-arg 'config=/etc/rancher/k3s/kubelet-config.yaml' \
            %{~endif~}
            %{~if var.oidc_sc != null~}
            --kube-apiserver-arg=service-account-key-file=${local.oidc_sc_key_file} \
            --kube-apiserver-arg=service-account-signing-key-file=${local.oidc_sc_signing_key_file} \
            --kube-apiserver-arg=service-account-issuer=${var.oidc_sc.issuer} \
            %{~if var.oidc_sc.jwks_uri != ""~}
            --kube-apiserver-arg=service-account-jwks-uri=${var.oidc_sc.jwks_uri} \
            %{~endif~}
            --kube-apiserver-arg=api-audiences=${var.oidc_sc.api_audiences} \
            %{~endif~}
            %{~for parameter in var.script_parameters~}
            ${parameter} \
            %{~endfor~}
            $$${KUBELET_PROVIDER_ID:+--kubelet-arg=provider-id=$KUBELET_PROVIDER_ID} \
            --data-dir $K3S_DATA_DIR

          systemctl enable --now ${local.k3s_service_name}
    - path: /usr/local/bin/k3s-post-installer.sh
      mode: 0700
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -eu
          %{~if var.post_install_script_snippet != ""~}
          ${indent(10, var.post_install_script_snippet)}
          %{~endif~}
    %{~if local.is_server && var.oidc_sc != null~}
    - path: ${local.oidc_sc_signing_key_file}
      mode: 0600
      overwrite: true
      contents:
        inline: |
          ${indent(10, sensitive(var.oidc_sc.signing_key))}
    - path: /usr/local/bin/k3s-installer-service-account-key.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -eu

          # Define paths and variables
          oidc_sc_signing_key_file="${local.oidc_sc_signing_key_file}"
          oidc_sc_key_file="${local.oidc_sc_key_file}"
          oidc_sc_existing_key_file="${var.data_dir}/server/tls/service.key"

          # Check if original current key file exists
          if [ ! -f "$oidc_sc_signing_key_file" ]; then
            echo "Service original current key file does not exist."
            exit 1
          fi

          # Check if existing key file exists
          if [ -f "$oidc_sc_existing_key_file" ]; then
            # Remove newline characters from content for comparison
            oidc_sc_existing_key_file_content=$(cat "$oidc_sc_signing_key_file" | tr -d '\r\n')
            oidc_sc_key_file_content=$(cat "$oidc_sc_key_file" | tr -d '\r\n')

            # Check if current key content is already in service key file
            if [[ "$oidc_sc_key_file_content" == *"$oidc_sc_existing_key_file_content"* ]]; then
              echo "Existing key is already in the service key file."
            else
              # Append existing key to service key file
              cat "$oidc_sc_existing_key_file" >> "$oidc_sc_key_file"
              echo "Appended existing key to service key file."
            fi
          fi

          if [ -f "$oidc_sc_key_file" ]; then
            # Remove newline characters from content for comparison
            oidc_sc_signing_key_file_content=$(cat "$oidc_sc_signing_key_file" | tr -d '\r\n')
            oidc_sc_key_file_content=$(cat "$oidc_sc_key_file" | tr -d '\r\n')

            # Check if current key content is already in service key file
            if [[ "$oidc_sc_key_file_content" == *"$oidc_sc_signing_key_file_content"* ]]; then
              echo "Current key is already in the service key file."
            else
              # Append current key to service key file
              echo "$(cat "$oidc_sc_signing_key_file" "$oidc_sc_key_file")" >| "$oidc_sc_key_file"
              echo "Appended current key to service key file."
            fi
          else
            # Create service key file, appending current key
            cat "$oidc_sc_signing_key_file" >| "$oidc_sc_key_file"
            echo "Created service key file."
          fi

          chmod 0600 "$oidc_sc_key_file"
          chmod 0600 "$oidc_sc_signing_key_file"
    %{~endif~}
    %{~if var.shutdown.service~}
    - path: /usr/local/bin/k3s-shutdown.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash

          K3S_NODE_NAME="$(hostname -f)"

          export KUBECONFIG=$$${KUBECONFIG:-${local.k3s_kubelet_kubeconfig}}
          %{~if var.shutdown.drain~}
          already_cordoned="$(/usr/local/bin/k3s kubectl ${local.kubectl_server_option} get node "$K3S_NODE_NAME" -o jsonpath='{.spec.unschedulable}')"
          /usr/local/bin/k3s kubectl ${local.kubectl_server_option} \
            drain "$K3S_NODE_NAME" \
            %{~if var.shutdown.drain_timeout != "0"~}
            --timeout=${var.shutdown.drain_timeout} \
            %{~endif~}
            %{~if var.shutdown.drain_request_timeout != "0"~}
            --request-timeout=${var.shutdown.drain_request_timeout} \
            %{~endif~}
            %{~if var.shutdown.drain_grace_period >= 0~}
            --grace-period=${var.shutdown.drain_grace_period} \
            %{~endif~}
            %{~if var.shutdown.drain_skip_wait_for_delete_timeout > 0~}
            --skip-wait-for-delete-timeout=${var.shutdown.drain_skip_wait_for_delete_timeout} \
            %{~endif~}
            --ignore-daemonsets \
            --delete-emptydir-data \
            --force
          [ "$already_cordoned" = "true" ] || touch ${local.k3s_shutdown_cordon_state_file}
          %{~endif~}
          %{~if var.shutdown.killall_script~}
          /usr/local/bin/k3s-killall.sh
          %{~endif~}
    - path: /usr/local/bin/k3s-uncordon-node.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash

          K3S_NODE_NAME="$(hostname -f)"

          export KUBECONFIG=$$${KUBECONFIG:-${local.k3s_kubelet_kubeconfig}}

          is_node_ready() {
            /usr/local/bin/k3s kubectl ${local.kubectl_server_option} \
              wait node --for condition=Ready --timeout=1m "$K3S_NODE_NAME"
          }

          uncordon_node() {
            /usr/local/bin/k3s kubectl ${local.kubectl_server_option}  \
              uncordon "$K3S_NODE_NAME"
          }

          for i in {1..5}; do
            if is_node_ready; then
              uncordon_node
              break
            fi
            sleep 5
          done
    %{~endif~}
    %{~if var.selinux~}
    - path: /usr/local/bin/k3s-installer-selinux-data-dir.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -eu
          K3S_DATA_DIR=${var.data_dir}
          if [[ -d "$K3S_DATA_DIR" && ! -f "$K3S_DATA_DIR/.selinux" ]]; then
              mkdir -p "$K3S_DATA_DIR/storage"
              restorecon -R "$K3S_DATA_DIR"
              touch "$K3S_DATA_DIR/.selinux"
          fi
    %{~endif~}
    %{~if var.fleetlock != null~}
    - path: /etc/zincati/config.d/60-fleetlock-updates-strategy.toml
      contents:
        inline: |
          [identity]
          group = "${coalesce(var.fleetlock.group, var.mode == "agent" ? "agents" : "servers")}"
          [updates]
          strategy = "fleet_lock"
          [updates.fleet_lock]
          base_url = "http://${var.fleetlock.cluster_ip}"
    %{~if local.is_server_bootstrap~}
    - path: /var/opt/fleetlock/namespace.yaml
      mode: 0644
      overwrite: true
      contents:
        inline: |
          apiVersion: v1
          kind: Namespace
          metadata:
            name: default
    - path: /var/opt/fleetlock/kustomization.yaml
      mode: 0644
      overwrite: true
      contents:
        inline: |
          apiVersion: kustomize.config.k8s.io/v1beta1
          kind: Kustomization
          namespace: ${var.fleetlock.namespace}
          resources:
          - namespace.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/cluster-role-binding.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/cluster-role.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/deployment.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/role-binding.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/role.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/service-account.yaml
          - https://raw.githubusercontent.com/poseidon/fleetlock/${var.fleetlock.version}/examples/k8s/service.yaml
          patches:
          - patch: |-
              apiVersion: v1
              kind: Service
              metadata:
                name: fleetlock
              spec:
                clusterIP: ${var.fleetlock.cluster_ip}
          %{~if length(var.fleetlock.node_selectors) > 0 || length(var.fleetlock.tolerations) > 0~}
          - patch: |-
              apiVersion: apps/v1
              kind: Deployment
              metadata:
                name: fleetlock
              spec:
                template:
                  spec:
                    %{~if var.fleetlock.affinity != ""~}
                    affinity:
                      ${indent(22, var.fleetlock.affinity)}
                    %{~endif~}
                    containers:
                    - name: fleetlock
                      env:
                      - name: NAMESPACE
                        valueFrom:
                          fieldRef:
                            fieldPath: metadata.namespace
                      %{~if var.fleetlock.resources != ""~}
                      resources:
                        ${indent(24, var.fleetlock.resources)}
                      %{~endif~}
                    %{~if length(var.fleetlock.node_selectors) > 0~}
                    nodeSelector:
                    %{~for label, value in var.fleetlock.node_selectors~}
                    ${label}: "${value}"
                    %{~endfor~}
                    %{~endif~}
                    %{~if length(var.fleetlock.tolerations) > 0~}
                    tolerations:
                    %{~for toleration in var.fleetlock.tolerations~}
                    - operator: "${toleration.operator}"
                      %{~if toleration.key != ""~}
                      key: "${toleration.key}"
                      %{~endif~}
                      %{~if toleration.value != ""~}
                      value: "${toleration.value}"
                      %{~endif~}
                      %{~if toleration.effect != ""~}
                      effect: "${toleration.effect}"
                      %{~endif~}
                    %{~endfor~}
                    %{~endif~}
          %{~endif~}
    - path: /usr/local/bin/fleetlock-addon-installer.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -e
          if ! which kustomize &>/dev/null; then
            ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
            KUSTOMIZE_VERSION=${var.fleetlock.kustomize_version}
            rm -f /tmp/kustomize
            curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v$$${KUSTOMIZE_VERSION}/kustomize_v$$${KUSTOMIZE_VERSION}_linux_$$${ARCH}.tar.gz | tar -C /tmp -xzf -
            mv /tmp/kustomize /usr/local/bin/kustomize
            chmod 0544 /usr/local/bin/kustomize
          fi

          mkdir -p ${var.data_dir}/server/manifests
          kustomize build /var/opt/fleetlock > ${var.data_dir}/server/manifests/fleetlock.yaml
    %{~endif~}
    %{~endif~}
    %{~if var.kubelet_config.content != ""~}
    - path: /etc/rancher/k3s/kubelet-config.yaml
      mode: 0640
      overwrite: true
      contents:
        inline: |
          apiVersion: kubelet.config.k8s.io/${var.kubelet_config.version}
          kind: KubeletConfiguration
          ${indent(10, var.kubelet_config.content)}
    %{~endif~}
    %{~if !local.is_server_bootstrap~}
    - path: /usr/local/bin/k3s-installer-wait-bootstrap-server.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash
          server_host=${try(split(":", split("://", var.origin_server)[1])[0], var.origin_server)}
          server_port=${try(split(":", var.origin_server)[2], "443")}
          while ! timeout 1 bash -c "2> /dev/null > /dev/tcp/$$${server_host}/$$${server_port}"; do
            echo "Waiting for bootstrap server ${var.origin_server}..."
            sleep 5
          done
    %{~endif~}
    - path: /etc/yum.repos.d/rancher-k3s-common.repo
      mode: 0644
      overwrite: true
      contents:
        inline: |
          [rancher-k3s-common]
          name=Rancher K3s Common)
          baseurl=${var.repo_baseurl}
          enabled=${var.testing_repo ? "0" : "1"}
          gpgcheck=1
          repo_gpgcheck=0
          gpgkey=${var.repo_gpgkey}
    - path: /etc/yum.repos.d/rancher-k3s-common-testing.repo
      mode: 0644
      overwrite: true
      contents:
        inline: |
          [rancher-k3s-common-testing]
          name=Rancher K3s Common Testing)
          baseurl=${var.testing_repo_baseurl}
          enabled=${var.testing_repo ? "1" : "0"}
          gpgcheck=1
          repo_gpgcheck=0
          gpgkey=${var.testing_repo_gpgkey}
systemd:
  units:
    %{~if var.shutdown.service~}
    - name: ${local.k3s_shutdown_service_name}
      enabled: true
      contents: |
        [Unit]
        Description=K3s Shutdown
        DefaultDependencies=no
        Requisite=multi-user.target
        After=multi-user.target
        Before=shutdown.target
        RefuseManualStart=yes
        ConditionPathExists=/usr/local/bin/k3s-shutdown.sh

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=no
        ExecStart=-/usr/local/bin/k3s-shutdown.sh

        [Install]
        WantedBy=shutdown.target
    - name: ${local.k3s_shutdown_uncordon_service_name}
      enabled: true
      contents: |
        [Unit]
        Description=K3s Uncordon After Shutdown
        Wants=network-online.target
        After=network-online.target
        After=${local.k3s_service_name}
        ConditionPathExists=${local.k3s_shutdown_cordon_state_file}

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=no
        ExecStart=/usr/local/bin/k3s-uncordon-node.sh
        ExecStart=/bin/rm -f ${local.k3s_shutdown_cordon_state_file}

        [Install]
        WantedBy=${local.k3s_service_name}
    %{~endif~}
    %{~if var.unit_dropin_k3s != ""~}
    - name: ${local.k3s_service_name}
      dropins:
        - name: overwrite.conf
          contents: |
            ${indent(12, var.unit_dropin_k3s)}
    %{~endif~}
    - name: ${var.install_service_name}
      enabled: true
      %{~if var.unit_dropin_install_k3s != ""~}
      dropins:
        - name: overwrite.conf
          contents: |
            ${indent(12, var.unit_dropin_install_k3s)}
      %{~endif~}
      contents: |
        [Unit]
        Description=Install K3s
        %{~for before_unit in var.before_units~}
        Before=${before_unit}
        %{~endfor~}
        Wants=network-online.target
        After=network-online.target
        After=additional-rpms.service
        %{~for after_unit in var.after_units~}
        After=${after_unit}
        %{~endfor~}
        ConditionPathExists=/usr/local/bin/k3s-pre-installer.sh
        ConditionPathExists=/usr/local/bin/install-k3s.sh
        ConditionPathExists=/usr/local/bin/k3s-post-installer.sh
        ConditionPathExists=/etc/yum.repos.d/rancher-k3s-common.repo
        ConditionPathExists=!/var/lib/%N.done
        %{~if !local.is_server_bootstrap~}
        ConditionPathExists=/usr/local/bin/k3s-installer-wait-bootstrap-server.sh
        %{~endif~}
        StartLimitInterval=200
        StartLimitBurst=3

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=on-failure
        RestartSec=60
        TimeoutStartSec=${local.is_server_bootstrap ? "120" : "180"}
        EnvironmentFile=-${local.k3s_install_service_env_file}
        ExecStartPre=/usr/local/bin/k3s-pre-installer.sh
        ExecStart=/usr/local/bin/install-k3s.sh
        ExecStart=/bin/touch /var/lib/%N.done
        ExecStartPost=/usr/local/bin/k3s-post-installer.sh

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}
