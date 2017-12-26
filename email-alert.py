import config as cfg
import smtplib

sent_from = cfg.gmail_user
to = [cfg.gmail_to]
subject = 'Raspberry pi alert'
body = 'Progress failed'

email_text = """\
From: %s
To: %s
Subject: %s

%s
""" % (sent_from, ", ".join(to), subject, body)

try:
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    server.ehlo()
    print(cfg.gmail_user, cfg.gmail_pw)
    server.login(cfg.gmail_user, cfg.gmail_pw)
    server.sendmail(sent_from, to, email_text)
    server.close()
except:
    print("Sending alert was failed.")
    raise