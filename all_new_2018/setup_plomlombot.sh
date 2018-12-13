#!/bin/sh
set -e

# Ensure we have a GPG target to encrypt to.
if [ $# -lt 1 ]; then
    echo "Need public key ID as argument."
    false
fi
gpg_key="$1"

config_tree_prefix="${HOME}/config/all_new_2018/"
irclogs_dir=/var/www/html/irclogs
cp "${config_tree_prefix}"/user_scripts/plomlombot_daemon.sh /home/plom/
chown plom:plom /home/plom/plomlombot_daemon.sh
apt -y install screen python3-venv gpg dirmngr
su plom -c "gpg --recv-key ${gpg_key}"
# TODO: After this, we could in theory remove dirmngr if we only installed it just now.
su plom -c "cd && git clone /var/public_repos/plomlombot-irc"
systemctl enable /etc/systemd/system/plomlombot.service
service plomlombot start
mkdir -p "${irclogs_dir}"
chown -R plom:plom "${irclogs_dir}"
echo "Don't forget to add a file ~/.plomlombot with content such as:"
echo "gpg_key ${gpg_key}"
echo "bot: SCREEN_SESSION_NAME BOT_NAME #CHANNEL_NAME IRC_SERVER_NAME"
