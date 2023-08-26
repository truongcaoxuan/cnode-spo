#!/bin/bash
# Check if the session exists, discarding output
# We can check $? for the exit status (zero for success, non-zero for failure)

session="cardano"
# Check if the session exists, discarding output
# We can check $? for the exit status (zero for success, non-zero for failure)
tmux has-session -t $session 2>/dev/null

if [ $? != 0 ]; then
        echo "Session not found."
else
         echo "Killing session"
        tmux kill-session -t cardano
fi
