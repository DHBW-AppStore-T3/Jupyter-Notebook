#cloud-config

# Enable SSH password authentication
ssh_pwauth: true

packages:
  - curl
  - wget
  - git
  - htop
  - nano
  - vim
  - openssl
  - net-tools

groups:
%{ for team in unique_teams ~}
  - ${team}
%{ endfor ~}

users:
%{ for idx, user in all_users ~}
  - name: ${user.username}
    shell: /bin/bash
    sudo: ['ALL=(ALL) ALL']
    groups: ${user.team}
    lock_passwd: false
%{ endfor ~}

# SSH configuration in a separate drop-in file
write_files:
  - path: /etc/ssh/sshd_config.d/99-custom.conf
    content: |
      PasswordAuthentication yes
      PubkeyAuthentication yes
      PermitRootLogin no
      UsePAM yes
    permissions: '0644'

runcmd:
  # Set passwords (plaintext)
%{ for idx, user in all_users ~}
  - echo '${user.username}:${passwords[idx]}' | chpasswd
%{ endfor ~}

  - systemctl restart sshd

  - systemctl enable jupyterhub
  - systemctl restart jupyterhub

  # Optional: Firewall
  - ufw --force enable
  - ufw allow OpenSSH
  - ufw allow 8000/tcp

  # Setup log (passwords intentionally omitted for security)
  - |
    cat >> /var/log/setup-complete.log <<EOF
    ================================================
    Setup complete: $(date)
    ================================================
    Teams: ${join(", ", unique_teams)}
    Users created: ${length(all_users)}
    JupyterHub: Port 8000
    ================================================
    EOF

final_message: |
  ================================================
  JupyterHub Multi-User System ready!
  ================================================
  Teams: ${join(", ", unique_teams)}
  Users: ${length(all_users)}

  Access: http://<vm-ip>:8000
  Login: <username> + password (see Outputs)
  ================================================
