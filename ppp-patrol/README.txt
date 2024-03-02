# create common/_config.py

python3 -m venv venv
. ./venv/bin/activate
pip install -r requirements.txt

crontab -e

@reboot /root/pp-park-project/ppp-patrol/cron/boot.sh
*/5 * * * * /root/pp-park-project/ppp-patrol/cron/5min.sh
