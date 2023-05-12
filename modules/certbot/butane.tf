data "template_file" "butane_snippet_install_certbot" {
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
            certbot
            firewalld
    - path: /usr/local/bin/certbot-installer.sh
      mode: 0754
      overwrite: true
      contents:
        inline: |
          #!/bin/bash -e
          echo "Dependencies installed..."
          # firewalld rules
          if ! systemctl is-active firewalld &> /dev/null
          then
            echo "Enabling firewalld..."
            systemctl restart dbus.service
            restorecon -rv /etc/firewalld
            systemctl enable --now firewalld
            echo "Firewalld enabled..."
          fi
          # Add firewalld rules
          echo "Adding firewalld rules..."
          firewall-cmd --zone=public --permanent --add-port=${var.http_01_port}/tcp
          firewall-cmd --reload
          echo "Firewalld rules added..."

          # generate certificate
          echo "Generating certificate..."
          certbot certonly -n --standalone \
            -d '${var.domain}' \
          %{~for additional_domain in var.additional_domains~}
            -d '${additional_domain}' \
          %{~endfor~}
          %{~if var.post_hook.path != "" && var.post_hook.content != ""~}
            --post-hook '${var.post_hook.path}' \
          %{~endif~}
          %{~if var.agree_tos~}
            --agree-tos \
          %{~endif~}
          %{~if var.staging~}
            --staging \
          %{~endif~}
          %{~if var.http_01_port != 80~}
            --http-01-port ${var.http_01_port} \
          %{~endif~}
            --email '${var.email}'
          echo "Certificate generated..."
    %{~if var.post_hook.path != "" && var.post_hook.content != ""~}
    - path: ${var.post_hook.path}
      mode: ${var.post_hook.mode}
      overwrite: true
      contents:
        inline: |
          ${indent(10, var.post_hook.content)}
    %{~endif~}
systemd:
  units:
    - name: install-certbot.service
      enabled: true
      contents: |
        [Unit]
        Description=Install Certbot
        # We run before `zincati.service` to avoid conflicting rpm-ostree
        # transactions.
        Before=zincati.service
        %{~for before_unit in var.before_units~}
        Before=${before_unit}
        %{~endfor~}
        Wants=network-online.target
        After=network-online.target
        After=additional-rpms.service
        %{~for after_unit in var.after_units~}
        After=${after_unit}
        %{~endfor~}
        ConditionPathExists=/usr/local/bin/certbot-installer.sh
        ConditionPathExists=!/var/lib/%N.done
        %{~if var.post_hook.path != "" && var.post_hook.content != ""~}
        ConditionPathExists=${var.post_hook.path}
        %{~endif~}
        StartLimitInterval=200
        StartLimitBurst=3

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        Restart=on-failure
        RestartSec=60
        TimeoutStartSec=120
        ExecStart=/usr/local/bin/certbot-installer.sh
        ExecStart=/bin/touch /var/lib/%N.done

        [Install]
        WantedBy=multi-user.target
TEMPLATE
}
