# Terraform definition for the lab Controllers
#

data "template_file" "controller_userdata" {
  count    = "${var.student_count}"
  template = "${file("${path.module}/userdata/controller.userdata")}"

  vars {
    hostname = "${var.id}-student${count.index + 1}-controller"
    jump_ip  = "${aws_instance.jump.private_ip}"
    number   = "${count.index + 1}"
  }
}

resource "aws_instance" "ctrl" {
  count                       = "${var.student_count}"
  ami                         = "${lookup(var.ami_avi_controller, var.aws_region)}"
  availability_zone           = "${lookup(var.aws_az, var.aws_region)}"
  instance_type               = "${var.flavour_avi}"
  key_name                    = "${var.key}"
  vpc_security_group_ids      = ["${aws_security_group.ctrlsg.id}"]
  subnet_id                   = "${aws_subnet.pubnet.id}"
  associate_public_ip_address = true
  iam_instance_profile        = "AviController-Refined-Role"
  source_dest_check           = false
  user_data              = "${data.template_file.controller_userdata.*.rendered[count.index]}"
  depends_on                  = ["aws_instance.jump"]

  tags {
    Name  = "${var.id}-student${count.index + 1}-controller"
    Owner = "${var.owner}"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.vol_size_avi}"
    delete_on_termination = "true"
  }
}
