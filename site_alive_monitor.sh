#!/bin/bash
#
# Site Alive Monitor Script.
#
# MIT License
#
# Copyright (c) 2021 Groov-in
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

function send_mail() {
	id=$1
	subject=$2
	body=$3
	prio=$4
	mailfrom=$5
	rcptto=$6
	rcptto2=$7
	rcptto3=$8
	rcptto4=$9
	rcptto5=${10}
	
	/bin/echo -ne "from: ""$mailfrom""\n" > /dev/shm/"$id".mail
	
	/bin/echo -ne "to: ""$rcptto""\n" >> /dev/shm/"$id".mail
	
	if [ "" != "$rcptto2" ]; then
		/bin/echo -ne "to: ""$rcptto2""\n" >> /dev/shm/"$id".mail
	fi
	
	if [ "" != "$rcptto3" ]; then
		/bin/echo -ne "to: ""$rcptto3""\n" >> /dev/shm/"$id".mail
	fi
	
	if [ "" != "$rcptto4" ]; then
		/bin/echo -ne "to: ""$rcptto4""\n" >> /dev/shm/"$id".mail
	fi
	
	if [ "" != "$rcptto5" ]; then
		/bin/echo -ne "to: ""$rcptto5""\n" >> /dev/shm/"$id".mail
	fi
	
	if [ "High" == "$prio" ]; then
		/bin/echo -ne "Priority: urgent\nX-Priority: 1\nX-MSMail-Priority: High\nImportance: High\n" >> /dev/shm/"$id".mail
	fi
	
	if [ "Low" == "$prio" ]; then
		/bin/echo -ne "Priority: non-urgent\nX-Priority: 5\nX-MSMail-Priority: Low\nImportance: Low\n" >> /dev/shm/"$id".mail
	fi
	
	/bin/echo -ne "Content-Type: text/plain; charset=UTF-8\n" >> /dev/shm/"$id".mail
	/bin/echo -ne "Content-Transfer-Encoding: 8bit\n" >> /dev/shm/"$id".mail
	
	/bin/echo -ne "subject: ""$subject""\n\n" >> /dev/shm/"$id".mail
	/bin/echo -ne `date "+%Y-%m-%d %H:%M:%S"`"\n\n" >> /dev/shm/"$id".mail
	/bin/echo -ne "$body""\n" >> /dev/shm/"$id".mail
	
	/usr/sbin/sendmail -f "$mailfrom" -t < /dev/shm/"$id".mail
	cat /dev/shm/"$id".mail
	rm -f /dev/shm/"$id".mail
}

if [ ! -f "$1" ]; then
	echo $1 File Not Found.
	exit -3
fi

. $1

if [ "" == "$TRY_COUNT" ]; then
	TRY_COUNT="3"
fi

LOCK_FILE=/dev/shm/"$UUID".lock

RESULT=-2

for ((i=0; i < ${TRY_COUNT}; i++)); do
	if [ "PING" == "$CHECK_TYPE" ]; then
		ping -c 1 -w 1 "$TARGET_HOST" >/dev/null 2>&1
		RESULT=`echo $?`
	fi

	if [ "PORT" == "$CHECK_TYPE" ]; then
		(sleep 3;echo quit) | telnet "$TARGET_HOST" "$TARGET_PORT" 2>&1 | grep Connected >/dev/null 2>&1
		RESULT=`echo $?`
	fi

	if [ "HTML" == "$CHECK_TYPE" ]; then
		if [ "Y" == "$INSECURE" ]; then
			if [ "" != "$BASIC_AUTH" ]; then
				curl -k -m 30 -o /dev/null -w '%{http_code}\n' -s -u "$BASIC_AUTH" "$TARGET_URL" | grep -w 200 >/dev/null 2>&1
			else
				curl -k -m 30 -o /dev/null -w '%{http_code}\n' -s "$TARGET_URL" | grep -w 200 >/dev/null 2>&1
			fi
		else
			if [ "" != "$BASIC_AUTH" ]; then
				curl -m 30 -o /dev/null -w '%{http_code}\n' -s -u "$BASIC_AUTH" "$TARGET_URL" | grep -w 200 >/dev/null 2>&1
			else
				curl -m 30 -o /dev/null -w '%{http_code}\n' -s "$TARGET_URL" | grep -w 200 >/dev/null 2>&1
			fi
		fi
		RESULT=`echo $?`
	fi

	if [ "SMTP" == "$CHECK_TYPE" ]; then
		(sleep 3;echo quit) | telnet "$TARGET_HOST" "$TARGET_PORT" 2>&1 | grep 220 >/dev/null 2>&1
		RESULT=`echo $?`
	fi

	if [ 0 -eq $RESULT ]; then
		break
	fi
done

if [ 0 -eq $RESULT ]; then
	if [ -f "$LOCK_FILE" ]; then
		send_mail "$UUID" "$RECOVERY_MAIL_SUBJECT" "$RECOVERY_MAIL_BODY" "Low" "$MAIL_FROM" "$RCPT_TO" "$RCPT_TO_2" "$RCPT_TO_3" "$RCPT_TO_4" "$RCPT_TO_5"
		rm -rf "$LOCK_FILE"
	fi
else
	if [ ! -f "$LOCK_FILE" ]; then
		touch "$LOCK_FILE"
		send_mail "$UUID" "$ERROR_MAIL_SUBJECT" "$ERROR_MAIL_BODY" "High" "$MAIL_FROM" "$RCPT_TO" "$RCPT_TO_2" "$RCPT_TO_3" "$RCPT_TO_4" "$RCPT_TO_5"
	fi
fi

exit $RESULT
