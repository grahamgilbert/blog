---
title: Restricting access to the Crypt GUI in AWS
date: 2020-01-13T10:30:46-00:00
layout: post
categories:
 - Crypt
 - AWS
 - Terraform
---

[Crypt is a client secret escrow tool](https://github.com/grahamgilbert/crypt-server) (primarily FileVault, but other secret types too). Because it hold secrets, it is common to want to restrict access to retrieving secrets to certain locations.

If you are running one node, you can simply add something like the following to your Nginx configuration:

```
upstream crypt {
  server 127.0.0.1:8000 fail_timeout=0;
}

server {
    listen 443 ssl ;
    server_name crypt.company.com;

    expires 1h;

    ssl on;
    ssl_certificate           /etc/nginx/ssl/crypt.company.com.pem;
    ssl_certificate_key       /etc/nginx/ssl/crypt.company.com.key;
    add_header X-Frame-Options "SAMEORIGIN";
    access_log            /var/log/nginx/crypt.access.log;

    location ~ ^/(checkin) {
        proxy_pass http://crypt;
        # your proxy settings here
    }

    location / {
        proxy_redirect         http:// https://;
        proxy_pass             http://crypt;
        # your proxy settings here
        allow 10.0.0.0/8; # Office network
        allow 172.16.0.0/12; #VPC
        deny all;
    }
}
```

The above will allow everyone access to the `/checkin` endpoint (so keys continue to be escrowed), but restrict any other page to the subnets listed.

But what about when you have multiple application servers behind an [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)? Wouldn't it be great if you could block the traffic before it even gets to Nginx? Fortunately this is pretty simple with [Listener Rules](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-rules).

If you have more than one or two subnets that you need to whitelist, you're either going to have a lot of clicking, or if you're doing it (half) right, a lot of copy and pasted Terraform code. But wait - Terraform supports `count`. We can reduce the amount of copypasta with something like this (much is omitted from the below, like instances and the actual load balancer):

``` hcl
variable "allowed_subnets" {
    type = "list"
    default = [
        "10.0.0.0/8",
        "172.16.0.0/12"
    ]
}

resource "aws_lb_listener" "crypt" {
  load_balancer_arn = "${aws_lb.crypt.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "my_certificate_arn"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Unauthorized"
      status_code  = "403"
    }
  }
}

resource "aws_alb_listener_rule" "crypt_checkin" {
  listener_arn = "${aws_lb_listener.crypt.arn}"
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.crypt.arn}"
  }

  condition {
    path_pattern {
      values = ["/checkin?"]
    }
  }
}

resource "aws_alb_listener_rule" "crypt_admin" {
  listener_arn = "${aws_lb_listener.crypt.arn}"
  priority     = "${count.index + 10}"
  count        = "${length(var.allowed_subnets)}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.crypt.arn}"
  }

  condition {
    source_ip {
      values = ["${var.allowed_subnets[count.index]}"]
    }
  }
}

resource "aws_lb_target_group" "crypt" {
  name        = "crypt-prod"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.vpc}"

  health_check {
    path     = "/admin/login/"
    interval = "30"
  }
}
```
