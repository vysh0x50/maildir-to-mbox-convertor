#!/bin/bash
#Bash Script to convert Maildir to Mbox using formail in cPanel servers

echo "Enter the Email account: "
read email_account
echo
echo "Enter the mail folder to convert: "
read mail_dir
echo

domain=`echo $email_account | awk -F\@ '{print $2'}`
user_name=`echo $email_account | awk -F\@ '{print $1}'`
user=`fgrep "$domain" /etc/userdomains | awk '{print $2}' | head -1`

#checking the respective cPanel user exist or not
if [ -z "$user" ];then
    echo "cPanel User not found !"
    exit
    
else
    cd /home/$user/mail/$domain
    if [ -d "$user_name" ];then
    echo "Email account $email_account found!"
    echo
    else
    echo "Email account $email_account not found"
    exit
    fi
fi

cd /home/$user/mail/$domain/$user_name
#creating a list of custom mail folders
directory_list=( $(ls -a | grep -E "^\.[a-zA-Z0-9]" | awk -F\. '{print $2}') )
#array of possible inputs
possible_inputs=(inbox Inbox INBOX)

mkdir /home/$user/Mail_backup
if [[ " ${possible_inputs} " =~ " ${mail_dir} " ]]; then
    echo "Converting inbox..."
    echo
    #converting cur to mbox
    for file in `find /home/$user/mail/$domain/$user_name/cur -type f`
    do
        cat $file | formail -A Date: >> /home/$user/Mail_backup/cur.mbox
    done
   
    #converting new to mbox
    for file in `find /home/$user/mail/$domain/$user_name/new -type f`
    do
        cat $file | formail -A Date: >> /home/$user/Mail_backup/new.mbox
    done
    cd /home/$user/Mail_backup

    #combining cur and new to inbox
    cat cur.mbox new.mbox > inbox.mbox
    rm -f cur.mbox
    rm -f new.mbox
    echo "Finished converting !"
    echo
elif [[ " ${directory_list[@],,} " =~ " ${mail_dir,,} " ]]; then
    echo "Converting $mail_dir..."
    for file in `find /home/$user/mail/$domain/$user_name/.$mail_dir -type f`
    do
        cat $file | formail -A Date: >> /home/$user/Mail_backup/$mail_dir.mbox
    done
    echo "Finished converting !"
    echo
fi

#zipping the backup
echo "Creating a zip of the mail backup..."
echo

cd /home/$user
#chown $user:$user Mail_backup -R
zip -r "$user_name""_""$mail_dir.zip" Mail_backup
rm -rf Mail_backup
chown $user:$user "$user_name""_""$mail_dir.zip"
echo

echo "Zip file created and placed it in /home/"$user" as "$user_name""_""$mail_dir.zip" "
