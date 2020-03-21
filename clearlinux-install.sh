# The Flatpak app is included as part of the desktop bundle. 
# Make sure the desktop bundle is installed before installing a Flatpak app: 
sudo swupd bundle-list | grep desktop
sudo swupd bundle-add desktop # Install the desktop bundle
flatpak install flathub com.visualstudio.code # Install VS Code
flatpak install flathub org.vim.Vim # Install Vim