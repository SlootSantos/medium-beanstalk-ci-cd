# eb application #
resource "aws_elastic_beanstalk_application" "ci_cd" {
  name        = "ci_cd"
  description = "This is the ci/cd application"
}

# eb environment #
resource "aws_elastic_beanstalk_environment" "ci_cd_env" {
  name                = "ci_cd-env"
  application         = aws_elastic_beanstalk_application.ci_cd.name
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.20.3 running Multi-container Docker 19.03.6-ce (Generic)"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ci_cd_beanstalk_profile.arn
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
}



resource "aws_iam_instance_profile" "ci_cd_beanstalk_profile" {
  name = "ci_cd_profile"
  role = aws_iam_role.ci_cd_beanstalk_role.name
}

resource "aws_iam_role" "ci_cd_beanstalk_role" {
  name = "ci_cd-beanstalk-role"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# required to fetch the container from your private registry if custom image
data "aws_iam_policy" "ECR_READ" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "beanstalk_role_policy_attach_ECR_READ" {
  role       = aws_iam_role.ci_cd_beanstalk_role.name
  policy_arn = data.aws_iam_policy.ECR_READ.arn
}

# required to execute the container as WEB tier
data "aws_iam_policy" "BEANSTALK_WEB" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "beanstalk_role_policy_attach_BEANSTALK_WEB" {
  role       = aws_iam_role.ci_cd_beanstalk_role.name
  policy_arn = data.aws_iam_policy.BEANSTALK_WEB.arn
}

# required to run a multicontainer platform application
data "aws_iam_policy" "BEANSTALK_MULTI_DOCKER" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "beanstalk_role_policy_attach_BEANSTALK_MULTI_DOCKER" {
  role       = aws_iam_role.ci_cd_beanstalk_role.name
  policy_arn = data.aws_iam_policy.BEANSTALK_MULTI_DOCKER.arn
}