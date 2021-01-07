#!/bin/bash
#########################################################
#                   Maildir to Mbox Convertor           #
######################################################### 

echo "Enter the Email account: "
read email_account
echo
echo "Enter the mail folder to convert: "
read mail_dir

domain=`echo $email_account | awk -F\@ '{print $2'}`
user_name=`echo $email_account | awk -F\@ '{print $1}'`
user=`fgrep "$domain" /etc/userdomains | awk '{print $2}'`

if [ -z "$user" ];then
    echo "cPanel User not found !"
    exit
    
else
    cd /home/$user/mail/$domain
    if [ -d $user_name ];then
    echo "Email account $email_account found!"
    else
    echo "Email account $email_account not found"
    exit
    fi
fi

cd /home/$user/mail/$domain/$user_name
directory_list=( $(ls -a | grep -E "^\.[a-zA-Z0-9]" | awk -F\. '{print $2}') )
possible_inputs=(inbox Inbox INBOX)

mkdir /home/$user/Mail_backup
if [[ " ${possible_inputs} " =~ " ${mail_dir} " ]]; then
    echo "Converting cur to mbox"
    for file in find /home/$user/mail/$domain/$user_name/cur -type f
    do
        cat $file | formail -A Date: >> /home/$user/Mail_backup/cur.mbox
    done
    echo "converting new to mbox"
    for file in find /home/$user/mail/$domain/$user_name/new -type f
    do
        cat $file | formail -A Date: >> /home/$user/Mail_backup/new.mbox
    done
    echo "Finished converting !"
    
elif [[ " ${directory_list} " =~ " ${mail_dir,,} " ]]; then
    echo "Converting $mail_dir to mbox"
    for file in find /home/$user/mail/$domain/$user_name/$mail_dir -type f
    do
        cat $file | formail -A Date: >> /home/$user/Mail_backup/$mail_dir.mbox
    done
    echo "Finished converting !"
fi

echo "Zipping the output..."
cd /home/$user
zip -r mailBackup.zip Mail_backup
echo "Zipped the backup, check /home/"$user""
rm -rf Mail_backup