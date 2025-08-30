Here is a set of step-by-step instructions to set up your Debian development VM from your macOS M1 host. This guide incorporates the solutions to all the errors we troubleshooted, making it a more robust, single-pass process.

-----

## Prerequisites on Your macOS Host

First, install the necessary tools on your Mac using Homebrew.

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Ansible for automation, UTM for virtualization, and sshpass for Ansible's password handling
brew install ansible utm sshpass
```

-----

## Step 1: Create the Debian VM with UTM

This step creates the target machine for Ansible.

1.  **Download Debian for ARM:** Get the **netinst** image for **arm64** from the official [Debian website](https://www.debian.org/distrib/).
2.  **Create the VM in UTM:**
      * Open UTM -\> "Create a New Virtual Machine" -\> "Virtualize" -\> "Linux".
      * Enable **"Use Apple Virtualization"** for best performance.
      * Select your downloaded Debian ARM ISO image.
      * Assign hardware resources (e.g., 4GB RAM, 4 CPU cores, 40GB+ disk).
3.  **Install Debian:**
      * Start the VM and proceed with the Debian installation.
      * At the "Software selection" screen, select **only** the following:
          * **SSH server** (absolutely essential)
          * **standard system utilities**
      * Create your user (e.g., `youruser`) and set a strong password. Also, set a password for the `root` user when prompted.
      * **Add user to sudo group:** After installation, log in as root and add your user to the sudo group:
        ```bash
        # Log in as root or switch to root
        su -
        # Add your user to the sudo group (replace 'youruser' with your actual username)
        /usr/sbin/usermod -aG sudo youruser
        # Verify the user is in the sudo group
        groups youruser
        # Logout and log back in as your user for changes to take effect
        exit
        ```
        This is **essential** because the Ansible playbook requires root privileges to install software and configure the system.
4.  **Find the VM's IP Address:** After installation, log into the VM's console and run `ip a` to find its IP address (e.g., `192.168.64.4`).

-----

## Step 2: Set Up the Ansible Project on macOS

Now, prepare the automation files on your Mac.

1.  **Create a Project Directory:**

    ```bash
    mkdir ansible-debian-setup
    cd ansible-debian-setup
    ```

2.  **Create a Deploy Key:** This key will be used to securely clone your private dotfiles repository from GitHub.

    ```bash
    # Creates a key named 'dotfiles_key' without a passphrase
    ssh-keygen -t ed25519 -f ./dotfiles_key -N ""
    ```

      * Go to your dotfiles repository settings on GitHub and add the content of `dotfiles_key.pub` as a **Deploy Key**.
      * **Note:** Your dotfiles repository should contain a `home.nix` file that defines your Home Manager configuration. This file will be automatically configured with the necessary user settings during the playbook execution.

3.  **Encrypt the Deploy Key:** Use Ansible Vault to secure your private key. You'll be prompted to create a vault password.

    ```bash
    ansible-vault encrypt dotfiles_key
    ```

4.  **Create the Inventory File (`inventory.ini`):** This file tells Ansible which machine to configure.

    ```ini
    # inventory.ini
    [vm]
    debian-vm ansible_host=192.168.64.4 ansible_user=youruser
    ```

      * Replace the IP address and `ansible_user` with your VM's details.

-----

## Step 3: Create the Master Ansible Playbook

This `playbook.yml` file contains all the instructions to set up the VM, incorporating fixes for all previously encountered errors.

**`playbook.yml`:**

```yaml
- name: Debian Entwickler-VM aufsetzen
  hosts: vm
  become: yes # Die meisten Tasks brauchen Root-Rechte

  tasks:
    - name: System-Abhängigkeiten installieren
      apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop:
        - curl
        - git

    - name: Nix-Paketmanager installieren
      shell: "curl -L https://nixos.org/nix/install | sh -s -- --daemon"
      args:
        creates: /nix # Wird nur ausgeführt, wenn /nix nicht existiert

    - name: Warten bis Nix-Daemon bereit ist
      wait_for:
        path: /nix/var/nix/daemon-socket/socket
        timeout: 60

    - name: Nix-Profile für User einrichten
      shell: |
        if [ ! -f "/home/{{ ansible_user }}/.nix-profile/etc/profile.d/nix.sh" ]; then
          /nix/var/nix/profiles/default/bin/nix-env --install --attr nixpkgs.nix
        fi
      become_user: "{{ ansible_user }}"
      become: no

    - name: SSH-Verzeichnis für den User erstellen
      file:
        path: "/home/{{ ansible_user }}/.ssh"
        state: directory
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0700'
      become_user: "{{ ansible_user }}"
      become: no

    - name: Verschlüsselten Deploy Key auf die VM kopieren
      copy:
        src: dotfiles_key # Die mit Vault verschlüsselte Datei
        dest: "/home/{{ ansible_user }}/.ssh/dotfiles_key"
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0600'

    - name: SSH-Konfiguration für GitHub erstellen
      blockinfile:
        path: "/home/{{ ansible_user }}/.ssh/config"
        create: yes
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0600'
        block: |
          Host github.com
            HostName github.com
            User git
            IdentityFile /home/{{ ansible_user }}/.ssh/dotfiles_key
            IdentitiesOnly yes

    - name: Dotfiles-Repository klonen
      git:
        repo: git@github.com:yourusername/your-dotfiles.git  # <-- UPDATE THIS
        dest: "/home/{{ ansible_user }}/.dotfiles"
        version: test/nix  # <-- UPDATE BRANCH IF NEEDED
        accept_hostkey: yes
      become_user: "{{ ansible_user }}"
      become: no

    - name: Home Manager Channel hinzufügen
      shell: |
        . "/home/{{ ansible_user }}/.nix-profile/etc/profile.d/nix.sh"
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
      become_user: "{{ ansible_user }}"
      become: no
      args:
        creates: "/home/{{ ansible_user }}/.nix-channels"

    - name: Home Manager installieren
      shell: |
        . "/home/{{ ansible_user }}/.nix-profile/etc/profile.d/nix.sh"
        nix-shell '<home-manager>' -A install
      become_user: "{{ ansible_user }}"
      become: no
      args:
        creates: "/home/{{ ansible_user }}/.nix-profile/bin/home-manager"

    - name: Home Manager Konfigurationsverzeichnis erstellen
      file:
        path: "/home/{{ ansible_user }}/.config/home-manager"
        state: directory
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0755'
      become_user: "{{ ansible_user }}"
      become: no

    - name: Home Manager Konfiguration kopieren und anpassen
      copy:
        src: "/home/{{ ansible_user }}/.dotfiles/home.nix"
        dest: "/home/{{ ansible_user }}/.config/home-manager/home.nix"
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0644'
        remote_src: yes
      become_user: "{{ ansible_user }}"
      become: no

    - name: Benutzerkonfiguration zu home.nix hinzufügen
      lineinfile:
        path: "/home/{{ ansible_user }}/.config/home-manager/home.nix"
        insertafter: "^{"
        line: "  home.username = \"{{ ansible_user }}\";"
        state: present
      become_user: "{{ ansible_user }}"
      become: no

    - name: Home-Verzeichnis Konfiguration zu home.nix hinzufügen
      lineinfile:
        path: "/home/{{ ansible_user }}/.config/home-manager/home.nix"
        insertafter: "home.username"
        line: "  home.homeDirectory = \"/home/{{ ansible_user }}\";"
        state: present
      become_user: "{{ ansible_user }}"
      become: no

    - name: Unfree Pakete erlauben (für VSCode etc.)
      lineinfile:
        path: "/home/{{ ansible_user }}/.config/home-manager/home.nix"
        insertafter: "home.homeDirectory"
        line: "  nixpkgs.config.allowUnfree = true;"
        state: present
      become_user: "{{ ansible_user }}"
      become: no

    - name: Home Manager Konfiguration anwenden
      shell: |
        . "/home/{{ ansible_user }}/.nix-profile/etc/profile.d/nix.sh"
        home-manager switch
      become_user: "{{ ansible_user }}"
      become: no
```

-----

## Step 4: Run the Automation

Execute the playbook from your macOS terminal.

1.  **First Contact (Manual SSH):** Connect to your VM once manually to approve its SSH host key.

    ```bash
    ssh youruser@192.168.64.4
    # Type 'yes' when prompted, then log out with 'exit'.
    ```

2.  **Run the Playbook:** Execute the final command. It will prompt you for three passwords: your Vault password, the SSH login password for `youruser`, and the `sudo` password for `youruser` (which is the same as the login password).

    ```bash
    ansible-playbook -i inventory.ini --ask-vault-pass --ask-pass -K playbook.yml
    ```

Ansible will now automatically configure your entire VM. After it finishes, your Debian environment will be ready with Nix, Home Manager, and all the tools defined in your dotfiles.