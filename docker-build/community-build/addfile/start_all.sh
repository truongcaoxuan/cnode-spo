#!/bin/bash
session="cardano"
# Check if the session exists, discarding output
# We can check $? for the exit status (zero for success, non-zero for failure)
tmux has-session -t $session 2>/dev/null
if [ $? != 0 ]; then
tmux attach-session -t $session
tmux new -s "cardano" -n "node" -d
tmux split-window -h
tmux split-window -v
tmux select-pane -t 'cardano:node.0'
#tmux split-window -h
tmux send-keys -t 'cardano:node.2' '/opt/cardano/cnode/scripts/cnode.sh' Enter
tmux send-keys -t 'cardano:node.0' '/opt/cardano/cnode/scripts/gLiveView.sh' Enter
tmux send-keys -t 'cardano:node.1' 'htop' Enter
tmux send-keys -t 'cardano:node.3' 'nload' Enter
fi
tmux attach-session -t $session
