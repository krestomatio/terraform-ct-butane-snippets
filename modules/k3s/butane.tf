locals {
  kubectl_server_option          = var.origin_server != "" ? "--server ${var.origin_server}" : ""
  k3s_shutdown_cordon_state_file = "${var.config.data_dir}/k3s-uncordon.todo"
  k3s_service_name               = var.mode == "agent" ? "k3s-agent.service" : "k3s.service"
  k3s_kubelet_kubeconfig         = "${var.config.data_dir}/agent/kubelet.kubeconfig"
}

data "template_file" "butane_snippet_install_k3s" {
  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    - path: /var/lib/additional-rpms.list
      overwrite: false
      append:
        - inline: |
            k3s-selinux
    - path: /usr/local/bin/k3s-installer.sh
      mode: 0754
      overwrite: true
      contents:
        source: ${var.config.script_url}
        verification:
          hash: sha256-${var.config.script_sha256sum}
    %{~if var.shutdown.service~}
    - path: /usr/local/bin/k3s-shutdown.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash
          export KUBECONFIG=$$${KUBECONFIG:-${local.k3s_kubelet_kubeconfig}}
          if /usr/bin/systemctl is-active --quiet ${local.k3s_service_name}; then
            %{~if var.shutdown.drain~}
            already_cordoned="$(/usr/local/bin/k3s kubectl ${local.kubectl_server_option} get node "$(hostname -f)" -o jsonpath='{.spec.unschedulable}')"
            /usr/local/bin/k3s kubectl ${local.kubectl_server_option} \
              drain "$(hostname -f)" \
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
            %{~if var.shutdown.delete_node~}
            /usr/local/bin/k3s kubectl ${local.kubectl_server_option} \
              delete node "$(hostname -f)"
            %{~endif~}
            %{~if var.shutdown.killall_script~}
            /usr/local/bin/k3s-killall.sh
            %{~endif~}
          fi
    - path: /usr/local/bin/k3s-uncordon-node.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash
          export KUBECONFIG=$$${KUBECONFIG:-${local.k3s_kubelet_kubeconfig}}
          /usr/local/bin/k3s kubectl ${local.kubectl_server_option}  \
            uncordon $(hostname -f)
    %{~endif~}
    %{~if var.config.selinux~}
    - path: /usr/local/bin/k3s-installer-selinux-data-dir.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash
          mkdir -p ${var.config.data_dir}/storage
          restorecon -R ${var.config.data_dir}
    %{~endif~}
    - path: /usr/local/bin/k3s-pre-installer.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -eu
          %{~if contains(["server", "agent"], var.mode)~}
          /usr/local/bin/k3s-installer-wait-bootstrap-server.sh
          %{~endif~}
          %{~if var.fleetlock != null && contains(["bootstrap"], var.mode)~}
          /usr/local/bin/fleetlock-addon-installer.sh
          %{~endif~}
          %{~if var.config.pre_install_script_snippet != ""~}
          ${indent(10, var.config.pre_install_script_snippet)}
          %{~endif~}
    - path: /usr/local/bin/k3s-post-installer.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -eu
          %{~if var.config.selinux~}
          /usr/local/bin/k3s-installer-selinux-data-dir.sh
          %{~endif~}
          %{~if var.config.post_install_script_snippet != ""~}
          ${indent(10, var.config.post_install_script_snippet)}
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
    %{~if contains(["bootstrap"], var.mode)~}
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
                    containers:
                    - name: fleetlock
                      env:
                      - name: NAMESPACE
                        valueFrom:
                          fieldRef:
                            fieldPath: metadata.namespace
                    %{~if length(var.fleetlock.node_selectors) > 0~}
                    nodeSelector:
                    %{~for label, value in var.fleetlock.node_selectors~}
                    ${label}: "${value}"
                    %{~endfor~}
                    %{~endif~}
                    %{~if length(var.fleetlock.tolerations) > 0~}
                    tolerations:
                    %{~for toleration in var.fleetlock.tolerations~}
                    - key: "${toleration.key}"
                      operator: "${toleration.operator}"
                      %{~if toleration.value != null~}
                      value: "${toleration.value}"
                      %{~endif~}
                      effect: "${toleration.effect}"
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

          mkdir -p ${var.config.data_dir}/server/manifests
          kustomize build /var/opt/fleetlock > ${var.config.data_dir}/server/manifests/fleetlock.yaml
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
    %{~if contains(["server", "agent"], var.mode)~}
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
          baseurl=${var.config.repo_baseurl}
          enabled=${var.config.testing_repo ? "0" : "1"}
          gpgcheck=1
          repo_gpgcheck=0
          gpgkey=${var.config.repo_gpgkey}
    - path: /etc/yum.repos.d/rancher-k3s-common-testing.repo
      mode: 0644
      overwrite: true
      contents:
        inline: |
          [rancher-k3s-common-testing]
          name=Rancher K3s Common Testing)
          baseurl=${var.config.testing_repo_baseurl}
          enabled=${var.config.testing_repo ? "1" : "0"}
          gpgcheck=1
          repo_gpgcheck=0
          gpgkey=${var.config.testing_repo_gpgkey}
    %{~if var.secret_encryption.key != null && contains(["bootstrap", "server"], var.mode)~}
    - path: ${var.secret_encryption.path}
      mode: 0600
      contents:
        inline: |
          {"kind":"EncryptionConfiguration","apiVersion":"apiserver.config.k8s.io/v1","resources":[{"resources":["secrets"],"providers":[{"aescbc":{"keys":[{"name":"aescbckey","secret":"${var.secret_encryption.key}"}]}},{"identity":{}}]}]}
    %{~endif~}
