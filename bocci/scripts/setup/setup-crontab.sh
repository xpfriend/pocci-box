#!/bin/bash
set -ex

echo 'MAILTO=""' >/tmp/task-schedule.txt
cat /tmp/*-task-schedule.txt >>/tmp/task-schedule.txt
sudo -u ${POCCI_USER} crontab /tmp/task-schedule.txt
rm -f /tmp/*task-schedule.txt
