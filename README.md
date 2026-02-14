# update-dns

Shell script that updates DNS in AWS Route 53.

Useful if you have a computer at home with a dynamic IP address that changes now and then, and you want to be able to reach it with a domain name that you keep in AWS Route 53.

This script checks your current IP address, compares it to the IP it last saw, and updates your AWS Route 53 domain name to point the new IP address if the new IP address does not match the old one.

For this to work, you must have

  - created an AWS policy that allows you to update records in your hosted zone
  - created a user that has the above policy attached
  - installed aws-cli and configured it with the new user
  - copied update-dns-example.conf to update-dns.conf, and then adjusted the settings for your situation

Example policy (don't forget to change Z1234567890ABC to your own hosted zone ID):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/Z1234567890ABC"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/Z1234567890ABC"
      ]
    }
  ]
}
```

Example installation and configuration:

```sh
  $ sudo snap install aws-cli --classic
  $ aws configure
```
