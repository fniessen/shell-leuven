# User dependent .bash_profile file

# Source the user's .bashrc if it exists.
if [[ -f "$HOME"/.bashrc ]]; then
    . "$HOME"/.bashrc
fi