systemd:
  units:
    %{~if var.shutdown.service~}
    - name: shutdown-${local.k3s_service_name}
      enabled: true
      contents: |
        [Unit]
        Description=K3s Shutdown
        DefaultDependencies=no
        Wants=network-online.target
        After=network-online.target
        After=${local.k3s_service_name}
        Requisite=${local.k3s_service_name}
        Before=shutdown.target
        RefuseManualStart=yes
        ConditionPathExists=/usr/local/bin/k3s-shutdown.sh

        [Service]
        Type=oneshot
        ExecStart=-/usr/local/bin/k3s-shutdown.sh

        [Install]
        WantedBy=shutdown.target
    - name: shutdown-uncordon-${local.k3s_service_name}
      enabled: true
      contents: |
        [Unit]
        Description=K3s Uncordon After Shutdown
        Wants=network-online.target
        After=network-online.target
        After=${local.k3s_service_name}
        Requires=${local.k3s_service_name}
        ConditionPathExists=${local.k3s_shutdown_cordon_state_file}

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=no
        ExecStart=/usr/local/bin/k3s-uncordon-node.sh
        ExecStart=/bin/rm -f ${local.k3s_shutdown_cordon_state_file}

        [Install]
        WantedBy=multi-user.target
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
        ConditionPathExists=/usr/local/bin/k3s-installer.sh
        ConditionPathExists=/etc/yum.repos.d/rancher-k3s-common.repo
        ConditionPathExists=!/var/lib/%N.done
        %{~if contains(["server", "agent"], var.mode)~}
        ConditionPathExists=/usr/local/bin/k3s-installer-wait-bootstrap-server.sh
        %{~endif~}
        StartLimitInterval=200
        StartLimitBurst=3

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=on-failure
        RestartSec=60
        TimeoutStartSec=%{if contains(["bootstrap"], var.mode)}120%{else}180%{endif}
        %{~if var.channel != ""~}
        Environment="INSTALL_K3S_CHANNEL=${var.channel}"
        %{~endif~}
        %{~if contains(["bootstrap"], var.mode)~}
        # harmless to leave flag here
        Environment="K3S_CLUSTER_INIT=true"
        %{~endif~}
        %{~if var.mode != "agent"~}
        %{~if var.token != ""~}
        Environment="K3S_TOKEN=${var.token}"
        %{~endif~}
        %{~if var.agent_token != ""~}
        Environment="K3S_AGENT_TOKEN=${var.agent_token}"
        %{~endif~}
        %{~else~}
        %{~if var.agent_token != ""~}
        Environment="K3S_TOKEN=${var.agent_token}"
        %{~else~}
        Environment="K3S_TOKEN=${var.token}"
        %{~endif~}
        %{~endif~}
        %{~for envvar in var.config.envvars~}
        Environment="${envvar}"
        %{~endfor~}
        ExecStartPre=/usr/local/bin/k3s-pre-installer.sh
        ExecStart=/usr/local/bin/k3s-installer.sh
%{~if contains(["bootstrap", "server"], var.mode)} server%{endif}
%{~if contains(["agent"], var.mode)} agent%{endif}
%{~if contains(["agent", "server"], var.mode)} --server ${var.origin_server}%{endif}
%{~if var.config.selinux} --selinux%{endif}
%{~if var.kubelet_config.content != ""} --kubelet-arg 'config=/etc/rancher/k3s/kubelet-config.yaml'%{endif}
%{~if true} --data-dir ${var.config.data_dir} ${join(" ", var.config.parameters)}%{endif}
        ExecStartPre=/usr/local/bin/k3s-post-installer.sh
        ExecStart=/bin/touch /var/lib/%N.done

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}
