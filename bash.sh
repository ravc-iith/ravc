#!/bin/bash

############### A D M I N ############################################## INITIALIZATION #####################################################
command0='rm -rf ROOT/'
gnome-terminal --title="Deleting root" -x sh -c "$command0;"

sleep 1

command1='python3 AttributeCertifier.py --title "Identity Certificate" --name IdP --req-ip 127.0.0.1 --req-port 3001  --open-ip 127.0.0.1 --open-port 7001'

command2='python3 AttributeCertifier.py --title "Income Certificate" --name Employer --req-ip 127.0.0.1 --req-port 3002  --open-ip 127.0.0.1 --open-port 7002 --dependency "Identity Certificate"'

command3='truffle migrate --reset –compile-all'

gnome-terminal --title="Identity CA" -x sh -c "$command1 < Identity_input.txt;bash"
sleep 1
gnome-terminal --title="Income CA" -x sh -c "$command2 < Income_input.txt;bash"
sleep 1
gnome-terminal --title="SC Deploying" -x sh -c "$command3 > SC_output.txt;"
#bash avoided at tail end to exit the tab after execution
sleep 10 #waiting for SC deployment

Opening=$(sed -n '160p' SC_output.txt)
Issue=$(sed -n '161p' SC_output.txt)
Request=$(sed -n '162p' SC_output.txt)
Params=$(sed -n '163p' SC_output.txt)
Verify=$(sed -n '164p' SC_output.txt)

#echo $Params

command4='python3 ProtocolInitiator_DeployContracts.py --params-address $(sed -n '163p' SC_output.txt) --request-address $(sed -n '162p' SC_output.txt) --issue-address $(sed -n '161p' SC_output.txt) --opening-address $(sed -n '160p' SC_output.txt)'

gnome-terminal --title="ProtocolInitiator_DeployContracts" -x sh -c "$command4;"
sleep 5

command5='python3 ProtocolInitiator_AC_Setup.py --title "Loan Credential" --name Loaner --ip 127.0.0.1 --port 4000 --dependency "Identity Certificate" "Income Certificate"'

gnome-terminal --title="ProtocolInitiator_AC_Setup" -x sh -c "$command5 < ProtocolInitiator_input.txt;"
sleep 5

command6='python3 ProtocolInitiator_UpdateCAInformation.py --titles "Identity Certificate" "Income Certificate" --address 0xE279a5e0DEb02eDe68876bea8206EeFb2Ab0E96C --rpc-endpoint "http://127.0.0.1:7545"'

gnome-terminal --title="ProtocolInitiator_UpdateCAInformation" -x sh -c "$command6;"
sleep 5

command7='python3 ProtocolInitiator_AnonymousCredentials.py --title "Loan Credential" --address 0xE279a5e0DEb02eDe68876bea8206EeFb2Ab0E96C --validator-addresses 0x444D3aa9426Ca8e339d607bF53262A8B524B844e 0x2D0B894312087b3BF55e4432871b6FD3CC8c180A 0x5126e167868d403dba7DbC5a28bA0e5ACbb086C0 --opener-addresses 0x202870f3671F1d6B401693FBcF66082781D1958F 0x34aB8f91ef8524a9eCF47D2eC6ab1DBdC3a2D704 0xdedCA5790B8899dA5168a4D34b171A8294D0Fb5F --rpc-endpoint "http://127.0.0.1:7545"'

gnome-terminal --title="ProtocolInitiator_AnonymousCredentials" -x sh -c "$command7;"
sleep 5

############### ############################################## #####################################################

command8='python3 Validator.py --title "Loan Credential" --id 1 --address 0x444D3aa9426Ca8e339d607bF53262A8B524B844e --rpc-endpoint "http://127.0.0.1:7545"'
command9='python3 Validator.py --title "Loan Credential" --id 2 --address 0x2D0B894312087b3BF55e4432871b6FD3CC8c180A --rpc-endpoint "http://127.0.0.1:7545"'
command10='python3 Validator.py --title "Loan Credential" --id 3 --address 0x5126e167868d403dba7DbC5a28bA0e5ACbb086C0 --rpc-endpoint "http://127.0.0.1:7545"'

command11='python3 Opener.py --title "Loan Credential" --id 1 --ip 127.0.0.1 --port 8001 --address 0x202870f3671F1d6B401693FBcF66082781D1958F --rpc-endpoint "http://127.0.0.1:7545"'
command12='python3 Opener.py --title "Loan Credential" --id 2 --ip 127.0.0.1 --port 8002 --address 0x34aB8f91ef8524a9eCF47D2eC6ab1DBdC3a2D704 --rpc-endpoint "http://127.0.0.1:7545"'
command13='python3 Opener.py --title "Loan Credential" --id 3 --ip 127.0.0.1 --port 8003 --address 0xdedCA5790B8899dA5168a4D34b171A8294D0Fb5F --rpc-endpoint "http://127.0.0.1:7545"'

gnome-terminal --title="Validator 1" -x sh -c "$command8;bash"
gnome-terminal --title="Validator 2" -x sh -c "$command9;bash"
gnome-terminal --title="Validator 3" -x sh -c "$command10;bash"

gnome-terminal --title="Opener 1" -x sh -c "$command11;bash"
gnome-terminal --title="Opener 2" -x sh -c "$command12;bash"
gnome-terminal --title="Opener 3" -x sh -c "$command13;bash"

sleep 15
command14='python3 SP.py --title "Loan Service" --name Bank --address 0xB1A0d85CFeA6ce282729adb7e66CD69f57DC3245 --verify-address $(sed -n '164p' SC_output.txt) --rpc-endpoint "http://127.0.0.1:7545" --accepts "Loan Credential"'

#gnome-terminal --title="Service Provider" -x sh -c "$command14 < SP_input.txt;bash"
#gnome-terminal --title="Service Provider" -x sh -c "$command14;bash"

sleep 15

command15='python3 User.py --unique-name user1 --address 0x1A1684c3027eA12046155013BfC5518C65dD5943 --rpc-endpoint "http://127.0.0.1:7545"'
#gnome-terminal --title="User 1" -x sh -c "$command15 < User_input.txt;bash"
#gnome-terminal --title="User 1" -x sh -c "$command15;bash"

python3 User.py --title "Loan Service" --name Bank --address 0xB1A0d85CFeA6ce282729adb7e66CD69f57DC3245 --verify-address $(sed -n '164p' SC_output.txt) --accepts "Loan Credential" --unique-name user1 --address 0x1A1684c3027eA12046155013BfC5518C65dD5943 --rpc-endpoint "http://127.0.0.1:7545"


