data "template_file" "butane_snippet_install_k3s" {
  template = <<TEMPLATE
---
variant: fcos
version: 1.4.0
storage:
  files:
    # pkg dependencies to be installed by additional-rpms.service
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
    - path: /usr/local/bin/k3s-installer-post.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash

          # workaround for https://github.com/k3s-io/k3s-selinux/issues/36#issuecomment-1556803739
          mkdir -p ${var.config.data_dir}/storage
          restorecon -R ${var.config.data_dir}
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
          echo "Installing kustomize..."
          if ! which kustomize &>/dev/null; then
            ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
            KUSTOMIZE_VERSION=${var.fleetlock.kustomize_version}
            rm -f /tmp/kustomize
            curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v$$${KUSTOMIZE_VERSION}/kustomize_v$$${KUSTOMIZE_VERSION}_linux_$$${ARCH}.tar.gz | tar -C /tmp -xzf -
            mv /tmp/kustomize /usr/local/bin/kustomize
            chmod 0544 /usr/local/bin/kustomize
          fi
          echo "Done installing kustomize"

          echo "Installing fleetlock manifests..."
          mkdir -p ${var.config.data_dir}/server/manifests
          kustomize build /var/opt/fleetlock > ${var.config.data_dir}/server/manifests/fleetlock.yaml
          echo "Done installing fleetlock manifests"
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
          echo "Waiting for bootstrap server ${var.origin_server}..."
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
    %{~if var.unit_dropin_k3s != ""~}
    - name: k3s.service
      dropins:
        - name: overwrite.conf
          contents: |
            ${indent(12, var.unit_dropin_k3s)}
    %{~endif~}
    %{~if var.unit_dropin_install_k3s != ""~}
    - name: install-k3s.service
      dropins:
        - name: overwrite.conf
          contents: |
            ${indent(12, var.unit_dropin_install_k3s)}
    %{~endif~}
    - name: install-k3s.service
      enabled: true
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
        # We run before `zincati.service` to avoid conflicting rpm-ostree
        # transactions.
        Before=zincati.service
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
        # harmless to leave `K3S_CLUSTER_INIT=true` flag here. See https://github.com/k3s-io/k3s/discussions/7107#discussioncomment-5349940
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
        %{~if contains(["server", "agent"], var.mode)~}
        ExecStartPre=/usr/local/bin/k3s-installer-wait-bootstrap-server.sh
        %{~endif~}
        %{~if var.fleetlock != null~}
        ExecStartPre=/usr/local/bin/fleetlock-addon-installer.sh
        %{~endif~}
        ExecStart=/usr/local/bin/k3s-installer.sh
%{~if contains(["bootstrap", "server"], var.mode)} server%{endif}
%{~if contains(["agent"], var.mode)} agent%{endif}
%{~if contains(["agent", "server"], var.mode)} --server ${var.origin_server}%{endif}
%{~if var.config.selinux} --selinux%{endif}
%{~if var.kubelet_config.content != ""} --kubelet-arg 'config=/etc/rancher/k3s/kubelet-config.yaml'%{endif}
%{~if true} --data-dir ${var.config.data_dir} ${join(" ", var.config.parameters)}%{endif}
        ExecStart=/usr/local/bin/k3s-installer-post.sh
        ExecStart=/bin/touch /var/lib/%N.done

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}
