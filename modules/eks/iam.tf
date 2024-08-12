

resource "aws_iam_role" "eks-role" {
  name               = "${terraform.workspace}-${var.identifier}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-role.name
}









resource "aws_iam_role" "ahmad-eks-node-role" {
  name = "eks-node-group-${var.identifier}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ahmad-eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ahmad-eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ahmad-eks-node-role.name
}


resource "aws_iam_policy" "eks_to_secrets_manager" {
  name        = "Allow_eks_to_get_value_from_secrets_manager"
  path        = "/"
  description = "Allow To Get Value from secret manager"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
          ],
        "Resource": "arn:aws:secretsmanager:us-west-2:680688655542:secret:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ReadSecretsFromSecretsManager" {
  policy_arn = aws_iam_policy.eks_to_secrets_manager.arn
  role       = aws_iam_role.ahmad-eks-node-role.name

}