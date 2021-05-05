#!/bin/bash
. encpass.sh
send_invite()  {
invite_req=`curl --location --request POST ''$cs_url'/v1/svc-account/invites' -H 'Authorization: Bearer '$1'' -H 'Content-Type: application/json' --data-raw '{ "inviter_account_id": "'$2'", "inviter_user_id":"'$5'", "account_ids": ["'$6'", "'$2'"], "invitees": [ {"first_name": "", "last_name": "", "email": "'$3'"}], "role_id": "'$4'", "cascade": "CASCADE_UPWARD"}'`
echo "\n Invite: $invite_req"
exit 0
  }
inviter_account_id=$(get_secret invite inviter_account_id)
inviter_user_id=$(get_secret invite inviter_user_id)
role_id=$(get_secret invite role_id)
client_id=$(get_secret invite client_id)
client_secret=$(get_secret invite client_secret)
account_id=$(get_secret invite account_id)
cs_url=$(get_secret invite cs_url)
udf_url=$(get_secret invite udf_url)
invite_accepted=0
bearer=`curl --location --request POST ''$cs_url'/v1/svc-auth/login' -H 'Content-Type: application/json' --data-raw '{"client_id": "'$client_id'", "client_secret": "'$client_secret'", "grant_type": "client_credentials" }' | jq '.access_token' |sed 's/"//g'`
user_email=`curl --location --request GET ''$udf_url'/deployment/deployer'`
declare -a status
status=(`curl --location --request GET ''$cs_url'/v1/svc-account/invites' -H 'Authorization: Bearer '$bearer' '| jq -r '.invites[] | select(.invitee_email == "'$user_email'" ).status ' | sed 's/$/ /' | tr -d '\n' `)
number_invites=${#status[@]}
echo "Number of invites sent for this email: '$number_invites': ${status[@]}"
if [ $number_invites != 0 ]; then
  for i in "${status[@]}" ; do
    if [ accepted == $i ]; then
    echo "No need to send an invite"
    exit 0
  break
    fi
done;
fi
send_invite $bearer $inviter_account_id $user_email $role_id $inviter_user_id $account_id
