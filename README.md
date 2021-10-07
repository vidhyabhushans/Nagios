# Nagios


1) Edit nrpe.sh file
 on line 62, add nagios server ip
 
     sed -i "s&allowed_hosts=127.0.0.1,::1&allowed_hosts=127.0.0.1,::1, <X.X.X.X>, <X.X.X.X>&" /usr/local/nagios/etc/nrpe.cfg;
     
2) chmod +x nrpe.sh and execute it "./nrpe.sh"
3) test service from nagios server
    /usr/lib64/nagios/plugins/check_nrpe -H <>
4) go to the nagios directory and create cfg file
5) test configuration and check any error

   /usr/sbin/nagios  -v /etc/nagios/nagios.cfg
 
6) on no error restart nagios service
    systemctl restart nagios
