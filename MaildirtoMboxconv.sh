#!/bin/bash
echo "Please enter the cPanel username: "
read user
echo
echo "Please enter the domain of email account: "
read domain_name
echo
echo "Please enter the username of email account: "
read user_name
echo
echo "Please enter the mail directory you wish to export: "
read mail_dir

#checking the existence of cpanel user
cd /var/cpanel/users
 for $user in *
 do
    if [[ -d $user ]];then
    echo $user "found !"
    else
    echo "The " $user " not found in the server ! Please enter a valid cPanel user "
    exit
 done

#checking the existence of entered domain under mail folder in the respective user
cd /home/$user/mail
for $domain_name in *
do 
  if [[ -d $domain_name ]];then
  echo $domain_name " found for the user " $user
  else
  echo "The " $domain_name " not found for the user " $user " Please enter a valid domain name "
  exit
done

#checking the existence of email account
cd /home/$user/mail/$domain_name
for $user_name in *
do
    if [[ -d $user_name ]]; then
    echo "The email account " $user_name"@"$domain_name " found !"
    else
    echo "The email account " $user_name"@"$domain_name " not found ! Please enter a valid username "
    exit
done

#checking the existence of entered mail directory
cd /home/$user/mail/$domain_name/$user_name
possible_inputs= (inbox Inbox INBOX)
if [[ " ${possible_inputs[@]} " =~ " $mail_dir " ]];then
mkdir /home/$user/Mail_backup
    echo "Mail directory found !"
    echo "Converting cur to mbox format"
    for file in find /home/$user/mail/$domain_name/$user_name/cur -type f
    do
        cat $file | formail -A Date: &gt;&gt; /home/$user/Mail_backup/cur.mbox
    done
    echo "converting new to mbox format"
    for file in find /home/$user/mail/$domain_name/new -type f
    do
        cat $file | formail -A Date: &gt;&gt; /home/$user/Mail_backup/new.mbox
    done
    echo "Converted inbox to mbox format, please check the output in /home/$user/Mail_backup"
fi
